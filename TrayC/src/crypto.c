/*
 * crypto.c — AES-128-CBC via Windows CryptoAPI.
 *
 * IV aleatoria prepended al ciphertext, salida en HEX mayúsculas.
 * ponytail: ~170 líneas de AES manual → 40 líneas con API del SO.
 */
#include "crypto.h"

#include <stdlib.h>
#include <string.h>
#include <windows.h>

#define AES_KEY "DATASCAN_QR_2026" /* 16 bytes = AES-128 */

char *aes_cbc_encrypt_hex(const char *plain, size_t plainLen) {
  HCRYPTPROV hProv = 0;
  HCRYPTKEY hKey = 0;
  char *hex = NULL;

  if (!CryptAcquireContextW(&hProv, NULL, NULL, PROV_RSA_AES,
                            CRYPT_VERIFYCONTEXT))
    return NULL;

  struct {
    BLOBHEADER hdr;
    DWORD dwKeySize;
    BYTE keyData[16];
  } keyBlob = {{PLAINTEXTKEYBLOB, CUR_BLOB_VERSION, 0, CALG_AES_128}, 16, {0}};
  memcpy(keyBlob.keyData, AES_KEY, 16);

  if (!CryptImportKey(hProv, (BYTE *)&keyBlob, sizeof(keyBlob), 0, 0, &hKey))
    goto done;

  BYTE iv[16];
  if (!CryptGenRandom(hProv, 16, iv))
    goto done;

  if (!CryptSetKeyParam(hKey, KP_IV, iv, 0))
    goto done;

  DWORD bufLen = (DWORD)plainLen + 16;
  BYTE *buf = (BYTE *)malloc(bufLen);
  if (!buf) goto done;
  memcpy(buf, plain, plainLen);

  DWORD outLen = (DWORD)plainLen;
  if (!CryptEncrypt(hKey, 0, TRUE, 0, buf, &outLen, bufLen)) {
    free(buf);
    goto done;
  }

  size_t hexLen = (16 + outLen) * 2 + 1;
  hex = (char *)malloc(hexLen);
  if (!hex) { free(buf); goto done; }

  static const char hx[] = "0123456789ABCDEF";
  int pos = 0;
  for (int i = 0; i < 16; i++) {
    hex[pos++] = hx[iv[i] >> 4];
    hex[pos++] = hx[iv[i] & 0xf];
  }
  for (DWORD i = 0; i < outLen; i++) {
    hex[pos++] = hx[buf[i] >> 4];
    hex[pos++] = hx[buf[i] & 0xf];
  }
  hex[pos] = '\0';
  free(buf);

done:
  if (hKey) CryptDestroyKey(hKey);
  if (hProv) CryptReleaseContext(hProv, 0);
  return hex;
}
