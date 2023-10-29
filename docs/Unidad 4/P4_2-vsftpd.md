
COMUNIDAD : https://help.ubuntu.com/community/vsftpd

# Práctica 4.2 - Instalar y Configurar el servidor vsftpd 

En esta práctica, aprenderemos cómo  instalar y configurar un servidor FTP usando vsftpd en un servidor basado en Ubuntu. 

**Información básica sobre el servidor vsftpd (Very Secure FTP Daemon):**

Hoy en día existe una amplia gama de servidores FTP de código abierto, como FTPD, VSFTPD, PROFTPD y pureftpd. Entre todos ellos, VSFTPD es un protocolo muy seguro, rápido y el más utilizado para transferir archivos entre dos sistemas. VSFTPD también se conoce como «Demonio de Protocolo de Transferencia de Archivos Muy Seguro» con soporte de SSL, IPv6, FTPS explícito e implícito.

Archivos y directorios que se crean en el sistema:

- El archivo `/etc/init.d/vsftpd` es el script de inicio en sistemas basados en Linux que permite administrar el servicio vsftpd, a través de  tareas como iniciar, detener, reiniciar y administrar el servicio de FTP. Por ejemplo un comando para iniciar el servicio en Ubuntu sería este: `systemctl start vsftpd` , entre otros (stop, restart, reload, status).
- El archivo `/usr/sbin/vsftpd` este archivo es el binario principal que se utiliza para iniciar y ejecutar el servidor FTP vsftpd. Es responsable de escuchar en el puerto FTP (por lo general, el puerto 21) y gestionar las conexiones de los clientes FTP. Este archivo lee la configuración del archivo `/etc/vsftpd.conf` al iniciarse para personalizar el comportamiento del servidor FTP. 
- El archivo `/etc/vsftpd.conf` es el archivo de configuración principal del servidor vsftpd donde se especifican numerosos parámetros de configuración que controlan el comportamiento y la seguridad del servidor FTP.
- El directorio `/srv/ftp` este directorio raíz por defecto del servidor FTP, que se utiliza para organizar y administrar los archivos y directorios que están disponibles para los usuarios que se conectan al servidor FTP. Es donde se alojarán los archivos para usuarios anónimos (accesos anónimos) sino se indica lo contrario en la configuración.
- El archivo `/etc/ftpusers` tiene como función denegar el acceso a ciertos usuarios, evitando que puedan autenticarse y utilizar los servicios de FTP.
- El archivo `/etc/vsftpd.user_list` se utiliza para controlar el acceso permitido a un grupo específico de usuarios. Este archivo no se instala, por lo cual hay que crearlo antes de comenzar a trabajar con la configuración.
- El archivo `/etc/vsftpd.chroot_list` tiene como propósito principal controlar qué usuarios pueden ser "encarcelados" en sus respectivos directorios de inicio (chroot) cuando se conectan al servidor FTP.
- El archivo `/var/log/vsftpd.log` es un archivo de registro útil para el monitoreo, la solución de problemas y la auditoría de actividades en el servidor FTP.

Vamos a empezar a trabajar. 
--------------------------------------
IMPORTANTE: he seguido 
https://linuxpasion.com/como-instalar-y-configurar-un-servidor-ftp-vsftpd-con-ssl-tls-en-ubuntu-20-04
https://howtoforge.es/como-instalar-el-servidor-ftp-vsftpd-y-asegurarlo-con-tls-en-debian-11/
--------------------------------------

## Creamos una instancia AWS

Vamos a instalar el servidor vsftpd en una VM Debian en AWS. Crear una instancia nueva que llamarás **P4-vsftpd**

**Añade una Regla de Entrada:**
En la pestaña "Reglas de entrada", debes añadir una regla para permitir el tráfico en el puerto FTP que necesitas. 

- Para FTP no cifrado (puerto 21), crea una regla con el protocolo TCP y el puerto 21.
- Para FTPS o SFTP con cifrado (puerto 22), también crea una regla con el protocolo TCP y el puerto 22.

Asegúrate de especificar la fuente del tráfico, lo que puede ser tu propia dirección IP si deseas acceder al servidor FTP desde tu ubicación actual o cualquier otra fuente si deseas permitir el acceso desde cualquier lugar (ten en cuenta que esto puede ser menos seguro).

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


### Paso 2: Configuración del directorio de usuarios

1. Ahora, vamos a crear una nueva cuenta de usuario para transacciones FTP, utilizando este usuario iniciaremos la sesión en el servidor FTP más adelante. Estableceremos como contraseña la misma que el usuario.

```sh
sudo adduser userftp
```

2. Agregamos el nuevo usuario `userftp` a la lista de usuarios de FTP permitidos.

```sh
echo "userftp" | sudo tee -a /etc/vsftpd.userlist
```
3. Crearemos un directorio FTP y de archivos de datos para este nuevo usuario.

Este paso lo realizamos cuando se desea un directorio diferente como raíz FTP (recuerda que el que tiene por defecto el servidor ftp es  `/srv/ftp`) y otro diferente para cargar archivos para sortear la limitación de chroot jail.

Creamos la carpeta FTP. 
```sh
sudo mkdir /home/userftp/ftp
```
Establecer su propiedad, para ello cambiaremos el propietario a `nobody` y el grupo a `nogroup`, donde `nobody` es un usuario que generalmente tiene permisos mínimos y se utiliza para ejecutar servicios o procesos que no deben tener acceso a recursos del sistema y `nogroup` es un grupo que también se utiliza para limitar el acceso a recursos y archivos.
  
```sh
sudo chown nobody:nogroup /home/userftp/ftp
```
Elimina los permisos de escritura en la carpeta.
```sh
sudo chmod a-w /home/userftp/ftp
```

Verificamos los permisos antes de continuar.
```sh
sudo ls -al /home/userftp/ftp
```

Ahora vamos a crear el directorio de escritura real para los archivos, donde se puedan subir los archivos. Le vamos a dar la propiedad al usuario creado `userftp` y le damos todos los permisos

```sh
sudo mkdir /home/userftp/ftp/upload
sudo chown userftp:userftp /home/userftp/ftp/upload
sudo chmod -R 777 /home/userftp/ftp/upload
```
Comprueba los permisos.

```sh
sudo ls -al /home/userftp/ftp
```
Finalmente, agregamos un archivo pruebaftp.txt para usar en las pruebas.

```sh
echo "esto es una prueba con vsftpd" | sudo tee /home/userftp/ftp/upload/pruebaftp.txt
```

## PASO 3. Configuración del servidor vsftpd

Ahora repasaremos algunas configuraciones importantes para que vsftpd funcione. Para ello buscamos el archivo de configuración y guardamos una copia de él por si acaso: 

```sh
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.backup
```
Estas son las modificaciones que vamos a realizar dentro del archivo de configuración:

Comienza abriendo el archivo de configuración.

```sh
sudo nano /etc/vsftpd.conf
```

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
---------------------
**3. Cárcel de Chroot para los usuarios locales** ?¿
FTP funciona mejor cuando un usuario está restringido a un directorio determinado. Vsftpd logra eso usando chroot jails. 
Cuando chroot está habilitado para usuarios locales, están restringidos a sus directorios de inicio de forma predeterminada. Para lograr esto, cambiamos la configuración con las propiedades siguientes: .

```linuxconfig
chroot_local_user=YES
```
Para evitar cualquier vulnerabilidad de seguridad, chroot cuando está habilitado, no funcionará siempre que el directorio al que los usuarios estén restringidos sea escribible. Para sortear esta limitación, tenemos dos métodos para **permitir la carga de archivos cuando chroot está habilitado.**

- Método 1 – Este método funciona mediante el uso de un directorio diferente para cargas FTP. 
En nuestro caso, hemos decidio crear un directorio `ftp` dentro del home del usuario para que sirva como chroot y un segundo directorio para la carga de archivos que hemos llamamos `upload`. Para lograr esto, agregamos las siguientes líneas al final del archivo.

```linuxconfig
user_sub_token=$USER
local_root=/home/$USER/ftp
```
- Método 2 – El segundo método es simplemente otorgar acceso de escritura al directorio de inicio como un todo. 
Agregamos la siguiente línea para lograr esto.
```linuxconfig
allow_writeable_chroot=YES
```

---------------------
**4. Restricción de usuarios**
Para permitir que solo ciertos usuarios inicien sesión en el servidor FTP, agreguamos las siguientes líneas en la parte inferior. Con esta opción habilitada, debemos especificar qué usuarios deberían poder usar FTP y agregar sus nombres de usuario en el archivo /etc/vsftpd.userlist.

```linuxconfig
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
```

Guarda y cierra el archivo. Reiniciamos el servicio vsftpd para habilitar la configuración realizada.

```sh
sudo systemctl restart vsftpd
```
A continuación, asegúrate de que el servicio vsftpd está en su estado de ejecución ejecutando el siguiente comando en el Terminal:

```sh
sudo systemctl status vsftpd
```
Recuerda para volver al prompt , debes pulsar q  


## Paso 5 – Comprobación del acceso FTP





