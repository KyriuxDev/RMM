/*
 * tray.c — System tray, context menu, notifications, WndProc.
 */
#include "tray.h"

#include <shellapi.h>
#include <stdio.h>
#include <windows.h>

#include "hwinfo.h"
#include "qr_gen.h"

/* ── Helpers ─────────────────────────────────────────────────────── */

static void show_msgbox(const WCHAR *title, const WCHAR *msg) {
  MessageBoxW(g_hWnd, msg, title, MB_OK | MB_ICONINFORMATION);
}

/* ── Public ──────────────────────────────────────────────────────── */

void show_datos(void) {
  Telemetria tm;
  gather_telemetry(&tm);
  Inventario inv;
  gather_software(&inv);
  WCHAR buf[4096];
  swprintf_s(buf, 4096,
             L"Equipo     : %s\n"
             L"Usuario    : %s\n"
             L"Dominio    : %s\n"
             L"IP         : %s\n"
             L"MAC        : %s\n"
             L"Marca      : %s\n"
             L"Modelo     : %s\n"
             L"Serie      : %s\n"
             L"Windows    : %s\n"
             L"Ult. Update: %s\n"
             L"CPU        : %.1f%%\n"
             L"RAM        : %.1f%%\n"
             L"Disco      : %.1f%%\n"
             L"Antivirus  : %s\n"
             L"Software   : %d apps",
             g_info.hostname, g_info.username, g_info.domain, g_info.ip,
             g_info.mac, g_info.brand, g_info.model, g_info.serial,
             g_info.osVersion, g_info.lastUpdate,
             tm.cpu_pct, tm.ram_pct, tm.disk_pct,
             inv.antivirusActivo ? L"Activo" : L"No detectado", inv.count);
  free_inventario(&inv);
  show_msgbox(L"DataScan — Datos del Equipo", buf);
}

void do_generate_qr(void) {
  WCHAR pngPath[MAX_PATH];
  if (!generate_qr_png(&g_info, pngPath, MAX_PATH)) {
    show_msgbox(L"Error", L"No se pudo generar el código QR.");
    return;
  }
  ShellExecuteW(NULL, L"open", pngPath, NULL, NULL, SW_SHOWNORMAL);
}

void tray_add(HINSTANCE hInst) {
  g_nid.cbSize = sizeof(g_nid);
  g_nid.hWnd = g_hWnd;
  g_nid.uID = 1;
  g_nid.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP;
  g_nid.uCallbackMessage = WM_TRAYICON;
  g_nid.hIcon = (HICON)LoadImageW(hInst, MAKEINTRESOURCEW(1), IMAGE_ICON, 0, 0,
                                  LR_DEFAULTSIZE);
  if (!g_nid.hIcon)
    g_nid.hIcon = LoadIconW(NULL, IDI_APPLICATION);
  wcscpy_s(g_nid.szTip, sizeof(g_nid.szTip) / sizeof(WCHAR),
           L"DataScan — Datos del Equipo");
  Shell_NotifyIconW(NIM_ADD, &g_nid);
}

void tray_remove(void) { Shell_NotifyIconW(NIM_DELETE, &g_nid); }

void show_context_menu(void) {
  POINT pt;
  GetCursorPos(&pt);
  HMENU hMenu = CreatePopupMenu();
  AppendMenuW(hMenu, MF_STRING, ID_TRAY_DATOS, L"Ver Datos del Equipo");
  AppendMenuW(hMenu, MF_STRING, ID_TRAY_QR, L"Generar Código QR");
  AppendMenuW(hMenu, MF_SEPARATOR, 0, NULL);
  AppendMenuW(hMenu, MF_STRING, ID_TRAY_SALIR, L"Salir");
  SetForegroundWindow(g_hWnd);
  TrackPopupMenu(hMenu, TPM_RIGHTBUTTON, pt.x, pt.y, 0, g_hWnd, NULL);
  DestroyMenu(hMenu);
}

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
  switch (msg) {
  case WM_TRAYICON:
    if (lParam == WM_RBUTTONUP || lParam == WM_LBUTTONUP)
      show_context_menu();
    break;

  case WM_COMMAND:
    switch (LOWORD(wParam)) {
    case ID_TRAY_DATOS:
      show_datos();
      break;
    case ID_TRAY_QR:
      do_generate_qr();
      break;
    case ID_TRAY_SALIR:
      DestroyWindow(hwnd);
      break;
    }
    break;

  case WM_HOTKEY:
    switch ((int)wParam) {
    case HK_DATOS:
      show_datos();
      break;
    case HK_QR:
      do_generate_qr();
      break;
    }
    break;

  case WM_DESTROY:
    tray_remove();
    PostQuitMessage(0);
    break;

  default:
    return DefWindowProcW(hwnd, msg, wParam, lParam);
  }
  return 0;
}
