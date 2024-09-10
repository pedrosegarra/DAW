---
title: '1.4 Instalación y configuración de Git'
---

# Instalación y configuración de Git

## Instalación

### Instalando en Linux

Si quieres instalar Git en Linux a través de un instalador binario, en general puedes hacerlo a través de la herramienta básica de gestión de paquetes que trae tu distribución. Si estás en Fedora, puedes usar yum:

    $ yum install git-core

O si estás en una distribución basada en Debian como Ubuntu, prueba con apt-get:

    $ apt-get install git

### Instalando en Windows

Instalar Git en Windows es muy fácil. El proyecto "Gti for Windows" (antes msysGit) tiene uno de los procesos de instalación más sencillos. Simplemente descarga el archivo exe del instalador desde la página de GitHub, y ejecútalo:

[https://gitforwindows.org/](https://gitforwindows.org/)

Una vez instalado, tendrás tanto la versión de línea de comandos (incluido un cliente SSH que nos será útil más adelante) como la interfaz gráfica de usuario estándar. Se recomienda no modificar las opciones que trae por defecto el instalador.

### Instalando en MacOS

En MacOS se recomienda tener instalada la herramienta [homebrew](https://brew.sh/). Después, es tan fácil como ejecutar:

    $ brew install git

### Recomendación

En este curso estamos acostumbrados a usar máquinas virtuales en AWS. Si vas a estar trabajando en casa y en el instituto, te recomiendo que crees una MV Debian con parámetros por defecto en AWS para ir siguiendo el curso. De esta forma tendrás lo mismo en ambos lugares.

Si optas por esa opción recuerda realizar lo primero un `sudo apt-get update && upgrade` antes de instalar git para contar con la última versión disponible.

!!!Información
    Puedes comprobar la versión de git que estás usando con `git --version`. En el momento de escribir estas notas la versión es la 2.39.2

## Configuración

### Tu identidad

Lo primero que deberías hacer cuando instalas Git es establecer tu nombre de usuario y dirección de correo electrónico. Esto es importante porque las confirmaciones de cambios (commits) en Git usan esta información, y es introducida de manera inmutable en los commits que envías:

    $ git config --global user.name "John Doe"
    $ git config --global user.email johndoe@example.com

También se recomienda configurar el siguiente parámetro:

    $ git config --global push.default simple

### Bash Completion

Si estás trabajando en linux _Bash completion_ es una utilidad que permite a bash completar órdenes y parámetros. Por defecto suele venir desactivada en Ubuntu y es necesario modificar el archivo `$HOME/.bashrc` para poder activarla. Simplemente hay que descomentar las líneas que lo activan.