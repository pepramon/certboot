# Utilizamos la imagen oficial de certbot como base
FROM certbot/certbot:latest

# CertBoot latest se basa en Alpine, se actualiza el sistema
RUN apk update && \
    apk upgrade && \
    rm -rf /var/cache/apk/*

# Copiar el script de inicio al contenedor
COPY script_inicio.sh /script_inicio.sh

# Definir el script como entrypoint
ENTRYPOINT ["/bin/sh", "/script_inicio.sh"]
