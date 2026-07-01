# Certificados SSL

Colocá aquí los certificados para HTTPS:

- `fullchain.pem` — certificado + cadena completa
- `privkey.pem` — clave privada

Este directorio se monta en el contenedor como `/etc/nginx/ssl` (ver `docker-compose.yml`).

> **Importante:** los `.pem`/`.key`/`.crt` están ignorados por git (`.gitignore`). No se commitean.

## En el servidor

Reutilizá los certificados del deploy anterior (Let's Encrypt / el que ya estaba en uso):

```sh
cp /ruta/al/deploy/anterior/ssl/fullchain.pem ./ssl/fullchain.pem
cp /ruta/al/deploy/anterior/ssl/privkey.pem  ./ssl/privkey.pem
```

Si este directorio queda vacío, el contenedor genera un certificado **autofirmado**
de respaldo al arrancar (el navegador mostrará advertencia, pero el sitio levanta).
