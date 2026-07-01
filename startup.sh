#!/bin/bash
# Script simple para levantar SimpleApps al reiniciar el servidor

cd /home/simpleapps-landing
docker-compose down 2>/dev/null
docker container prune -f &>/dev/null
docker-compose up -d --build

echo "$(date): SimpleApps iniciado" >> /var/log/simpleapps.log
