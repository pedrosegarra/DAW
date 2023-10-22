# Permisos 
Dentro de un servicio FTP, uno de los pasos importantes es el de conceder permisos determinados para controlar el acceso al servidor o a los diferentes directorios. El protocolo FTP sigue los permisos establecidos en entornos de tipo UNIX y sus similares GNU/Linux.

Por otro lado, los permisos también son una parte importante de la configuración del servicio FTP para poder restringir la lectura y escritura a usuarios que entran al sistema desde el exterior, dando siempre los mínimos permisos a los usuarios y siempre a carpeta concretas para que no puedan acceder a información a la que no están autorizados.

## Nivel de acceso
En Linux existen tres niveles de acceso a ficheros y carpetas:
- Propietario(user=u): permisos asignados al propietario del archivo o directorio.
- Grupo(group=g): permisos asignados a los grupos de usuarios.
- Otros(others=o): permisos asignados a otros usuarios existentes en el sistema operativo que no son ni propietarios ni pertenecen a un grupo.

## Tipos de permisos

Cada grupo a su vez puede tener tres permisos:
- Lectura (r): se puede ver el contenido, visualizar un fichero o un directorio. 
- Escritura (w): se puede modificar el contenido del archivo o directorio.
- Ejecución (x): se puede ejecutar el archivo.
- La ausencia de permiso es identificada con el carácter '-'. 

Cada permiso tiene un equivalente numérico en el sistema octal, así poe ejemplo: r=4, w=2, x=1 y -=0. Por ejemplo: rw- identifica permiso de lectura y escritura o lo que es lo mismo 4+2+0=6

En un sistema operativo tipo GNU/Linux mediante el comando `ls -l` puedes ver los permisos asignados a ficheros y directorios.

El modo octal relacionado con los permisos es el siguiente:

**falta tabla**

### Veamos un ejemplo:

Estos tres permisos se pueden aplicar a los tres niveles anteriores, en la siguiente pantalla se puede ver un ejemplo.

**IMAGEN DEL EJEMPLO**

El primer carácter indica el *tipo de archivo* de la siguiente manera: 
- d: directorio.
- guión (-): fichero.
- l: enlace (link).
- b: archivo binario.
- p: archivo especial de tubería (pipe).
- c: archivo de caracteres especiales (por ejemplo una impresora).

El resto son 9 caracteres, indican los *permisos en cada uno de los grupos*, por ejemplo: rwxr-xr-x en tres grupos.
- Primer grupo son los permisos del *Propietario (user)* del directorio o archivo.
- Segundo grupo son los permisos del *Grupo (group)*.
- Tercer grupo son los permisos del resto u *Otros (others)* usuarios del sistema operativo.

Después aparece un número que indica el *número de enlaces al archivo.*
- La siguiente columna es el nombre de usuario propietario del archivo o directorio.
- La siguiente es el nombre del grupo al que pertenece el archivo.
- Las siguientes columnas son el tamaño y la fecha y hora de la última modificación del archivo o directorio.
- La última columna es el nombre del directorio o archivo.

### Comando chmod
Para asignar permisos en Linux se usa el comando chmod que puede modificar los permisos siguientes:
- Propietario (u) 
- Grupos (g)
- Otros (o)

La sintaxis general es: 
`
chmod [opciones] modo-octal fichero
`
Por ejemplo, si se quiere asignar permisos de lectura (r) y escritura (w) al fichero prueba1.txt solamente al usuario propietario podemos utilizar cualquiera de los dos comandos siguientes:
`chmod 600 prueba1.txt` 
`chmod u+rw prueba1.txt`
**IMAGEN DEL EJEMPLO**

### Comando chown

Este comando se utiliza para cambiar el propietario del archivo o directorio se usa el comando chown. La sintaxis general es: 
`chown [opciones] [usuario] [:grupo] ficheros`

Por ejemplo, si se quiere hacer propietario a usuario1 del fichero prueba.txt el comando a utilizar sería: `chown usuario1 prueba.txt`
**IMAGEN DEL EJEMPLO**

> Por otro lado en un sistema GNU/Linux, en principio, no todos los usuarios del sistema tienen acceso por ftp, así existe un fichero **/etc/ftpusers** que contiene una lista de usuarios que no tienen permiso de acceso por FTP. Por razones de seguridad al menos los siguientes usuarios deberían estar listados en este fichero: root, bin, uucp, news. Ten en cuenta que las líneas en blanco y las líneas que comiencen por el carácter '#' serán ignoradas.






