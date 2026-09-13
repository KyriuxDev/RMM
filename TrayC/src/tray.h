/*
 * tray.h — System tray icon, context menu, window procedure.
 */
#ifndef TRAY_H
#define TRAY_H

#include "common.h"

void tray_add(HINSTANCE hInst);
void tray_remove(void);
void show_context_menu(void);
void show_datos(void);
void do_generate_qr(void);
LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);

#endif /* TRAY_H */
