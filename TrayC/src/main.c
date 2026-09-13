/*
 * main.c — Entry point: singleton, COM, Winsock, autostart, tray.
 */
#include <winsock2.h>
#include <windows.h>

#include "common.h"
#include "hwinfo.h"
#include "tray.h"

/* ── Globals ─────────────────────────────────────────────────────── */
HWND g_hWnd;
HANDLE g_hMutex = NULL;
NOTIFYICONDATA g_nid;
BOOL g_comOk = FALSE;
HardwareInfo g_info;

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
                   LPSTR lpCmdLine, int nCmdShow) {
  (void)hPrevInstance;
  (void)lpCmdLine;
  (void)nCmdShow;

  /* Singleton */
  g_hMutex = CreateMutexW(NULL, TRUE, L"DataScan_Mutex");
  if (GetLastError() == ERROR_ALREADY_EXISTS) {
    if (g_hMutex)
      CloseHandle(g_hMutex);
    return 0;
  }

  /* COM */
  com_init();

  /* Winsock — ponytail: init once, used by get_ip_mac */
  WSADATA wsa;
  WSAStartup(MAKEWORD(2, 2), &wsa);

  /* Autoarranque */
  set_autostart();

  /* Hardware info */
  gather_hardware(&g_info);

  /* Ventana oculta (solo para mensajes) */
  WNDCLASSW wc = {0};
  wc.lpfnWndProc = WndProc;
  wc.hInstance = hInstance;
  wc.lpszClassName = L"DataScan_Class";
  RegisterClassW(&wc);

  g_hWnd = CreateWindowW(wc.lpszClassName, L"DataScan", 0, 0, 0, 0, 0,
                         NULL, NULL, hInstance, NULL);
  if (!g_hWnd)
    goto cleanup;

  /* Tray */
  tray_add(hInstance);

  /* Hotkeys */
  RegisterHotKey(g_hWnd, HK_DATOS, MOD_CONTROL | MOD_ALT | MOD_NOREPEAT, 'I');
  RegisterHotKey(g_hWnd, HK_QR, MOD_ALT | MOD_SHIFT | MOD_NOREPEAT, 'Q');

  /* Message loop */
  MSG msg;
  while (GetMessage(&msg, NULL, 0, 0) > 0) {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }

cleanup:
  UnregisterHotKey(g_hWnd, HK_DATOS);
  UnregisterHotKey(g_hWnd, HK_QR);
  WSACleanup();
  com_deinit();
  if (g_hMutex)
    CloseHandle(g_hMutex);
  return 0;
}
