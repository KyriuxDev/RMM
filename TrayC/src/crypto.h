/*
 * crypto.h — AES-128-CBC encryption via Windows CryptoAPI.
 */
#ifndef CRYPTO_H
#define CRYPTO_H

#include <stddef.h>

/*
 * Encrypts `plain` with AES-128-CBC (PKCS#7 padding).
 * Returns a hex string: IV (16 bytes) + ciphertext, uppercase.
 * Caller must free() the result. Returns NULL on failure.
 */
char *aes_cbc_encrypt_hex(const char *plain, size_t plainLen);

#endif /* CRYPTO_H */
