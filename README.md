# Simple Apps — Landing

Landing page de Simple Apps. Sitio **estático** (HTML/CSS/JS + assets self-hosted),
responsive con menú hamburguesa y acordeón de FAQ.

> **En producción se sirve con el nginx NATIVO del VPS, no con Docker.**
> Ver [Deploy en producción](#deploy-en-producción). Los archivos Docker de este
> repo sirven solo para probar en local.

## Estructura

```
simpleapps-landing/
├── site/                  # sitio estático (lo que sirve nginx)
│   ├── index.html
│   ├── css/
│   │   ├── styles.css     # estilos de la página
│   │   └── icons.css      # Bootstrap Icons (self-hosted)
│   ├── js/
│   │   └── main.js        # menú hamburguesa + acordeón FAQ
│   └── assets/
│       ├── img/hero.png
│       └── fonts/         # General Sans, Lato, Bootstrap Icons
├── deploy/                # infraestructura de producción (nginx nativo)
│   ├── install.sh             # instala/repara todo (idempotente)
│   ├── simpleapps-deploy      # publica site/ en el webroot + reload nginx
│   ├── simpleapps-healthcheck # verifica y auto-repara el sitio
│   ├── nginx/simpleapps.com.ar
│   ├── systemd/               # service de boot + timer de healthcheck
│   ├── apt/99-simpleapps-restore
│   └── certbot/reload-nginx.sh
├── Dockerfile             # SOLO local: nginx:alpine sirviendo site/
├── nginx.conf             # SOLO local (la config real está en deploy/nginx/)
├── docker-compose.yml     # SOLO local: puertos 80/443 + volumen ./ssl
├── docker/40-ensure-ssl.sh# genera cert autofirmado si no hay uno montado
├── ssl/                   # certificados SSL (no se commitean)
└── Simple Apps Landing.html  # diseño original (fuente de referencia)
```

## Desarrollo local

Cualquier servidor estático sirve para previsualizar `site/`. Por ejemplo:

```sh
cd site && python -m http.server 8000
# abrir http://localhost:8000
```

## Docker (solo para probar en local)

```sh
docker compose up -d --build
# HTTP:  http://localhost
# HTTPS: https://localhost  (cert autofirmado si ./ssl está vacío → advertencia del navegador)
```

**No usar en el VPS**: ahí los puertos 80/443 los tiene el nginx nativo y el
contenedor no puede arrancar.

## Deploy en producción

El VPS `vps-4740477-x` (dattaweb) sirve `simpleapps.com.ar` con el **nginx nativo
del sistema**. El sitio vive en `/var/www/simpleapps.com.ar`, que es una copia de
`site/` publicada por `simpleapps-deploy`.

### Publicar cambios

```sh
cd /home/simpleapps-landing
git pull
sudo simpleapps-deploy          # sincroniza site/ → webroot, valida config y recarga nginx
```

O en un solo paso: `sudo simpleapps-deploy --pull`.

### Instalar / reparar la infraestructura

```sh
sudo /home/simpleapps-landing/deploy/install.sh
```

Es idempotente. Instala el vhost, los scripts, el service de boot, el timer de
healthcheck, el hook de apt y la config de renovación de certbot.

### Cómo se garantiza que el sitio no se caiga

| Riesgo | Protección |
|---|---|
| Actualización de nginx pisa el sitio | El webroot es `/var/www/simpleapps.com.ar`, que **no pertenece a ningún paquete** (antes era `/usr/share/nginx/html`, propiedad de `nginx-common`) |
| Cualquier `apt`/`unattended-upgrade` rompe algo | Hook `/etc/apt/apt.conf.d/99-simpleapps-restore` corre el healthcheck después de cada operación de dpkg |
| Se reinicia el server | `nginx.service` y `simpleapps-site.service` están `enabled`: al boot se republica el sitio y se verifica |
| nginx se cae o el contenido se corrompe | `simpleapps-healthcheck.timer` verifica cada 5 min y repara solo |
| Petición sin `Host` conocido cae en el sitio default de nginx | El vhost de simpleapps es `default_server` y el sitio `default` de nginx está deshabilitado |
| Vence el certificado HTTPS | `certbot.timer` renueva con authenticator **webroot** (`/var/www/certbot`), sin parar nginx, y el deploy hook recarga nginx. El healthcheck avisa si faltan menos de 14 días |

### Diagnóstico

```sh
sudo simpleapps-healthcheck              # verifica y repara ahora mismo
journalctl -t simpleapps-healthcheck     # historial de reparaciones
systemctl list-timers 'simpleapps*'      # próximo chequeo
sudo certbot renew --dry-run             # probar renovación del certificado
```

`server_name` está configurado para `simpleapps.com.ar`, `www.simpleapps.com.ar`
y `vps-4740477-x.dattaweb.com`.

### Otro proyecto en el mismo VPS

El VPS también aloja el stack Docker **imedba** en `/home/imedba/` (bindeado solo a
`127.0.0.1`, no lo proxea el nginx nativo). Son independientes. Al trabajar en
imedba, evitar comandos globales de Docker tipo `docker container prune` o
`docker system prune`, que afectan a todo el server.

## Notas

- Enlaces del footer completados con los canales reales: Instagram
  (`instagram.com/simpleapps.ig`), Email (`contacto.simpleapps@gmail.com`),
  WhatsApp (`wa.me/5491123992362`) y LinkedIn. La tarjeta de GitHub del diseño
  original se reemplazó por Instagram (canal activo real, no hay GitHub).
- Config de deploy (nginx/SSL/puertos) tomada del repo `los-verdes-1313/los-verdes`,
  adaptada a un sitio estático (sin build de Node).
