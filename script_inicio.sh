#!/bin/bash

# Para una salida limpia si Certboot está en marcha
salir_bien() {
    echo "Apagando CERTBOOT"
    if kill -0 "${CERTBOOT_PID}" 2>/dev/null; then
        kill -SIGTERM "${CERTBOOT_PID}"
        wait "${CERTBOOT_PID}" || echo "CERTBOOT ya estaba detenido"
    fi
}

# Si se reciben las señales 
# Si se recibe SIGTERM, se mata de manera ordena el proceso (lo envia docker por defecto para apagar contenedores)
# INT es SIGINT que sería el Ctrl+c
trap "salir_bien" SIGTERM INT
# Si hay un SIGQUIT se hace un exit. SIGQUIT tiene volcado de memoria
trap "exit" QUIT

while true; do
    certbot $@
    
    # Si existe la variable UID, se cambia el propietario de los certificados
    if [ -n "$UID" ]; then
        echo "Cambiando propietario de los ficheros a uid--> ${UID}"
        chown -R $UID /etc/letsencrypt
    fi
    
    # Si existe la variable GID, se cambia el grupo de los certificados
    if [ -n "$GID" ]; then
        echo "Cambiando grupo propietario de los fichero al gid --> ${GID}"
        chgrp -R $GID /etc/letsencrypt
    fi
    
    # Permiso total al propietario y de lectura al grupo
    echo "Changing file permisions to 740"
    chmod -R 740 /etc/letsencrypt
    
    # Si existe la variable DORMIR, se espera es tiempo, y sino se sale
    if [ -n "$SLEEP" ]; then
        # Tiempo a dormir
        echo "Durmiendo durante ${DORMIR}"
        sleep $DORMIR
    else
        break
    fi
done &

# Guardar el PID del proceso
CERTBOOT_PID=$!

# Se espera a que termine el proceso y recoge el codigo de salida
wait -n "${CERTBOOT_PID}"
EXIT_CODE=$?

# Se sale
echo "Saliendo con codigo de salida ${EXIT_CODE}"
exit "${EXIT_CODE}"
