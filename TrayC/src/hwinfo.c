/*
 * hwinfo.c — Hardware detection, registry, COM/WMI.
 */
#include <winsock2.h>
#include <windows.h>

#include "hwinfo.h"

#include <iphlpapi.h>
#include <ctype.h>
#include <pdh.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wchar.h>
#include <wbemidl.h>

/* ── COM / WMI ──────────────────────────────────────────────────── */

void com_init(void) {
  HRESULT hr = CoInitializeEx(0, COINIT_MULTITHREADED);
  if (FAILED(hr))
    return;
  hr = CoInitializeSecurity(NULL, -1, NULL, NULL, RPC_C_AUTHN_LEVEL_DEFAULT,
                            RPC_C_IMP_LEVEL_IMPERSONATE, NULL, EOAC_NONE, NULL);
  if (FAILED(hr) && hr != (HRESULT)RPC_E_TOO_LATE) {
    CoUninitialize();
    return;
  }
  g_comOk = TRUE;
}

void com_deinit(void) {
  if (g_comOk) {
    CoUninitialize();
    g_comOk = FALSE;
  }
}

/* ── WMI helper genérico ─────────────────────────────────────────── */

static BOOL wmi_query_first(const WCHAR *ns, const WCHAR *wql, const WCHAR *field,
                            WCHAR *dest, DWORD destLen) {
  wcscpy_s(dest, destLen, L"N/A");
  if (!g_comOk)
    return FALSE;

  IWbemLocator *pLoc = NULL;
  IWbemServices *pSvc = NULL;
  IEnumWbemClassObject *pEnum = NULL;
  IWbemClassObject *pObj = NULL;
  BOOL ok = FALSE;
  HRESULT hr;

  hr = CoCreateInstance(&CLSID_WbemLocator, 0, CLSCTX_INPROC_SERVER,
                        &IID_IWbemLocator, (LPVOID *)&pLoc);
  if (FAILED(hr)) goto done;

  BSTR nss = SysAllocString(ns);
  hr = pLoc->lpVtbl->ConnectServer(pLoc, nss, NULL, NULL, 0, 0, 0, 0, &pSvc);
  SysFreeString(nss);
  if (FAILED(hr)) goto done;

  CoSetProxyBlanket((IUnknown *)pSvc, RPC_C_AUTHN_WINNT, RPC_C_AUTHZ_NONE, NULL,
                    RPC_C_AUTHN_LEVEL_CALL, RPC_C_IMP_LEVEL_IMPERSONATE, NULL,
                    EOAC_NONE);

  BSTR lang = SysAllocString(L"WQL");
  BSTR query = SysAllocString(wql);
  hr = pSvc->lpVtbl->ExecQuery(
      pSvc, lang, query, WBEM_FLAG_FORWARD_ONLY | WBEM_FLAG_RETURN_IMMEDIATELY,
      NULL, &pEnum);
  SysFreeString(lang);
  SysFreeString(query);
  if (FAILED(hr)) goto done;

  ULONG n = 0;
  if (SUCCEEDED(pEnum->lpVtbl->Next(pEnum, WBEM_INFINITE, 1, &pObj, &n)) &&
      n > 0) {
    VARIANT v;
    VariantInit(&v);
    if (SUCCEEDED(pObj->lpVtbl->Get(pObj, (BSTR)field, 0, &v, 0, 0)) &&
        v.vt == VT_BSTR && v.bstrVal) {
      wcsncpy_s(dest, destLen, v.bstrVal, destLen - 1);
      ok = TRUE;
    }
    VariantClear(&v);
  }

done:
  if (pObj) pObj->lpVtbl->Release(pObj);
  if (pEnum) pEnum->lpVtbl->Release(pEnum);
  if (pSvc) pSvc->lpVtbl->Release(pSvc);
  if (pLoc) pLoc->lpVtbl->Release(pLoc);
  return ok;
}

/* ── OS version + last update ────────────────────────────────────── */

static void get_os_version(WCHAR *dest, DWORD destLen) {
  WCHAR display[64] = L"";
  WCHAR build[64] = L"";

  HKEY hk;
  if (RegOpenKeyExW(HKEY_LOCAL_MACHINE,
                    L"SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion", 0,
                    KEY_READ, &hk) == ERROR_SUCCESS) {
    DWORD type, bytes;

    bytes = sizeof(display);
    RegQueryValueExW(hk, L"DisplayVersion", NULL, &type, (LPBYTE)display,
                     &bytes);

    bytes = sizeof(build);
    RegQueryValueExW(hk, L"CurrentBuild", NULL, &type, (LPBYTE)build, &bytes);

    /* Agregar UBR (build revision) */
    DWORD ubr = 0, ubrBytes = sizeof(ubr), ubrType;
    if (RegQueryValueExW(hk, L"UBR", NULL, &ubrType, (LPBYTE)&ubr,
                         &ubrBytes) == ERROR_SUCCESS && ubrType == REG_DWORD &&
        ubr > 0) {
      WCHAR tmp[64];
      swprintf_s(tmp, 64, L"%s.%u", build, ubr);
      wcscpy_s(build, 64, tmp);
    }

    RegCloseKey(hk);
  }

  if (display[0] && build[0])
    swprintf_s(dest, destLen, L"%s (Build %s)", display, build);
  else if (build[0])
    swprintf_s(dest, destLen, L"Build %s", build);
  else
    wcscpy_s(dest, destLen, L"N/A");
}

static void get_last_update(WCHAR *dest, DWORD destLen) {
  /* PowerShell Get-HotFix — funciona en Windows 10/11 donde WMI falla */
  WCHAR cmd[] =
      L"powershell.exe -NoProfile -Command "
      L"\"$u = Get-HotFix | Sort-Object InstalledOn -Descending | "
      L"Select-Object -First 1; "
      L"if($u){ "
      L"$d = if($u.InstalledOn){ $u.InstalledOn.ToString('yyyy-MM-dd') }"
      L" else { 'N/A' }; "
      L"Write-Output ($u.HotFixID + '|' + $d) "
      L"} else { Write-Output 'NONE' }\"";

  HANDLE hRead, hWrite;
  SECURITY_ATTRIBUTES sa = {sizeof(sa), NULL, TRUE};
  if (!CreatePipe(&hRead, &hWrite, &sa, 0)) {
    wcscpy_s(dest, destLen, L"N/A");
    return;
  }
  SetHandleInformation(hRead, HANDLE_FLAG_INHERIT, 0);

  STARTUPINFOW si = {sizeof(si)};
  si.dwFlags = STARTF_USESTDHANDLES;
  si.hStdOutput = hWrite;
  si.hStdError = GetStdHandle(STD_ERROR_HANDLE);

  PROCESS_INFORMATION pi = {0};
  BOOL ok = CreateProcessW(NULL, cmd, NULL, NULL, TRUE, CREATE_NO_WINDOW,
                           NULL, NULL, &si, &pi);
  CloseHandle(hWrite);

  if (!ok) {
    CloseHandle(hRead);
    wcscpy_s(dest, destLen, L"N/A");
    return;
  }

  /* Leer stdout (máx 512 bytes) como bytes crudos */
  BYTE raw[512] = {0};
  DWORD n = 0;
  ReadFile(hRead, raw, sizeof(raw) - 1, &n, NULL);
  CloseHandle(hRead);
  WaitForSingleObject(pi.hProcess, 8000);
  CloseHandle(pi.hProcess);
  CloseHandle(pi.hThread);

  if (n == 0) {
    wcscpy_s(dest, destLen, L"N/A");
    return;
  }

  /* Convertir bytes UTF-8 → WCHAR */
  WCHAR buf[512] = L"";
  MultiByteToWideChar(CP_UTF8, 0, (char *)raw, n, buf, 512);
  buf[n] = L'\0';

  /* Limpiar \r\n */
  WCHAR *p = buf;
  while (*p == L' ' || *p == L'\t') p++;
  WCHAR *end = p + wcslen(p);
  while (end > p && (end[-1] == L'\n' || end[-1] == L'\r' || end[-1] == L' '))
    end--;
  *end = L'\0';

  if (wcscmp(p, L"NONE") == 0 || p[0] == L'\0') {
    /* Fallback: Build desde WMI */
    WCHAR build[64] = L"";
    wmi_query_first(L"ROOT\\CIMV2", L"SELECT BuildNumber FROM Win32_OperatingSystem",
                    L"BuildNumber", build, 64);
    if (build[0] && wcscmp(build, L"N/A") != 0)
      swprintf_s(dest, destLen, L"Build %s", build);
    else
      wcscpy_s(dest, destLen, L"N/A");
    return;
  }

  /* Parsear "KB5034441|2025-01-14" */
  WCHAR *sep = wcschr(p, L'|');
  if (sep) {
    *sep = L'\0';
    WCHAR *date = sep + 1;
    while (*date == L' ') date++;
    swprintf_s(dest, destLen, L"%s (%s)", p, date);
  } else {
    swprintf_s(dest, destLen, L"%s", p);
  }
}

/* ── Registry ───────────────────────────────────────────────────── */

static void reg_read(HKEY root, const WCHAR *path, const WCHAR *name,
                     WCHAR *dest, DWORD destLen) {
  HKEY hk;
  if (RegOpenKeyExW(root, path, 0, KEY_READ, &hk) != ERROR_SUCCESS) {
    wcscpy_s(dest, destLen, L"N/A");
    return;
  }
  DWORD type, bytes = destLen * sizeof(WCHAR);
  if (RegQueryValueExW(hk, name, NULL, &type, (LPBYTE)dest, &bytes) !=
          ERROR_SUCCESS ||
      type != REG_SZ)
    wcscpy_s(dest, destLen, L"N/A");
  RegCloseKey(hk);
}

void set_autostart(void) {
  WCHAR exe[MAX_PATH];
  if (!GetModuleFileNameW(NULL, exe, MAX_PATH))
    return;
  HKEY hk;
  if (RegOpenKeyExW(HKEY_CURRENT_USER,
                    L"Software\\Microsoft\\Windows\\CurrentVersion\\Run", 0,
                    KEY_SET_VALUE, &hk) != ERROR_SUCCESS)
    return;
  RegSetValueExW(hk, L"DataScan", 0, REG_SZ, (const BYTE *)exe,
                 (DWORD)((wcslen(exe) + 1) * sizeof(WCHAR)));
  RegCloseKey(hk);
}

/* ── IP / MAC ───────────────────────────────────────────────────── */

static void get_ip_mac(WCHAR *ipBuf, DWORD ipLen, WCHAR *macBuf, DWORD macLen) {
  wcscpy_s(ipBuf, ipLen, L"N/A");
  wcscpy_s(macBuf, macLen, L"N/A");

  SOCKET s = socket(AF_INET, SOCK_DGRAM, 0);
  if (s != INVALID_SOCKET) {
    struct sockaddr_in srv = {0};
    srv.sin_family = AF_INET;
    srv.sin_port = htons(80);
    srv.sin_addr.s_addr = inet_addr("8.8.8.8");
    if (connect(s, (struct sockaddr *)&srv, sizeof(srv)) == 0) {
      struct sockaddr_in me = {0};
      int l = sizeof(me);
      if (getsockname(s, (struct sockaddr *)&me, &l) == 0)
        swprintf_s(ipBuf, ipLen, L"%hs", inet_ntoa(me.sin_addr));
    }
    closesocket(s);
  }

  IP_ADAPTER_INFO *buf = NULL;
  ULONG bufLen = 0;
  GetAdaptersInfo(NULL, &bufLen);
  buf = (IP_ADAPTER_INFO *)malloc(bufLen);
  if (buf && GetAdaptersInfo(buf, &bufLen) == NO_ERROR) {
    IP_ADAPTER_INFO *a = buf;
    while (a) {
      if (a->AddressLength == 6) {
        swprintf_s(macBuf, macLen, L"%02X-%02X-%02X-%02X-%02X-%02X",
                   a->Address[0], a->Address[1], a->Address[2], a->Address[3],
                   a->Address[4], a->Address[5]);
        break;
      }
      a = a->Next;
    }
  }
  free(buf);
}

/* ── Gather all ─────────────────────────────────────────────────── */

void gather_hardware(HardwareInfo *info) {
  DWORD sz;

  sz = 256;
  GetComputerNameW(info->hostname, &sz);
  sz = 256;
  GetUserNameW(info->username, &sz);

  WCHAR dom[256] = L"N/A";
  DWORD domSz = 256;
  GetEnvironmentVariableW(L"USERDOMAIN", dom, domSz);
  wcscpy_s(info->domain, 256, dom[0] ? dom : L"N/A");

  get_ip_mac(info->ip, 64, info->mac, 64);

  reg_read(HKEY_LOCAL_MACHINE, L"HARDWARE\\DESCRIPTION\\System\\BIOS",
           L"SystemManufacturer", info->brand, 256);
  reg_read(HKEY_LOCAL_MACHINE, L"HARDWARE\\DESCRIPTION\\System\\BIOS",
           L"SystemProductName", info->model, 256);

  wmi_query_first(L"ROOT\\CIMV2", L"SELECT SerialNumber FROM Win32_BIOS",
                  L"SerialNumber", info->serial, 256);

  get_os_version(info->osVersion, 256);
  get_last_update(info->lastUpdate, 256);
}

/* ── Telemetría: CPU / RAM / disco ───────────────────────────────── */

void gather_telemetry(Telemetria *t) {
  t->cpu_pct = t->ram_pct = t->disk_pct = 0.0;

  /* CPU: PDH, dos muestras a 1 s para no reportar un pico inicial de 0 % */
  PDH_HQUERY q = 0;
  PDH_HCOUNTER c = 0;
  if (PdhOpenQueryW(NULL, 0, &q) == ERROR_SUCCESS &&
      PdhAddEnglishCounterW(q, L"\\Processor(_Total)\\% Processor Time", 0, &c) ==
          ERROR_SUCCESS) {
    PdhCollectQueryData(q);
    Sleep(1000);
    if (PdhCollectQueryData(q) == ERROR_SUCCESS) {
      PDH_FMT_COUNTERVALUE v;
      DWORD status = PdhGetFormattedCounterValue(c, PDH_FMT_DOUBLE, NULL, &v);
      if (status == ERROR_SUCCESS)
        t->cpu_pct = v.doubleValue;
    }
    PdhCloseQuery(q);
  }

  /* RAM: memoria física en uso */
  MEMORYSTATUSEX ms;
  ms.dwLength = sizeof(ms);
  if (GlobalMemoryStatusEx(&ms) && ms.ullTotalPhys > 0)
    t->ram_pct = 100.0 - (100.0 * (double)ms.ullAvailPhys / (double)ms.ullTotalPhys);

  /* Disco: porcentaje en uso sumando las unidades fijas locales */
  DWORD drives = GetLogicalDrives();
  ULARGE_INTEGER tot = {0}, fre = {0};
  for (WCHAR d = L'A'; d <= L'Z'; d++) {
    if (!(drives & (1u << (d - L'A'))))
      continue;
    WCHAR root[4] = {d, L':', L'\\', 0};
    if (GetDriveTypeW(root) != DRIVE_FIXED)
      continue;
    ULARGE_INTEGER freeB, totalB;
    if (GetDiskFreeSpaceExW(root, &freeB, &totalB, NULL) && totalB.QuadPart > 0) {
      tot.QuadPart += totalB.QuadPart;
      fre.QuadPart += freeB.QuadPart;
    }
  }
  if (tot.QuadPart > 0)
    t->disk_pct = 100.0 - (100.0 * (double)fre.QuadPart / (double)tot.QuadPart);
}

/* ── Inventario de software ──────────────────────────────────────── */

#define NOAUT_MAX 64
#define NOAUT_LEN 63

static char g_noauth[NOAUT_MAX][NOAUT_LEN + 1];
static int g_noauth_count = 0;

/* Lista opcional "noautorizado.txt" junto al .exe: una subcadena de nombre
   por línea (minúsculas). Si no existe, todo el software se considera
   autorizado. ponytail: lista local; el servidor podrá mandarla luego. */
static void cargar_no_autorizado(void) {
  g_noauth_count = 0;
  WCHAR exe[MAX_PATH] = L"";
  if (!GetModuleFileNameW(NULL, exe, MAX_PATH))
    return;
  WCHAR *slash = wcsrchr(exe, L'\\');
  if (!slash)
    return;
  *slash = L'\0';
  WCHAR path[MAX_PATH];
  swprintf_s(path, MAX_PATH, L"%s\\noautorizado.txt", exe);

  FILE *f = _wfopen(path, L"r");
  if (!f)
    return;
  char line[128];
  while (fgets(line, sizeof(line), f) && g_noauth_count < NOAUT_MAX) {
    line[strcspn(line, "\r\n")] = '\0';
    char *p = line;
    while (*p == ' ')
      p++;
    if (!*p)
      continue;
    for (char *q = p; *q; q++)
      *q = (char)tolower((unsigned char)*q);
    size_t n = strlen(p);
    if (n > NOAUT_LEN)
      n = NOAUT_LEN;
    memcpy(g_noauth[g_noauth_count], p, n);
    g_noauth[g_noauth_count][n] = '\0';
    g_noauth_count++;
  }
  fclose(f);
}

static BOOL es_no_autorizado(const WCHAR *nombre) {
  if (g_noauth_count == 0)
    return FALSE;
  char utf8[512];
  if (WideCharToMultiByte(CP_UTF8, 0, nombre, -1, utf8, sizeof(utf8), NULL, NULL) <= 0)
    return FALSE;
  for (char *p = utf8; *p; p++)
    *p = (char)tolower((unsigned char)*p);
  for (int i = 0; i < g_noauth_count; i++)
    if (strstr(utf8, g_noauth[i]))
      return TRUE;
  return FALSE;
}

static BOOL es_antivirus(const WCHAR *nombre) {
  static const WCHAR *av[] = {
      L"defender",   L"mcafee",    L"norton",    L"symantec",  L"eset",
      L"kaspersky",  L"avast",     L"avira",     L"bitdefender", L"sophos",
      L"webroot",    L"trend micro", L"malwarebytes", L"sentinelone",
      L"crowdstrike"};
  WCHAR down[256];
  wcscpy_s(down, 256, nombre);
  for (WCHAR *p = down; *p; p++)
    *p = (WCHAR)towlower(*p);
  for (size_t i = 0; i < sizeof(av) / sizeof(av[0]); i++)
    if (wcsstr(down, av[i]))
      return TRUE;
  return FALSE;
}

static void reg_value(HKEY hk, const WCHAR *name, WCHAR *dest, DWORD destLen) {
  wcscpy_s(dest, destLen, L"");
  DWORD type, bytes = destLen * sizeof(WCHAR);
  if (RegQueryValueExW(hk, name, NULL, &type, (LPBYTE)dest, &bytes) !=
          ERROR_SUCCESS ||
      type != REG_SZ)
    wcscpy_s(dest, destLen, L"");
}

static void inv_push(Inventario *inv, const WCHAR *nombre, const WCHAR *ver,
                     BOOL esAv, BOOL autorizado) {
  if (inv->count == inv->cap) {
    int ncap = inv->cap ? inv->cap * 2 : 32;
    SoftwareItem *ni =
        (SoftwareItem *)realloc(inv->items, (size_t)ncap * sizeof(SoftwareItem));
    if (!ni)
      return;
    inv->items = ni;
    inv->cap = ncap;
  }
  SoftwareItem *it = &inv->items[inv->count++];
  wcscpy_s(it->nombre, 256, nombre);
  wcscpy_s(it->version, 128, ver[0] ? ver : L"-");
  it->antivirus = esAv;
  it->autorizado = autorizado;
}

static void enum_uninstall(HKEY root, const WCHAR *path, Inventario *inv) {
  HKEY hk;
  if (RegOpenKeyExW(root, path, 0, KEY_READ, &hk) != ERROR_SUCCESS)
    return;
  for (DWORD i = 0;; i++) {
    WCHAR sub[256];
    DWORD len = 256;
    if (RegEnumKeyExW(hk, i, sub, &len, NULL, NULL, NULL, NULL) != ERROR_SUCCESS)
      break;
    HKEY sk;
    if (RegOpenKeyExW(hk, sub, 0, KEY_READ, &sk) != ERROR_SUCCESS)
      continue;
    WCHAR name[256] = L"", ver[128] = L"";
    reg_value(sk, L"DisplayName", name, 256);
    reg_value(sk, L"DisplayVersion", ver, 128);
    RegCloseKey(sk);
    if (name[0] == L'\0')
      continue;
    inv_push(inv, name, ver, es_antivirus(name), !es_no_autorizado(name));
  }
  RegCloseKey(hk);
}

void gather_software(Inventario *inv) {
  memset(inv, 0, sizeof(*inv));
  cargar_no_autorizado();

  /* Estado del antivirus: WMI SecurityCenter2 (Windows 8.1/10/11). */
  WCHAR avName[128] = L"";
  BOOL ok = wmi_query_first(L"ROOT\\SecurityCenter2",
                            L"SELECT displayName FROM AntiVirusProduct",
                            L"displayName", avName, 128);
  inv->antivirusActivo = (ok && wcscmp(avName, L"N/A") != 0);

  enum_uninstall(HKEY_LOCAL_MACHINE,
                 L"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall", inv);
  enum_uninstall(HKEY_LOCAL_MACHINE,
                 L"SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall",
                 inv);
  enum_uninstall(HKEY_CURRENT_USER,
                 L"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall", inv);
}

void free_inventario(Inventario *inv) {
  free(inv->items);
  inv->items = NULL;
  inv->count = inv->cap = 0;
}
