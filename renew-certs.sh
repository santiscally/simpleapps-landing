#!/bin/bash
# Renovación MANUAL del certificado SSL.
#
# Normalmente NO hace falta correr esto: la renovación es automática vía
# certbot.timer (systemd), que ejecuta los hooks en /etc/letsencrypt/renewal-hooks/:
#   pre/    -> baja el contenedor (libera el puerto 80 para el challenge standalone)
#   deploy/ -> copia los certs renovados a /home/simpleapps-landing/ssl/
#   post/   -> vuelve a levantar el contenedor
#
# 'certbot renew' sólo renueva si faltan <30 días para el vencimiento.
# Para forzar una renovación (ej: cert vencido), agregá --force-renewal.

certbot renew "$@"
