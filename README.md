# Imagen de Docker para Certbot

Esta imagen de docker ofrece un semidemonio para CertBoot basado en su imagen oficial para manejar certificados SSL/TLS

Se puede fijar el tiempo entre los test para saber si es necesario renovar el certificado, el usuario y grupo a quien pertenecen los certificados para que puedan ser leídos por otros contenedores.

## Como usar con Docker Compose

```yml
version: "3"

services :
  certbot:
    # Cargar la imagen
    image: pepramon/certbot
    volumes:
      # Donde se almacenan los certificados
      - ./certbot/certs:/etc/letsencrypt:rw
      # Directorio con los plugins de certboot
      - ./certbot/plugins-certbot:/var/lib/letsencrypt:rw
      # Donde poner la prueba ACME (dependerá del comando usado)
      - ./certbot/acme:/acme:rw
    environment:
      # Tiempo a esperar para probar la caducidad de los certificados
      - DORMIR=6h
      # Propietario de los certificados (permisos 740)
      - UID = 1000
      # Grupo propietario de los certificados  (permisos 740)
      - GID = 1000

    # Comando a ejecutar (en este caso prueba http). Leer la documentación de CertBoot para otros comandos

    command: certonly --staging --non-interactive --email your@email.com --agree-tos --webroot -w /acme -d your.domain.com -d other.domain.net
```

## Modificaciones realizadas a la imagen oficial

### Variable de entorno `$DORMIR`

Esta variable define el tiempo que se esperará hasta volver a ejecutar el comando y probar de renovar el certificado. Utilizar formato del comando sleep de Linux, por ejemplo "6h"

Si no está definida el contenedor hará lo mismo que la imagen oficial, un single run y saldrá

**CUIDADO** Si tienes una política de restart, si no está bien definida, se puede correr el contenedor muchas veces seguidas!!!. Si se obtiene el certificado no pasaría nada ya que solo se comunica con Let'sEncrypt si se tiene que renovar, pero si no se obtiene un certificado, continuaría haciendo peticiones a  Let'sEncrypt y podría bloquearte!!!!

### Variable de entorno `$UID` 

Indica el UID del propietario de los ficheros (certificados) que genera CertBott. Si no está definida, por defecto será el UID de CertBoot

### Variable de entorno `$GID`

Esta variable fija el grupo propietario de los ficheros (certificados) que genera CertBott. Si no está definida, por defecto será el GID de CertBoot

### Permiso de ficheros 

Todos los ficheros dentro de `/etc/letsencrypt` se modificarán con los permisos `740` o `rwxr-x---`. Hay que tenerlo en consideración si es necesario leerlos desde otros contenedores que lean el mismo directorio (por ejemplo Nginx o Apache)

### Comando

Puedes poner tu comando personal, en este ejemplo se usa `--staging` que implica que no se usa el servidor oficial de Let'sEncrypt, sino que se usan servidores de pruebas para evitar problemas mientras se hace un test.

## Soporte

Aunque el punto de desarrollo de este proyecto está en un servidor de Gitea propio, se actualiza automáticamente el servidor de Github, y por tanto, cualquier comentario será bienvenido.

## Actualización de la imagen en DockerHub

Como se ha comentado anteriormente, el proyecto está alojado en un servidor de Gitea propio, una de las razones para ello es poder mantener actualiza la imagen de DockerHub de manera automática.

La imagen [https://hub.docker.com/r/pepramon/certbot](https://hub.docker.com/r/pepramon/certbot) se actualiza automáticamente en los siguiente supuestos:

* La imagen base de CertBoot ha cambiado
* Se ha modificado el Dockerfile o el script `script_inicio.sh` de la reaiz del repositorio

Para saber si la imagen base de CertBoot ha cambiado respecto a la construida, se almacena una etiqueta en el interior de la imagen generada que tiene el SHA de la imagen base (revisar `.gitea/workflows/` para ver como se hace).

La construcción se hace mediante Podman con el contenedor personalizado alojado en [https://github.com/pepramon/gitea-runner](https://github.com/pepramon/gitea-runner)