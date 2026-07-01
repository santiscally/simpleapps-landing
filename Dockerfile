# Simple Apps — landing page estática servida por nginx.
# El sitio es 100% estático (HTML/CSS/JS + assets), no requiere build de Node.
FROM nginx:alpine

# openssl: genera un certificado autofirmado de respaldo si no se montan
# certificados reales en /etc/nginx/ssl (ver docker/40-ensure-ssl.sh).
RUN apk add --no-cache openssl

# Configuración del server (HTTP :80 + HTTPS :443)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Se ejecuta antes de arrancar nginx: asegura que existan los certificados SSL.
COPY docker/40-ensure-ssl.sh /docker-entrypoint.d/40-ensure-ssl.sh
RUN chmod +x /docker-entrypoint.d/40-ensure-ssl.sh

# Sitio estático
COPY site/ /usr/share/nginx/html

EXPOSE 80
EXPOSE 443

# Iniciar nginx (entrypoint heredado de la imagen base ejecuta docker-entrypoint.d/*)
CMD ["nginx", "-g", "daemon off;"]
