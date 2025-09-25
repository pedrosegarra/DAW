---
title: 'Práctica 7 - Autenticación Apache contra LDAP dockerizada'
---

# Práctica 7 - Autenticación Apache contra LDAP dockerizada

Ya hemos aprendido a dockerizar OpenLDAP y también hemos aprendico a autenticar un Apache2 contra un servidor openLDAP. Ahora nos queda juntar ambas cosas.

!!! Atención
    Antes de seguir hemos de asegurarnos que hemos hecho y tenemos corriendo el servidor OpenLDAP de la "Práctica 5 - Dockerización de servidor LDAP". Además, debemos haber creado en ese servidor OpenLDAP dockerizado los mismos usuarios que creamos en la práctica "Práctica 3 - Configuración de un servidor LDAP" (al menos profe01)

La imagen oficial de apache2 en Docker Hub (httpd), no tiene instalado el módulo ldap, así que usaremos una imagen docker que si lo tiene instalado y es fácil de activar.

Vamos a reproducir en docker exactamente lo mismo que hicimos en la "Práctica 6 - Autenticación Apache contra LDAP"

Empezaremos creando un fichero Dockerfile como este, que deberás completar:

```
____ php:7-apache

# Activamos el módulo LDAP de Apache ejecutando el siguiente comando
____ a2enmod authnz_ldap

# Creamos el directorio test como en la práctica anterior
____ mkdir -p /var/www/html/test

# Copiamos los ficheros como los de la práctica anterior
____ index.html /var/www/html/test/index.html

____ 000-default.conf /etc/apache2/sites-enabled/000-default.conf

```

El fichero index.html podemos usar el siguiente:

```
<!DOCTYPE html>
<html>
<head>
<title>Sitio LDAP!</title>
</head>
<body>
<h1>Bienvendido al sitio validado por LDAP!</h1>
</body>
</html>
```

Y el fichero 000-default.conf usaremos uno como este:

```
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        <Directory "/var/www/html/test"> 
        AuthType Basic
        AuthName "Apache LDAP authentication"
        AuthBasicProvider ldap 
        AuthLDAPURL "ldap://ldap-service/ou=usuarios,dc=daw,dc=ieselcaminas?uid?sub" 
        AuthLDAPBindDN "cn=admin,dc=daw,dc=ieselcaminas"
        AuthLDAPBindPassword ieselcaminas
        Require valid-user
        </Directory>

</VirtualHost>
```

Fíjate que es igual que el de la práctica anterior salvo que hemos modificado la línea `AuthLDAPURL "ldap://ldap-service/ou=usuarios,dc=daw,dc=ieselcaminas?uid?sub" `. En la anterior usamos `AuthLDAPURL "ldap://127.0.0.1/ou=usuarios,dc=daw,dc=ieselcaminas?uid?sub" ` porque el servidor ldap estaba en el mismo equipo. Ahora está en otro contenedor y nos referiremos a él por su "hostname" que definimos en docker.

Cuando ya lo tengamos todo podemos crear nuestra imagen particularizada. Llámale my-apache2-

Después lanzamos el contenedor con:

```
docker run \
    --net ldap-network \
    --name apache2_server \
    -d \
    -p80:80 \
    my-apache2
```

Fíjate que usamos la misma red docker que usamos para el contenedor ldap en la práctica anterior y que eso les permite comunicarse.

Ahora accede desde un navegador a `http://IPSERVER/test` te debería solicitar la autenticación por ldap y al usar "profe01" nos debería permitir el acceso.

## Pasando información al contenedor mediante variables de entorno

Si te fijas hemos incluido los datos del usuario ldap dentro del propio Dockerfile y al crear la imagen, estos quedan dentro de la misma. ¿Y si quisiéramos crear una imagen que nos permitiera autenticar contra cualquier servidor ldap pasando los datos del servidor en el "docker run" mediante variables de entorno?

Vamos a borrar el contenedor "apache2_server" y la imagen "my-apache2". Modifiquemos el fichero `000-default.conf` así:

```
PassEnv LDAP_BIND_ON
PassEnv LDAP_PASSWORD
PassEnv LDAP_URL
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        <Directory "/var/www/html/test">
        AuthType Basic
        AuthName "Apache LDAP authentication"
        AuthBasicProvider ldap
        AuthLDAPBindDN ${LDAP_BIND_ON}
        AuthLDAPBindPassword ${LDAP_PASSWORD}
        AuthLDAPURL ${LDAP_URL}
        Require valid-user
        </Directory>

</VirtualHost>
```

En las primeras filas ahora definimos 3 variables, que serán las que recibirá como variables de entorno en el "docker run" y más abajo incluimos con ${} donde se incluirá el valor de dichas variables que recibamos del "docker run". Volvemos a crear la imagen y ahora lanzamos el contenedor así:

```
docker build -t my-apache2 .

docker run -d \
    --name apache2_server \
    --net ldap-network \
    -d \
    -p80:80 \
    -e LDAP_BIND_ON='cn=admin,dc=daw,dc=ieselcaminas' \
    -e LDAP_PASSWORD='ieselcaminas' \
    -e LDAP_URL='ldap://ldap-service/ou=usuarios,dc=daw,dc=ieselcaminas?uid?sub' \
    my-apache2
```

Comprueba como sigues pudiendo acceder a http://IPSERVER/test autenticando con profe01.
