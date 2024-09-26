---
title: '2 Instalación'
---

# Instalación

En el curso que estamos utilizando tenemos un capítulo completo dedicado a la instalación de Docker tanto en Linux, Windows y MacOSX. Puedes consultarlo aquí:

[Instalación de Docker](Ud7_img/Docker02_Instalacion.pdf)

Vamos a aprender a usar Docker sobre una distribución Linux Debian como hemos hecho hasta ahora. Si cuentas con un sistema operativo Linux basado en Debian puedes seguir el curso directamente sobre tu S.O. Sino, te aconsejo crear una máquina virtual en AWS con un Debian con opciones por defecto y seguir allí el curso. Recuerda, lo primero actualizar paquetes para contar con las últimas versiones disponibles:

    sudo apt-get update && sudo apt-get upgrade

Puedes seguir las instrucciones de instalación del PDF anterior. No obstante, yo te aconsejo que sigas el presente manual que te llevará a las instrucciones oficiales, más actualizadas.

## Disponibilidad

Existe dos versiones de Docker, una libre y otra que no lo es. En nuestro curso nos ocuparemos exclusivamente de la primera: [Docker CE (Community Edition)](https://docs.docker.com/install/).

Docker CE está disponible para los siguientes sistemas GNU/Linux: CentOS, Debian, Fedora y Ubuntu. No todas están en múltiples arquitecturas, pero sí todas soportan _x86\_64/amd64_. Si tienes otra arquitectura u otro sistema es mejor que uses una máquina virtual para arrancar una distribución compatible.

Para más información sobre sistemas privativos soportados, leer la sección de [plataformas soportadas](https://docs.docker.com/install/#supported-platforms) de la documentación oficial.

## Instalación

Debido a que, dependiendo de la distribución, la forma de instalarlo difiere, es mejor consultar la documentación oficial para saber como instalar Docker en tu máquina.

* Ubuntu: [https://docs.docker.com/install/linux/docker-ce/ubuntu/](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
* Debian: [https://docs.docker.com/install/linux/docker-ce/debian/](https://docs.docker.com/install/linux/docker-ce/debian/)
* CentOS: [https://docs.docker.com/install/linux/docker-ce/centos/](https://docs.docker.com/install/linux/docker-ce/centos/)
* Fedora: [https://docs.docker.com/install/linux/docker-ce/fedora/](https://docs.docker.com/install/linux/docker-ce/fedora/)

Como hemos quedado nosotros usaremos una Debian sobre AWS. Así pues, sigue las instrucciones anteriores para dicha distribución. No hará falta que hagas la parte de "Uninstall old versions" ya que es una máquina virtual recién instalada. Y utiliza la opcion "Install using the apt repository".

Una vez finalizado el proceso comprueba que Docker engine CE se ha instalado correctamente con:

    sudo docker version

Para saber si tienes Docker bien instalado, los tutoriales oficiales siempre te indican inicies un contenedor de ejemplo. Esto es lo que sucede:

!!! example
    Los códigos de ejemplo irán acompañados de una caja como esta para poder copiar y pegar los comandos.
    
    ```sh
    sudo docker run hello-world
    ```

El resultado es el siguiente:

```sh hl_lines="1 2 6"
$ sudo docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
d1725b59e92d: Pull complete 
Digest: sha256:0add3ace90ecb4adbf7777e9aacf18357296e799f81cabc9fde470971e499788
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
1. The Docker client contacted the Docker daemon.
2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
$ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
https://hub.docker.com/

For more examples and ideas, visit:
https://docs.docker.com/get-started/
```

En la línea 1 estamos ejecutando el cliente de Docker, y estamos indicando que queremos ejecutar un contenedor a partir de la imagen [hello-world](https://hub.docker.com/_/hello-world/) del registro público de Docker.

Si es la primera vez que hemos ejecutado esa imagen, nos aparecerá la línea 2, que indica que la imagen no puede ser encontrada y va a proceder a buscarla, por defecto, en el registro público. Si tenemos conexión a Internet se descargará la imagen  (línea 6) y automáticamente creará un contenedor.

Tanto si se ha descargado la imagen o ya estaba descargada, el contenedor se ejecutará, obteniendo el texto de bienvenida que se ve en el cuadro anterior.

## Post instalación

Para finalizar la instalación vamos a hacer un par de cosas que nos simplificarán la vida.

### Permitir administrar Docker a un usuario sin privilegios

Si estamos usando _Docker_ en nuestro ordenador personal, podemos configurar nuestro usuario para usar el cliente sin tener que poner _sudo_ delante. Para ello ejecuta lo siguiente:

!!! example
    Añade tu usuario al grupo de docker.

        sudo usermod -aG docker $USER

Para que los nuevos permisos surtan efecto, debes cerrar y volver a abrir la sesión. Para problemas relacionados con los permisos visitad [la página del manual oficial](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user).

### Instalar Docker Compose

También es necesario traer una herramienta llamada `Docker Compose`. Puedes instalarla con las instrucciones que hay en la página de [Instalación de Docker Compose](https://docs.docker.com/compose/install/).

Sin embargo, si usas _Ubuntu_ o _Debian_ puedes instalarlo de forma más fácil con _apt_:

!!! example
    Instalación de _Docker Compose_:

        sudo apt install docker-compose

Llegados a este punto deberíamos tener todas las herramientas necesarias para seguir este curso.