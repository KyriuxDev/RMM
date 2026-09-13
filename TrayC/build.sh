#!/usr/bin/env bash
# build.sh — Compila y firma DataScan.exe desde Debian con mingw
# Uso: chmod +x build.sh && ./build.sh

set -e

# ── Config ─────────────────────────────────────────────────────────
CROSS=x86_64-w64-mingw32-gcc
WINDRES=x86_64-w64-mingw32-windres
CN="Sistemas IMSS Sur Oaxaca"
O="Instituto Mexicano del Seguro Social"
OU="Delegacion Oaxaca"
PASSWORD="B1N4R10$"
# ───────────────────────────────────────────────────────────────────

echo "=== [1/5] Verificando herramientas ==="
for cmd in "$CROSS" "$WINDRES" osslsigncode openssl; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Instalando dependencias..."
        sudo apt-get update -qq
        sudo apt-get install -y gcc-mingw-w64-x86-64 osslsigncode
        break
    fi
done
echo "OK: $($CROSS --version | head -1)"

echo ""
echo "=== [2/5] Descargando dependencias ==="
mkdir -p deps

if [ ! -f deps/qrcodegen.h ]; then
    echo "Descargando nayuki QR-Code-generator..."
    curl -s -o deps/qrcodegen.h https://raw.githubusercontent.com/nayuki/QR-Code-generator/master/c/qrcodegen.h
    curl -s -o deps/qrcodegen.c https://raw.githubusercontent.com/nayuki/QR-Code-generator/master/c/qrcodegen.c
else
    echo "  qrcodegen ya presente"
fi

if [ ! -f deps/lodepng.h ]; then
    echo "Descargando LodePNG..."
    curl -s -o deps/lodepng.h https://raw.githubusercontent.com/lvandeve/lodepng/master/lodepng.h
    curl -L -o deps/lodepng.c https://raw.githubusercontent.com/lvandeve/lodepng/master/lodepng.cpp
else
    echo "  lodepng ya presente"
fi

echo ""
echo "=== [3/5] Compilando ==="
make

echo ""
echo "=== [4/5] Generando certificado de firma ==="
mkdir -p certs

if [ ! -f certs/imss_codesign.pfx ]; then
    cat > certs/codesign.cnf << EOF
[req]
default_bits       = 4096
prompt             = no
default_md         = sha256
distinguished_name = dn
x509_extensions    = v3_codesign

[dn]
CN = ${CN}
O  = ${O}
OU = ${OU}
C  = MX

[v3_codesign]
basicConstraints       = critical, CA:FALSE
keyUsage                = critical, digitalSignature
extendedKeyUsage        = critical, codeSigning
subjectKeyIdentifier    = hash
EOF

    openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 \
        -keyout certs/imss_codesign.key \
        -out certs/imss_codesign.crt \
        -config certs/codesign.cnf \
        -passout pass:"${PASSWORD}" \
        -nodes

    openssl pkcs12 -export \
        -out certs/imss_codesign.pfx \
        -inkey certs/imss_codesign.key \
        -in certs/imss_codesign.crt \
        -passin pass:"${PASSWORD}" \
        -passout pass:"${PASSWORD}"

    echo "  Certificado generado"
else
    echo "  Certificado ya existe"
fi

echo ""
echo "=== [5/5] Firmando DataScan.exe ==="
rm -f DataScan_signed.exe
osslsigncode sign \
    -pkcs12 certs/imss_codesign.pfx \
    -pass "${PASSWORD}" \
    -n "${CN}" \
    -i "https://imss.gob.mx" \
    -in DataScan.exe \
    -out DataScan_signed.exe

osslsigncode verify -in DataScan_signed.exe || true

echo ""
echo "=== LISTO ==="
echo "  DataScan_signed.exe — listo para copiar a Windows"
echo "  certs/imss_codesign.crt — instalar en los equipos destino (GPO)"
