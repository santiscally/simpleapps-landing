#!/bin/bash
# Renovación MANUAL del certificado SSL.
#
# Normalmente NO hace falta correr esto: la renovación es automática vía
# certbot.timer (systemd). El challenge usa el authenticator 'webroot' contra
# /var/www/certbot, servido por el nginx nativo, así que NO hay que parar nada.
# El hook deploy/10-reload-nginx.sh recarga nginx cuando el cert se renueva.
#
# 'certbot renew' sólo renueva si faltan <30 días para el vencimiento.
# Para forzar una renovación (ej: cert vencido), agregá --force-renewal.

certbot renew "$@"
