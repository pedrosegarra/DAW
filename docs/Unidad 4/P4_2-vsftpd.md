
COMUNIDAD : https://help.ubuntu.com/community/vsftpd

# Práctica 4.2 - Instalar y Configurar el servidor vsftpd 

En esta práctica, aprenderemos cómo  instalar y configurar un servidor FTP usando vsftpd en un servidor basado en Ubuntu. También aprenderemos cómo crear grupos de usuarios.

## Información básica sobre el servidor vsftpd (Very Secure FTP Daemon):

Hoy en día existe una amplia gama de servidores FTP de código abierto, como FTPD, VSFTPD, PROFTPD y pureftpd. Entre todos ellos, VSFTPD es un protocolo muy seguro, rápido y el más utilizado para transferir archivos entre dos sistemas. VSFTPD también se conoce como «Demonio de Protocolo de Transferencia de Archivos Muy Seguro» con soporte de SSL, IPv6, FTPS explícito e implícito.

**Archivos y directorios que se crean en el sistema:**

- El archivo `/etc/init.d/vsftpd` es el script de inicio en sistemas basados en Linux que permite administrar el servicio vsftpd, a través de  tareas como iniciar, detener, reiniciar y administrar el servicio de FTP. Por ejemplo un comando para iniciar el servicio en Ubuntu sería este: `systemctl start vsftpd` , entre otros (stop, restart, reload, status).
- El archivo `/usr/sbin/vsftpd` este archivo es el binario principal que se utiliza para iniciar y ejecutar el servidor FTP vsftpd. Es responsable de escuchar en el puerto FTP (por lo general, el puerto 21) y gestionar las conexiones de los clientes FTP. Este archivo lee la configuración del archivo `/etc/vsftpd.conf` al iniciarse para personalizar el comportamiento del servidor FTP. 
- El archivo `/etc/vsftpd.conf` es el archivo de configuración principal del servidor vsftpd donde se especifican numerosos parámetros de configuración que controlan el comportamiento y la seguridad del servidor FTP.
- El directorio `/srv/ftp` este directorio raíz por defecto del servidor FTP, que se utiliza para organizar y administrar los archivos y directorios que están disponibles para los usuarios que se conectan al servidor FTP. Es donde se alojarán los archivos para usuarios anónimos (accesos anónimos) sino se indica lo contrario en la configuración.
- El archivo `/etc/ftpusers` tiene como función denegar el acceso a ciertos usuarios, evitando que puedan autenticarse y utilizar los servicios de FTP.
- El archivo `/etc/vsftpd.user_list` se utiliza para controlar el acceso permitido a un grupo específico de usuarios. Este archivo no se instala, por lo cual hay que crearlo antes de comenzar a trabajar con la configuración.
- El archivo `/etc/vsftpd.chroot_list` tiene como propósito principal controlar qué usuarios pueden ser "encarcelados" en sus respectivos directorios de inicio (chroot) cuando se conectan al servidor FTP.
- El archivo `/var/log/vsftpd.log` es un archivo de registro útil para el monitoreo, la solución de problemas y la auditoría de actividades en el servidor FTP.

Vamos a empezar a trabajar ;

Crea una instancia en AWS son el sistema Debian, como has realizado hasta el momento, que llamarás **P4-vsftpd**

## PASO 1. Instalación del servidor vsftpd

En primer lugar, actualizaremos los repositorios de Ububtu y a continuación instalaremos el **servidor vsftpd** :

```
sudo apt-get update
sudo apt-get install vsftpd
```

Se crea el usuario *ftp* dentro del fichero **/etc/passwd**, y el grupo *ftp* en **/etc/group** del Servidor Linux. Puedes comprobarlo visualizando ambos ficheros.

```sh
cat /etc/passwd
cat /etc/group
```

Para comprobar que el servidor se ha iniciado buscamos el proceso:

```sh
ps -ef | grep vsftpd
```
Vemos que aparecen el proceso con el archivo de configuración  **/etc/vsftpd.conf** y el archivo ejecutable principal del servidor FTP vsftpd **/usr/sbin/vsftpd** 

## PASO 2. Configuración del servidor vsftpd

Ahora repasaremos algunas configuraciones importantes para que vsftpd funcione. Para ello buscamos el archivo de configuración y guardamos una copia de él por si acaso: 

```sh
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.backup
```
Estas son las modificaciones que vamos a realizar dentro del archivo de configuración:

**1. Acceso FTP a usuarios locales**
En este tutorial, permitiremos el acceso FTP solo a los usuarios locales y deshabilitaremos cualquier acceso anónimo. Para hacer esto, asegúrese de que las siguientes líneas existan y sean las siguientes.

```linuxconfig
anonymous_enable=NO
local_enable=YES
```

**2. Habilitar la carga de archivos**
El propósito singular más importante de FTP aquí es poder escribir en el servidor. Descomenta la siguiente línea para habilitar la carga de archivos eliminando # delante de ella.

```linuxconfig
write_enable=YES
```

**3. Cárcel de Chroot para los usuarios locales**
FTP funciona mejor cuando un usuario está restringido a un directorio determinado. Vsftpd logra eso usando chroot jails. Cuando chroot está habilitado para usuarios locales, están restringidos a sus directorios de inicio de forma predeterminada. Para lograr esto, descomente la siguiente línea.

```linuxconfig
chroot_local_user=YES
allow_writeable_chroot=YES
```

**4. Restricción de usuarios**
Para permitir que solo ciertos usuarios inicien sesión en el servidor FTP, agreguamos las siguientes líneas en la parte inferior. Con esta opción habilitada, debemos especificar qué usuarios deberían poder usar FTP y agregar sus nombres de usuario en el archivo /etc/vsftpd.userlist.

```linuxconfig
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
```

Reiniciamos vsftpd para habilitar la configuración realizada.

```sh
sudo systemctl restart vsftpd
```

### Paso 4: configuración del directorio de usuarios

Ahora, vamos a crear una nueva cuenta de usuario para transacciones FTP, utilizando este usuario iniciaremos la sesión en el servidor FTP más adelante.

```sh
sudo adduser testuser
```
-----------------------------
Ahora vamos a crear una carpeta en nuestro `home` en Debian que llamaremos `ftp`. Recuerda que debes cambiar nombre_usuario por admin (en Debian).

```sh
mkdir /home/nombre_usuario/ftp
```

Posteriormente en el archivo de configuración de **vsftpd.conf** indicaremos que este será el directorio al cual vsftpd se cambia después de conectarse el usuario e incluiremos la línea siguiente: `local_root=/home/admin/ftp`


## Comprobar la Conexión FTP al servidor vsftpd SIN CIFRADO


