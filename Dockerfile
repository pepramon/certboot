# Utilizamos la imagen oficial de certbot como base
FROM certbot/certbot:latest

# Copiar el script de inicio al contenedor
COPY script_inicio.sh /script_inicio.sh

# Definir el script como entrypoint
ENTRYPOINT ["/bin/sh", "/script_inicio.sh"]
