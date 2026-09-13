/*
 * qr_gen.h — QR code generation and PNG output.
 */
#ifndef QR_GEN_H
#define QR_GEN_H

#include "common.h"

/*
 * Generates a QR PNG from hardware info.
 * The QR data is AES-128-CBC encrypted.
 * Output path written to outPath. Returns TRUE on success.
 */
BOOL generate_qr_png(const HardwareInfo *info, WCHAR *outPath, DWORD pathLen);

#endif /* QR_GEN_H */
