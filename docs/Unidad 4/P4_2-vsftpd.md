
COMUNIDAD : https://help.ubuntu.com/community/vsftpd

# Práctica 4.2 - Instalar y Configurar el servidor vsftpd 

## OBJETIVO:
En esta práctica, aprenderemos cómo  instalar y configurar un servidor FTP usando vsftpd en un servidor basado en Ubuntu. También aprenderemos cómo asegurar la conexión usando el protocolo SSL/TLS.

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


### 3. Proteger el Vsftpd con SSL/TLS. 

**Generar un certificado autofirmado con OpenSSL**

Digamos que quieres transferir datos encriptados a través de FTP, para ello necesitas crear un certificado SSL y necesitas habilitar la conexión SSL/TLS.

Puedes crear un certificado utilizando OpenSSL con el siguiente comando:

Ya hemos visto que el servidor vsftpd admite FTPS (FTP sobre SSL/TLS), es decir que cifra las comunicaciones entre el cliente y el servidor. Así que para poder transferir datos encriptados a través de FTP, necesitaremos crear un certificado SSL y habilitar la conexión SSL/TLS. Por ello vamos a utilizar OpenSSL con el siguiente comando;

```sh
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem
```
```sh
sudo openssl req \ 
-x509 -nodes -days 365 \ 
-newkey rsa:2048 \ 
-keyout /etc/ssl/private/vsftpd-key.pem \ 
-out /etc/ssl/certs/vsftpd-cert.pem
```
Este comando genera un certificado SSL autofirmado válido por 365 días y guarda la clave privada y el certificado en /etc/ssl/private/vsftpd-key.pem y /etc/ssl/certs/vsftpd-cert.pem.

Tenemos que tener en cuenta que nos pedirá que ingresemos cierta información, como el país, el estado/provincia y el nombre común. Puede ingresar los valores que desee o dejarlos en blanco.

**Habilitar el cifrado SSL**

Una vez que tengamos el certificado SSL y la clave privada, tendremos que modificar el archivo /etc/vsftpd.conf y actualizar las siguientes directivas.

- rsa_cert_file: indicaremos la ruta del archivo del certificado.
- rsa_private_key_file: indicaremos la ruta del archivo de clave privada.
- ssl_enable: indicaremos el valor en YES para habilitar el cifrado SSL.

Lo vamos a realizar en el siguiente apartado junto con otros parámetros.

## 4. Configuración del servidor vsftpd

Y una vez realizados estos pasos, procedemos a realizar la configuración de *vsftpd* propiamente dicha. Para ello buscamos el archivo de configuración y guardamos una copia de él por si acaso: 

```sh
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.backup
```

Pasamos a modificar el archivo de configuración de este **servicio vsftpd.conf** utilizando un editor como puede ser *nano* o *vim* :

```sh
sudo nano /etc/vsftpd.conf
```
En primer lugar, buscaremos las siguientes líneas del archivo y las **eliminaremos por completo o comentaremos estas líneas**:

```linuxconfig
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO
```
Tras ello, **añadiremos** estas líneas en su lugar;

```linuxconfig 
rsa_cert_file=/etc/ssl/private/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.pem
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
ssl_ciphers=HIGH

local_root=/home/nombre_usuario/ftp
```

## 4. Reinicia el servicio 

Finalmente **reiniciamos el servicio** para que coja la nueva configuración realizada en todos estos pasos.

```sh
sudo systemctl restart --now vsftpd
```

## 5. Comprobar la Conexión FTP al servidor vsftpd

DESCARGAR EL ARCHIVO DE CONFIGURACION DE BACKUP 

¿CON QUE USUARIO CONSIGO ACCEDER AL SERVIDOR FTP DESDE MI PC PARA PODER SUBIR O BAJAR ARCHIVOS ??

- EL USUARIO admin ? profe ? DEBEN ESTAR DENTRO DEL etc/group y dentro de etc/ftp 

------ ESTO ES DE RAUL PRIETO QUE NO ENTIENDO ------

> Para poner realizar una conexión FTP al servidor FTP, debemos tener en cuenta si el modo de acceso es
>> - *Mediante el puerto por defecto del protocolo <u>inseguro</u> FTP*, el **puerto 21**, pero utilizando certificados que cifran el intercambio de datos convirtiéndolo así en <u>seguro</u>
>> - o *haciendo uso del protocolo SFTP*, que es un protocolo dedicado al intercambio de datos mediante una conexión similar a SSH, utilizando de hecho el **puerto 22**.

!!!task "Tarea"
    Configura un nuevo dominio (nombre web) para el .zip con el nuevo sitio web que os proporcionado. 
    **En este caso debéis transferir los archivos a vuestra Debian mediante SFTP.**

Tras acabar esta configuración, ya podremos acceder a nuestro servidor mediante un cliente FTP (como FileZilla, WinSCP o la línea de comandos) para conectarte al servidor FTP utilizando la dirección IP del servidor y las credenciales del usuario FTP que creaste.

La que vamos a intentar es realizar una transferencia de archivos entre nuestro servidor FTP en Debian y el cliente FTP (nuestro ordenador). 
Tras acabar esta configuración, ya podremos acceder a nuestro servidor mediante un **cliente FTP** adecuado, como por ejemplo 

    
#### Acceso con Cliente FTP de consola

1.Abre una terminal en tu sistema. 
- Desde Linux/Mac, abre el terminal del sistema
- Desde Windows, abre el "Símbolo del sistema" o "PowerShell". Puedes hacerlo buscando "cmd" o "PowerShell" en el menú de inicio o escribiendo "cmd" en la barra de búsqueda.

2.En la terminal, escribe el siguiente comando para iniciar una sesión FTP. Debes reemplazar *nombre_de_host_ftp* con la dirección IP PÚBLICA o el nombre de dominio del servidor FTP al que deseas conectarte:

```
ftp nombre_de_host_ftp
```

3. Una vez que ingreses el comando, el cliente FTP intentará establecer una conexión con el servidor. Si la conexión es exitosa, verás un mensaje similar a este:

```
Connected to nombre_de_host_ftp.
220 (nombre_del_servidor_ftp) FTP server ready
Name (nombre_de_host_ftp:tu_nombre_de_usuario_ftp):
```

4. A continuación, el cliente FTP te pedirá que ingreses un usuario (en nuestro caso recuerda que era **usuftp**)  y presiona "Enter". Luego, se te pedirá que ingreses la contraseña (recuerda que era **usuftp**). Si las credenciales son correctas, deberías obtener acceso al servidor FTP. Verifica que el prompt a cambiado a ftp> (quiere decir que has conectado correctamente).

#### Acceso con Cliente FTP gráfico 

Vamos a utilizar como **cliente FTP** con entorno gráfico a [Filezilla](https://filezilla-project.org/), que dispone de versiones para GNU/Linux, Mac OS X y Windows. Tras descargar <U>**el cliente FTP**</u> en nuestro ordenador, introducimos los datos necesarios para conectarnos a nuestro servidor FTP en Debian:

![](../img/ftp1.png)

+ La IP de Debian (recuadro rojo)
+ El nombre de usuario de Debian (recuadro verde)
+ La contraseña de ese usuario (recuadro fucsia)
+ El puerto de conexión, que será el 21 para conectarnos utilizando los certificados generados previamente (recuadro marrón)

Tras darle al botón de *Conexión rápida*, nos saltará un aviso a propósito del certificado, le damos a aceptar puesto que no entraña peligro ya que lo hemos genrado nosotros mismos:

![](../img/ftp2.png)

Nos conectaremos directamente a la carpeta que le habíamos indicado en el archivo de configuración `/home/raul/ftp`

Una vez conectados, buscamos la carpeta de nuestro ordenador donde hemos descargado el *.zip* (en la parte izquierda de la pantalla) y en la parte derecha de la pantalla, buscamos la carpeta donde queremos subirla. Con un doble click o utilizando *botón derecho > subir*, la subimos al servidor.

![](../img/ftp3.png)

Si lo que quisiéramos es conectarnos por **SFTP**, exactamente igual de válido, haríamos:

![](../img/ftp5.png)

Fijáos que al utilizar las claves de SSH que ya estamos utilizando desde la Práctica 1, no se debe introducir la contraseña, únicamente el nombre de usuario.

Puesto que nos estamos conectando usando las claves FTP, nos sale el mismo aviso que nos salía al conectarnos por primera vez por SSH a nuestra Debian, que aceptamos porque sabemos que no entraña ningún peligro en este caso:

![](../img/ftp6.png)

![](../img/ftp7.png)

Y vemos que al ser una especie de conexión SSH, nos conecta al `home` del usuario, en lugar de a la carpeta `ftp`. A partir de aquí ya procederíamos igual que en el otro caso.

Recordemos que debemos tener nuestro sitio web en la carpeta `/var/www` y darle los permisos adecuados, de forma similiar a cómo hemos hecho con el otro sitio web. 

El comando que nos permite descomprimir un *.zip* en un directorio concreto es:

```sh
unzip archivo.zip -d /nombre/directorio
```

Si no tuvieráis unzip instalado, lo instaláis:

```sh
sudo apt-get update && sudo apt-get install unzip
