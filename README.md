# Simple Apps — Landing

Landing page de Simple Apps. Sitio **estático** (HTML/CSS/JS + assets self-hosted),
responsive con menú hamburguesa y acordeón de FAQ. Servido con **nginx** vía Docker.

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
├── Dockerfile             # nginx:alpine sirviendo site/
├── nginx.conf             # server HTTP :80 + HTTPS :443
├── docker-compose.yml     # puertos 80/443 + volumen ./ssl
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

## Docker

```sh
# build + up
docker compose up -d --build

# HTTP:  http://localhost
# HTTPS: https://localhost  (cert autofirmado si ./ssl está vacío → advertencia del navegador)
```

Sin certificados en `./ssl`, el contenedor genera un autofirmado de respaldo para
arrancar igual. Con certificados válidos montados, los usa directamente.

## Deploy en el servidor (reemplazar la web actual)

En el servidor ya corre una web similar (proyecto Angular `los-verdes`). Para
reemplazarla por esta:

1. **Clonar / copiar** este repo al servidor.

2. **Certificados SSL** — reutilizá los del deploy anterior:
   ```sh
   cp /ruta/deploy-anterior/ssl/fullchain.pem ./ssl/fullchain.pem
   cp /ruta/deploy-anterior/ssl/privkey.pem   ./ssl/privkey.pem
   ```

3. **Bajar la web actual** (libera los puertos 80/443):
   ```sh
   cd /ruta/deploy-anterior && docker compose down
   ```

4. **Levantar esta**:
   ```sh
   cd /ruta/simpleapps-landing
   docker compose up -d --build
   ```

5. **Verificar**:
   ```sh
   docker compose ps
   curl -I http://localhost
   curl -kI https://localhost
   ```

`server_name` ya está configurado para `simpleapps.com.ar`, `www.simpleapps.com.ar`
y `vps-4740477-x.dattaweb.com`. Para forzar HTTP→HTTPS, descomentá el
`return 301` en `nginx.conf`.

## Notas

- Enlaces del footer completados con los canales reales: Instagram
  (`instagram.com/simpleapps.ig`), Email (`contacto.simpleapps@gmail.com`),
  WhatsApp (`wa.me/5491123992362`) y LinkedIn. La tarjeta de GitHub del diseño
  original se reemplazó por Instagram (canal activo real, no hay GitHub).
- Config de deploy (nginx/SSL/puertos) tomada del repo `los-verdes-1313/los-verdes`,
  adaptada a un sitio estático (sin build de Node).
