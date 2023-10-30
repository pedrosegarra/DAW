---
title: 'Práctica 4.1 - Acceso a un servidor FTP público ftp.rediris.es'
---

# Práctica 4.1 - Acceso a un servidor FTP público ftp.rediris.es ##

### Objetivo: 

Conectarse a un servidor público utilizando los comandos básicos de ftp y descargar un archivo   

### Proceso: 

Abre un terminal cmd en Linux, o PowerShell en Windows. 

Utiliza el comando ftp, esto hará que entres dentro del servidor ftp de tu ordenador y visualiza los comandos ftp disponibles en tu máquina con el comando help.

```
ftp
```
```
help
```
![Practica 4_1](P4_1/P4_1_1.png)

Vamos a conectar con una red pública como es ftp.rediris.es con el usuario anónimo, por lo que no hace falta registrarse con ningún usuario, pulsamos intro cuando nos pida el usuario. 

```
open ftp.rediris.es
```
![Practica 4_1](P4_1/P4_1_2.png)


Posteriormente vamos listar el contenido de archivo y directorios y accederemos a la carpeta /debian/doc para descargar el archivo constitution.txt, para ello sigue las indicaciones siguientes 

```
get constitution.txt
```
![Practica 4_1](P4_1/P4_1_3.png)

Para comprobar que se ha descargado correctamente, salimos del servidor ftp y listamos los archivos de nuestra máquina. Donde podemos observar que el archivo se ha descargado correctamente.
```
quit
```
![Practica 4_1](P4_1/P4_1_4.png)


>En definitiva los permisos del usuario anónimo en un servidor ftp se establecerán para que solamente pueda moverse por los directorios y descargar archivos, nunca subirlos, esto es, normalmente el usuario anónimo no podrá crear ni eliminar ficheros y directorios.







