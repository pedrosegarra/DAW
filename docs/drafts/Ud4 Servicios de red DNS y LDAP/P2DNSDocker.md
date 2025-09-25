---
title: 'Práctica 2 - Dockerización de un servidor DNS'
---

# Práctica 2 - Dockerización de un servidor DNS

Ahora que ya sabemos cómo instalar y configurar un servidor DNS vamos a dockerizarlo. A partir de ahora vamos a utilizar imágenes de docker ya existentes para ahorrarnos la tarea de instalar nuestro servidor.

!!! nota
    La imagen oficial de Bind9 en Docker hub es [internetsystemsconsortium/bind9](https://hub.docker.com/r/internetsystemsconsortium/bind9)

    Ahí puedes encontrar toda la información referente a esa imagen docker y cómo usarla.

    Usaremos la versión BIND 9.18 que tiene "extended support"

A la hora de dockerizar un servicio hemos visto que podemos seguir varias estrategias:

* Montar directorios del contenedor en directorios de nuestra máquina host
* Copiar ficheros de nuestro host al interior del contenedor en el momento de crear la imagen mediante el fichero Dockerfile
* Crear el contenedor y una vez creado usar el comando "docker cp" para copiar ficheros del host a su interior (podemos hacerlo con el contenedor arrancado o parado)
* Crear el contenedor, arrancarlo, "entrar a su interior" con "docker exec -it NOMBRECONTENEDOR /bin/sh" y modificar los ficheros que necesitemos. Si usamos esta forma no podremos reiniciar el servicio desde el contenedor. Deberemos salir y reiniciarlo

En esta ocasión vamos a optar por crear el contenedor y usar comandos "docker cp".

Para crear el contenedor usaremos el comando:

```sh
docker run -d \
        --name=miserverdns \
        --publish 53:53/udp \
        --publish 53:53/tcp \
        internetsystemsconsortium/bind9:9.18
```

A estas alturas ya tenemos claro lo que hace este comando.

!!! Atención
    Si estamos estamos corriendo docker en una EC2 en AWS puede que ya tenga el servicio `systemd-resolved` corriendo y utilizando el puerto 53, lo que nos dará un conflicto y evitará la creación del contenedor. Si esto ocurre podemos pararlo con `sudo systemctl stop systemd-resolved` y ya lo reactivaremos al acabar la práctica.

Una vez arrancado el contenedor ya hará consultas recursivas, así que le podemos preguntar por cualquier dominio y comprobar que resuelve correctamente. Por ejemplo, desde el host:

```
nslookup cisco.com 127.0.0.1
```

La localización de los archivos en el contenedor es la misma que en una instalación habitual e bind9. La única particularidad que he encontrado es que el fichero `/etc/bind/named.conf` de la imagen es distinto al de una instalación habitual y no tiene las directivas "include" habituales. Así que para poder trabajar como hemos hecho en nuestra instalación lo sobreescribiremos.

Para crear una zona igual que la de la práctica anterior, nos crearemos una carpeta `miserverdns` y crearemos en su interior estos ficheros:

```
named.conf
named.conf.options
named.conf.local
db.deaw.es
db.3.85.104
```

!!! Atención
    Recuerda que tendrás que cambiar `db.3.85.104` por el que corresponda a tu IP de resolución inversa

En cuanto al contenido de los ficheros serán todos iguales a los de la práctica anterior, salvo `named.conf` que contendrá lo siguiente:

``` 
include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
```

Cuando ya los tengamos todos creados los copiaremos uno a uno al interior del contenedor con:

```
docker cp named.conf miserverdns:/etc/bind
docker cp named.conf.options miserverdns:/etc/bind
...
```

Una vez todos copiados al interior podemos parar y reiniciar el contenedor, si estaba en marcha, o arrancarlo si estaba parado.

Ahora ya podemos interrogarlo, como hicimos en la práctica anterior y comprobar que resuelve correctamente.

Si hubiera algún problema o queremos comprobar su correcta configuración recuerda que tenemos los comandos `named-checkconf` y `named-checkzone`. Podemos lanzarlos al contenedor arrancado con:

```
docker exec miserverdns named-checkconf
docker exec miserverdns named-checkzone deaw.es /etc/bind/db.deaw.es
```
