#!/bin/bash
# Instala/reinstala toda la infraestructura de servido de simpleapps.com.ar.
# Es idempotente: se puede correr las veces que sea.
#
#   sudo /home/simpleapps-landing/deploy/install.sh
set -euo pipefail

REPO_DIR=/home/simpleapps-landing
D="$REPO_DIR/deploy"

[[ $EUID -eq 0 ]] || { echo "Correr como root"; exit 1; }

step() { echo; echo "==> $*"; }

step "Instalando scripts en /usr/local/bin"
install -m 0755 "$D/simpleapps-deploy"      /usr/local/bin/simpleapps-deploy
install -m 0755 "$D/simpleapps-healthcheck" /usr/local/bin/simpleapps-healthcheck

step "Creando webroot /var/www/simpleapps.com.ar y /var/www/certbot"
mkdir -p /var/www/simpleapps.com.ar /var/www/certbot
chown -R www-data:www-data /var/www/simpleapps.com.ar /var/www/certbot

step "Instalando vhost de nginx"
install -m 0644 "$D/nginx/simpleapps.com.ar" /etc/nginx/sites-available/simpleapps.com.ar
ln -sfn /etc/nginx/sites-available/simpleapps.com.ar /etc/nginx/sites-enabled/simpleapps.com.ar

step "Desactivando el sitio 'default' de nginx (es el que muestra 'Welcome to nginx!')"
rm -f /etc/nginx/sites-enabled/default

step "Instalando units de systemd"
install -m 0644 "$D/systemd/simpleapps-site.service"         /etc/systemd/system/
install -m 0644 "$D/systemd/simpleapps-healthcheck.service"  /etc/systemd/system/
install -m 0644 "$D/systemd/simpleapps-healthcheck.timer"    /etc/systemd/system/
systemctl daemon-reload
systemctl enable nginx
systemctl enable simpleapps-site.service
systemctl enable --now simpleapps-healthcheck.timer

step "Instalando hook de apt (repara el sitio tras cada actualizacion de paquetes)"
install -m 0644 "$D/apt/99-simpleapps-restore" /etc/apt/apt.conf.d/99-simpleapps-restore

step "Configurando certbot para renovar sin parar nginx (authenticator webroot)"
install -m 0755 "$D/certbot/reload-nginx.sh" /etc/letsencrypt/renewal-hooks/deploy/10-reload-nginx.sh
# Los hooks viejos hacian docker-compose down/up: con nginx nativo la renovacion
# standalone fallaba (puerto 80 ocupado) y el 'up' peleaba por los puertos 80/443.
rm -f /etc/letsencrypt/renewal-hooks/pre/01-stop-docker.sh
rm -f /etc/letsencrypt/renewal-hooks/post/01-start-docker.sh
rm -f /etc/letsencrypt/renewal-hooks/deploy/01-copy-certs.sh
RENEWAL_CONF=/etc/letsencrypt/renewal/simpleapps.com.ar.conf
if [[ -f "$RENEWAL_CONF" ]]; then
    cp -n "$RENEWAL_CONF" "$RENEWAL_CONF.bak-precambio" 2>/dev/null || true
    sed -i 's|^authenticator = .*|authenticator = webroot|' "$RENEWAL_CONF"
    grep -q '^webroot_path' "$RENEWAL_CONF" || sed -i '/^authenticator = webroot/a webroot_path = /var/www/certbot,' "$RENEWAL_CONF"
    grep -q '^\[\[webroot_map\]\]' "$RENEWAL_CONF" || cat >> "$RENEWAL_CONF" <<'EOF'

[[webroot_map]]
simpleapps.com.ar = /var/www/certbot
www.simpleapps.com.ar = /var/www/certbot
EOF
fi
systemctl enable certbot.timer

step "Publicando el sitio"
/usr/local/bin/simpleapps-deploy

step "Verificando"
/usr/local/bin/simpleapps-healthcheck

echo
echo "Instalacion completa."
