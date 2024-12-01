---
title: 'Práctica 4 - Carga de datos en servidor LDAP mediante ficheros ldif'
---

# Práctica 4 - Carga de datos en servidor LDAP mediante ficheros ldif

## Introducción

Hasta ahora hemos creado usuarios y grupos de forma gráfica. Vamos a ver cómo podemos crearlos también en modo comando haciedo uso de archivos ldif. Esta forma será mucho más rápida cuando necesitemos crear gran cantidad de entradas.

Para esta práctica crearemos un nuevo servidor LDAP.

Para empezar, entra en AWS Academy y crea un nuevo EC2 Debian con estas características. 

* Llámale ServidorLDAP2.
* Dale los recursos que te ofrece por defecto.
* Puedes usar el grupo de seguridad de la práctica anterior ServidorLDAP.
* Arranca la máquina y actualízala para que cuente con las últimas versiones de todos los paquetes.

Instala OpenLDAP igual que hicimos en la práctica anterior y ejecuta el comando de reconfiguración.

```sh
sudo dpkg-reconfigure slapd
```

En este caso usa `proyecto-empresa.local` para "DNS Domanin Name" y para "Organization name". Usa como password de administrador "ieselcaminas".

Comprueba con slapcat que se ha creado la base de datos y podemos empezar a trabajar.

## Creación de objetos

Empezaremos creando 2 unidades organizativas "ou". Crea un archivo `estructura_basica.ldif` con el siguiente contenido:


```conf
# Usuarios
dn: ou=usuarios,dc=proyecto-empresa,dc=local
objectClass: organizationalUnit
ou: usuarios

# Grupos
dn: ou=grupos,dc=proyecto-empresa,dc=local
objectClass: organizationalUnit
ou: grupos
```

Fíjate en el contenido. Primero definimos en dn de cada unidad organizativa. Luego decimos el tipo de objectClass de que se trata y finalmente definimos el ou.

Ahora vamos a incorporar esa información a la base de datos con el siguiente comando:

```sh
$ ldapadd -x -D cn=admin,dc=proyecto-empresa,dc=local -w ieselcaminas -f estructura_basica.ldif
adding new entry "ou=usuarios,dc=proyecto-empresa,dc=local"
adding new entry "ou=grupos,dc=proyecto-empresa,dc=local"`
```

Identifica los distintos parámetros del comando para saber lo que estás haciendo.

Podemos comprobar que se han añadido después de cada comando con `slapcat`. También puedes instalar phpldapadmin e ir comprobando gráficamente lo que vas haciendo.

Ya tenemos creadas nuestras 2 ou. Ahora vamos a crear los grupos dentro de la ou=grupos. Crea un fichero `grupos.ldif` con este contenido:

```conf
#Grupo profesores
dn: cn=profesores,ou=grupos,dc=proyecto-empresa,dc=local
objectClass: posixGroup
cn: profesores
gidNumber: 10000

#Grupo alumnos
dn: cn=alumnos,ou=grupos,dc=proyecto-empresa,dc=local
objectClass: posixGroup
cn: alumnos   
gidNumber: 10001
```

Recuerda que antes de asignar el gid a los grupos hemos de comprobar en `/etc/group` que dicho uid no está ya asignado a algún usuario local.

Y los añadimos mediante:

```sh
$ ldapadd -x -D cn=admin,dc=proyecto-empresa,dc=local -w ieselcaminas -f grupos.ldif
adding new entry "cn=profesores,ou=grupos,dc=proyecto-empresa,dc=local"

adding new entry "cn=alumnos,ou=grupos,dc=proyecto-empresa,dc=local"
```

Ahora crearemos los usuarios de los profesores. Crea el siguiente archivo y llámale `profesores.ldif`.

```conf
# Profe01
dn: uid=profe01,ou=usuarios,dc=proyecto-empresa,dc=local
objectClass: inetOrgPerson
objectClass: posixAccount
uid: profe01
cn: profe01
sn: DAW
loginShell: /bin/bash
uidNumber: 1001
gidNumber: 10000
homeDirectory: /home/profe01
gecos: Profe01 DAW
userPassword: 123456

# Profe02
dn: uid=profe02,ou=usuarios,dc=proyecto-empresa,dc=local
objectClass: inetOrgPerson
objectClass: posixAccount
uid: profe02
cn: profe02
sn: DAW
loginShell: /bin/bash
uidNumber: 1002
gidNumber: 10000
homeDirectory: /home/profe02
gecos: Profe02 DAW
userPassword: 123456
```

Recuerda que antes de asignar el uid a los usuarios hemos de comprobar en `/etc/passwd` que dicho uid no está ya asignado a algún usuario local.

Los añadiremos con:

```sh
$ ldapadd -x -D cn=admin,dc=proyecto-empresa,dc=local -w ieselcaminas -f profesores.ldif 
adding new entry "uid=profe01,ou=usuarios,dc=proyecto-empresa,dc=local"

adding new entry "uid=profe02,ou=usuarios,dc=proyecto-empresa,dc=local"
```

Crea tu y añade ahora un par de alumnos. Llámales alu01 y alu02. Dales uid a partir del 2001 y fíjate que su gid debe ser el 10001.

## Modificación de objetos

También podemos modificar objetos ya creados con ficheros ldif. Vamos a cambiar la contraseña de un usuario.

Crea el fichero `cambiar_usuario.ldif` con el siguiente contenido.

```sh
# Cambiar contraseña Usuario
dn: uid=alu01,ou=usuarios,dc=proyecto-empresa,dc=local
changetype: modify
replace: userPassword
userPassword: 654321
```

Y la cambiamos con:

```sh
$ ldapmodify -x -D cn=admin,dc=proyecto-empresa,dc=local -w ieselcaminas -f cambiar_usuario.ldif 
modifying entry "uid=alu01,ou=usuarios,dc=proyecto-empresa,dc=local"
```

## Búsqueda

También podemos hacer búsquedas en la base de datos de forma rápida.

Para buscar a todos los profesores:

```sh
ldapsearch -x -b dc=proyecto-empresa,dc=local "(uid=*profe*)"
```

O para buscar el profesor que tiene un uid concreto

```sh
$ ldapsearch -x -b dc=proyecto-empresa,dc=local "(uidNumber=1002)"
```

Para buscar profes con gid 10001 usaríamos esta consulta. Lógicamente no encontrará ningún resultado.

```sh
$ ldapsearch -x -b dc=proyecto-empresa,dc=local "(&(uid=*profe*)(gidNumber=10001))"
```

## Borrar registros.

Podemos borrar registros con el comando `ldapdelete`.

Borremos el usuario alu02

```sh
$ ldapdelete -x -D cn=admin,dc=proyecto-empresa,dc=local -w ieselcaminas uid=alu02,ou=usuarios,dc=proyecto-empresa,dc=local
```

Con esto ya hemos visto las acciones básicas que podemos hacer con comandos y ficheros ldif en un servidor OpenLDAP.

!!!Información
    Los comandos anteriores poseen la opción -h con la cual se puede indicar el host (nombre de dominio o IP) que identifica al servidor LDAP. Por ejemplo: ldapsearch -h 192.168.200.250 -x -b dc=proyecto-empresa,dc=local "(objectclass=*)" conectaría con el servidor LDAP en la IP 192.168.200.250 para buscar el DIT del dominio proyecto-empresa.local.

    Existe un paquete de nombre ldapscripts que contiene una serie de scripts para administrar de forma sencilla los usuarios y grupos almacenados en el servidor LDAP. Puedes encontrar plantillas de ejemplo, formato LDIF, situadas en /usr/share/doc/ldapscripts/examples/ cuando se instala el paquete ldapscripts.

## Referencias

[Servicios de red implicados en el despliegue de una aplicación web.](https://sarreplec.caib.es/pluginfile.php/10993/mod_resource/content/2/DAW05_v1/ArchivosUnidad/Moodle/DAW05_completa_offline/DAW05_Contenidos/index.html)