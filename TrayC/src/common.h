/*
 * common.h — Types, constants, and extern globals shared across modules.
 */
#ifndef COMMON_H
#define COMMON_H

#ifndef UNICODE
#define UNICODE
#endif
#ifndef _UNICODE
#define _UNICODE
#endif

#include <winsock2.h>
#include <windows.h>

/* ── Menu / Tray IDs ──────────────────────────────────────────────── */
#define WM_TRAYICON (WM_USER + 1)
#define ID_TRAY_DATOS 1001
#define ID_TRAY_QR    1002
#define ID_TRAY_SALIR 1003

/* ── Hotkeys ──────────────────────────────────────────────────────── */
#define HK_DATOS 2001  /* Ctrl+Alt+I */
#define HK_QR    2002  /* Alt+Shift+Q */

/* ── QR constants ─────────────────────────────────────────────────── */
#define QR_PIXEL_SIZE 6
#define QR_BORDER     4

/* ── Hardware info ────────────────────────────────────────────────── */
typedef struct {
  WCHAR hostname[256];
  WCHAR username[256];
  WCHAR domain[256];
  WCHAR ip[64];
  WCHAR mac[64];
  WCHAR brand[256];
  WCHAR model[256];
  WCHAR serial[256];
  WCHAR osVersion[256];
  WCHAR lastUpdate[256];
} HardwareInfo;

/* ── Telemetría (uso de recursos) ────────────────────────────────── */
typedef struct {
  double cpu_pct;
  double ram_pct;
  double disk_pct;
} Telemetria;

/* ── Inventario de software ──────────────────────────────────────── */
typedef struct {
  WCHAR nombre[256];
  WCHAR version[128];
  BOOL  antivirus;    /* coincide con un visor conocido de antivirus */
  BOOL  autorizado;   /* FALSE si aparece en la lista "noautorizado.txt" */
} SoftwareItem;

typedef struct {
  SoftwareItem *items;
  int count;
  int cap;
  BOOL antivirusActivo; /* detectado en WMI SecurityCenter2 */
} Inventario;

/* ── Globals (defined in main.c) ─────────────────────────────────── */
extern HWND g_hWnd;
extern HANDLE g_hMutex;
extern NOTIFYICONDATA g_nid;
extern BOOL g_comOk;
extern HardwareInfo g_info;

#endif /* COMMON_H */
