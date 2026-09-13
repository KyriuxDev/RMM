/*
 * qr_gen.c — QR → PNG (encrypt → encode → render → write).
 */
#include "qr_gen.h"

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>

#include "../deps/lodepng.h"
#include "../deps/qrcodegen.h"
#include "crypto.h"

BOOL generate_qr_png(const HardwareInfo *info, WCHAR *outPath, DWORD pathLen) {
  /* 1. Formatear datos de inventario */
  char plain[1024];
  snprintf(plain, sizeof(plain),
           "DATASCAN\nHOST: %ls\nUSER: %ls\nIP: %ls | MAC: %ls\nSN: %ls "
           "| MOD: %ls\nWIN: %ls\nUPD: %ls",
           info->hostname, info->username, info->ip, info->mac, info->serial,
           info->model, info->osVersion, info->lastUpdate);

  /* 2. Cifrar */
  char *cipherHex = aes_cbc_encrypt_hex(plain, strlen(plain));
  if (!cipherHex)
    return FALSE;

  /* 3. QR */
  uint8_t qrBuf[qrcodegen_BUFFER_LEN_MAX];
  uint8_t tmp[qrcodegen_BUFFER_LEN_MAX];

  BOOL ok = qrcodegen_encodeText(cipherHex, tmp, qrBuf, qrcodegen_Ecc_MEDIUM,
                                 qrcodegen_VERSION_MIN, qrcodegen_VERSION_MAX,
                                 qrcodegen_Mask_AUTO, TRUE);
  free(cipherHex);
  if (!ok)
    return FALSE;

  int qrSize = qrcodegen_getSize(qrBuf);
  int imgSize = (qrSize + 2 * QR_BORDER) * QR_PIXEL_SIZE;

  /* 4. Render RGBA */
  uint8_t *rgba = (uint8_t *)calloc(imgSize * imgSize * 4, 1);
  if (!rgba)
    return FALSE;

  memset(rgba, 0xFF, imgSize * imgSize * 4);

  for (int row = 0; row < qrSize; row++) {
    for (int col = 0; col < qrSize; col++) {
      if (qrcodegen_getModule(qrBuf, col, row)) {
        int px = (col + QR_BORDER) * QR_PIXEL_SIZE;
        int py = (row + QR_BORDER) * QR_PIXEL_SIZE;
        for (int dy = 0; dy < QR_PIXEL_SIZE; dy++) {
          for (int dx = 0; dx < QR_PIXEL_SIZE; dx++) {
            int idx = ((py + dy) * imgSize + (px + dx)) * 4;
            rgba[idx] = rgba[idx + 1] = rgba[idx + 2] = 0;
            rgba[idx + 3] = 255;
          }
        }
      }
    }
  }

  /* Ruta: %TEMP%\DataScan_<hostname>.png */
  WCHAR tmp2[MAX_PATH];
  GetTempPathW(MAX_PATH, tmp2);
  swprintf_s(outPath, pathLen, L"%sDataScan_%s.png", tmp2, info->hostname);

  char pathA[MAX_PATH];
  WideCharToMultiByte(CP_ACP, 0, outPath, -1, pathA, MAX_PATH, NULL, NULL);

  unsigned err = lodepng_encode32_file(pathA, rgba, imgSize, imgSize);
  free(rgba);
  return (err == 0);
}
