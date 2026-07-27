#!/bin/bash
# deploy hook de certbot: se ejecuta solo cuando el certificado se renovo de verdad.
# Recarga el nginx NATIVO para que tome el certificado nuevo.
set -euo pipefail
if nginx -t 2>/dev/null; then
    systemctl reload nginx
    logger -t simpleapps-certbot "certificado renovado — nginx recargado"
else
    logger -t simpleapps-certbot "ERROR: certificado renovado pero 'nginx -t' falla, no recargue"
    exit 1
fi
