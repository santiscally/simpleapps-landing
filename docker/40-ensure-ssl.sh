#!/bin/sh
# Garantiza que existan certificados SSL antes de que nginx arranque.
#
# En PRODUCCIÓN: montá los certificados válidos (fullchain.pem + privkey.pem)
# en /etc/nginx/ssl vía el volumen ./ssl del docker-compose. Si están, se usan.
#
# En LOCAL / sin certificados: se genera uno autofirmado de respaldo para que
# el contenedor arranque igual (el navegador mostrará advertencia en HTTPS).
set -e

SSL_DIR=/etc/nginx/ssl
mkdir -p "$SSL_DIR"

if [ -f "$SSL_DIR/fullchain.pem" ] && [ -f "$SSL_DIR/privkey.pem" ]; then
  echo "[ensure-ssl] Certificados encontrados en $SSL_DIR; se usan los montados."
  exit 0
fi

echo "[ensure-ssl] No hay certificados en $SSL_DIR; generando autofirmado de respaldo."
openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout "$SSL_DIR/privkey.pem" \
  -out "$SSL_DIR/fullchain.pem" \
  -subj "/CN=simpleapps.com.ar" \
  -addext "subjectAltName=DNS:simpleapps.com.ar,DNS:www.simpleapps.com.ar,DNS:localhost" \
  >/dev/null 2>&1
echo "[ensure-ssl] Certificado autofirmado generado."
