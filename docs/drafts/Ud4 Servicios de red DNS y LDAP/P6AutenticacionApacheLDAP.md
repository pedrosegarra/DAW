---
title: 'Práctica 6 - Autenticación Apache contra LDAP'
---

# Práctica 6 - Autenticación Apache contra LDAP

!!! Nota
    Para esta práctica partiremos de la "Práctica 2 - Configuración de un servidor LDAP y autenticación en Apache". Asegúrate de tenerla funcionando antes de empezar.

Arranca la máquina que llamamos ServidorLDAP.

Ya hemos instalado nuestro servidor OpenLDAP y hemos aprendido a crear usuarios. La utilidad real de esos usuarios será usarlos para validarse al acceder a algún sistema. Uno de los usos más habituales es para acceder al sistema operativo en distintos ordenadores. Pero como nosotros estamos en despliegue de aplicaciones web vamos a usarlo para acceder a una zona de un servidor web Apache. El motivo de usar Apache es que ya se instaló al instalar phpldapadmin y que la autenticación es muy sencilla de configurar.

En primer lugar comprobaremos que el servicio `apache2` está funcionando.

Habilita el módulo de autenticación LDAP Apache2.

```sh
sudo a2enmod authnz_ldap
```

Vamos a solicitar la autenticación a los usuarios que intentan acceder a un directorio denominado `test`.

Crea un directorio denominado `test` y crea dentro un archivo index.html. Cambia el usuario y grupo del directorio `test` y su contenido a www-data.

```sh
sudo mkdir /var/www/html/test
sudo nano /var/www/html/test/index.html
sudo chown -R www-data:www-data /var/www/html/test 
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

Ahora vamos a editar el archivo de configuración Apache 000-default.conf. Antes haremos una copia de seguridad del mismo.

```sh
sudo cp /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf.backup
sudo nano /etc/apache2/sites-enabled/000-default.conf
```
Incluímos las líneas resaltadas:

```yaml hl_lines="7-15"
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        <Directory "/var/www/html/test"> 
        AuthType Basic
        AuthName "Apache LDAP authentication"
        AuthBasicProvider ldap 
        AuthLDAPURL "ldap://127.0.0.1/ou=usuarios,dc=daw,dc=ieselcaminas?uid?sub" 
        AuthLDAPBindDN "cn=admin,dc=daw,dc=ieselcaminas"
        AuthLDAPBindPassword ieselcaminas
        Require valid-user
        </Directory>

</VirtualHost>
```

Veamos las distintas directivas para qué sirven:

* **"<"Directory "/var/www/html/test">"** : Directorio al que vamos a aplicar la autenticación
* **AuthType Basic** : Define el método de autenticación: Básica (Basic). Necesario para la autenticación basada en LDAP
* **AuthName "Apache LDAP authentication"** : Especifica el texto que se mostrará en el cuadro de diálogo de autenticación del navegador (aunque en mis pruebas no lo muestra)
* **AuthBasicProvider ldap** : Indica que el proveedor de autenticación será LDAP
* **AuthLDAPURL "ldap://127.0.0.1/ou=usuarios,dc=daw,dc=ieselcaminas?uid?sub"** : Especifica cómo Apache se conecta al servidor LDAP. Lo veremos en detalle a continuación
* **AuthLDAPBindDN "cn=admin,dc=daw,dc=ieselcaminas"** : Especifica el DN del usuario que se autenticará en el servidor LDAP para buscar las entradas. Si en la configuración del tu servidor LDAP se permiten búsquedas anónimas no haría falta esta directiva
* **AuthLDAPBindPassword ieselcaminas** : Contraseña asociada al AuthLDAPBindDN. Si en la configuración del tu servidor LDAP se permiten búsquedas anónimas no haría falta esta directiva
* **Require valid-user** : Permite el acceso solo a usuarios que proporcionen credenciales válidas (en este caso, autenticadas por LDAP).



Las directivas AuthLDAPURL, AuthLDAPBindDN y AuthLDAPBindPassword son las que tendréis que cambiar según la situación. La sintaxis de AuthLDAPURL es la siguiente:

```conf
AuthLDAPURL ldap://host:port/basedn?attribute?scope?filter [NONE|SSL|TLS|STARTTLS]
```
Si desmenuzamos la sintaxis:

* **host y port** son evidentes

* **basedn** es la ruta en el DIT (recuerda, el árbol) a partir de donde buscar los usuarios

* **attribute**, define el nombre atributo que contiene el nombre del usuario (normalmente uid)

* **scope**, puede ser *one* (para buscar en un subnivel a partir del basedn) o *sub* (para buscar en todos los subniveles)

* **filter**, filtro opcional de búsqueda, por ejemplo: (&(objectClass=inetOrgPerson)(description=*#*test*))

* [NONE|SSL|TLS|STARTTLS], parámetro opcional definiendo el tipo de conexión, por defecto NONE.

Recuerda reiniciar `apache2` para que se apliquen los cambios.

Ahora ya solo nos queda probar el funcionamiento. Abre una ventana privada de navegador en tu ordenador. Deberás abrir una ventana privada para cada prueba.

Accede a `http://IPSERVER/test`.

Te debería pedir un usuario y contraseña. Prueba con `profe01` y la contraseña que le pusiste antes. Luego abre una ventana privada y prueba con una contraseña incorrecta.

## Preparando la dockerización

A la hora de levantar un servicio en docker sabemos que es más fácil copiar archivos al interior del contenedor que modificar ficheros de cofiguración que están dentro del mismo. 

Pensemos también que el fichero de configuración del sitio lo tiene que actualizar el administrador, mientras que los ficheros del sitio los pueden modificar los propietarios del sitio, sin permisos de administrador. Por eso apache nos permite configurar algunas cosas mediante la inclusión de un fichero `.htaccess`, en este caso en `/var/www/html/test/`.

Para ello el administrador solo debería hacer lo siguiente. Recuperaremos el fichero de configuración original:

```sh
sudo cp /etc/apache2/sites-enabled/000-default.conf.backup /etc/apache2/sites-enabled/000-default.conf
```

Dejaremos el bloque "Directory" así:

        <Directory "/var/www/html/test">
                AllowOverride All
        </Directory>

Esto le indica a Apache que permita sobrecargar las configuraciones a través de archivos `.htaccess` dentro de ese directorio. Aquí acaba la tarea del administrador.

Ahora el editor del sitio web creas un archivo `.htaccess` dentro de `/var/www/html/test` con este contenido:

        AuthType Basic
        AuthName "Apache LDAP authentication"
        AuthBasicProvider ldap
        AuthLDAPURL "ldap://127.0.0.1/ou=usuarios,dc=daw,dc=ieselcaminas?uid?sub"
        AuthLDAPBindDN "cn=admin,dc=daw,dc=ieselcaminas"
        AuthLDAPBindPassword ieselcaminas
        Require valid-user

Fíjate que sólo estamos trasladando las directivas que antes estaban en `/etc/apache2/sites-enabled/000-default.conf` a `.htaccess`. 

Ojo con los permisos de `.htaccess`. Se encuentra en un directorio con el resto de archivos html del sitio web y contiene usuario y password de acceso al servidor LDAP, que es información sensible. Por eso es mejor sacar la autenticación Bind (es decir, el usuario y contraseña de LDAP) del fichero .htaccess. Para ello sacamos las directivas AuthLDAPBindDN ni AuthLDAPBindPassword y las configuramos en `/etc/ldap/ldap.conf` (en sistemas basados en Debian/Ubuntu). Este fichero sirve para centralizar toda la configuración de LDAP.

Por tanto creamos `/etc/ldap/ldap.conf` con este contenido:

        # Opciones de conexión
        BINDDN cn=admin,dc=daw,dc=ieselcaminas
        BINDPW ieselcaminas


Y dejamos `/var/www/html/test/.htaccess` así:

        AuthType Basic
        AuthName "Apache LDAP authentication"
        AuthBasicProvider ldap
        AuthLDAPURL "ldap://127.0.0.1/ou=usuarios,dc=daw,dc=ieselcaminas?uid?sub"
        Require valid-user

Reinicia apache e intenta acceder nuevamente a la web. Comprueba nuevamente el correcto funcionamiento.

!!! Nota
        Sacar la configuración a los archivos `.htaccess` y `ldap.conf` es una alternativa que puede ser útil en ocasiones. No es mejor ni peor. Solo debemos conocerla y usar una u otra forma según las necesidades de cada caso.
