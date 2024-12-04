---
title: 'Práctica 8 - Autenticación Nginx contra LDAP'
---

# Práctica 8 - Autenticación Nginx contra LDAP

En esta práctica vamos a autenticar el acceso en Nginx usando un servidor LDAP.

Partiremos de que tenemos configurado y ejecutándose el servidor LDAP que configuramos en la 'Práctica 2 - Configuración de un servidor LDAP y autenticación en Apache'. Obtén la IP pública de dicho servidor que nos hará falta para la configuración

También necesitaremos un servidor Nginx instalado en otra EC2. Puedes usar la máquina "servidorNginx" de la unidad de Servidores WEb o crear una nueva EC2 en AWS para instalar un servidor Nginx nuevo.

Crearemos un sitio virtual "sitioldap" junto a los anteriores:

```
sudo mkdir -p /var/www/sitioldap
sudo nano /var/www/sitioldap/index.html
```

Incluye lo siguient en index.html

    <!DOCTYPE html>
    <html>
    <head>
    <title>Sitio LDAP!</title>
    </head>
    <body>
    <h1>Bienvendido al sitio validado por LDAP!</h1>
    </body>
    </html>

Ahora crea el sitio virtual

```
sudo nano /etc/nginx/sites-available/sitioldap
```

Contenido del archivo, de momento sin autenticación:

```
server {
    listen 80;
    server_name sitioldap;
    root /var/www/sitioldap;
    index index.html;

    location / {
         try_files $uri $uri/ =404;
    }
}
```

Activamos el sitio virtual

```
sudo ln -s /etc/nginx/sites-available/sitioldap /etc/nginx/sites-enabled/
```

Verificamos la configuración de nginx

```
sudo nginx -t
```

Reiniciamos el servicio

```
sudo systemctl restart nginx
```

Y accedemos a `http://sitioldap`. Recuerda que habrás de modificar el fichero `/etc/hosts` para poder acceder. Comprueba que tienes acceso a la web sin aplicar la configuración de LDAP antes de continuar.

### Carga del módulo de autenticación LDAP.

Hay diversas formas de autenticar LDAP en NGINX. Si estás utilizando una distribución de Nginx que incluye soporte para módulos dinámicos, verifica si tienes el módulo **ngx_http_auth_ldap_module**. Puedes comprobar si está el módulo en `/etc/nginx/modules-available`.

Si no está, como es el caso de nuestra Debian, tendremos que instalarlo. Este módulo está disponible en Github para descargarlo y compilarlo [aquí](https://github.com/jessp01/nginx-auth-ldap). Para simplificarte esta tarea puedes descargar el .deb ya compilado [aquí](P5/libnginx-mod-http-auth-ldap_1.0.0-1_amd64.deb).

Puedes instalarlo con

```
sudo dpkg -i libnginx-mod-http-auth-ldap_1.0.0-1_amd64.deb
```

Una vez instalado verás el módulo disponible en `/etc/nginx/modules-enabled`.

```
$ ls -la /etc/nginx/modules-enabled/
lrwxrwxrwx 1 root root   58 Nov 27 19:01 50-mod-http-auth-ldap.conf -> /usr/share/nginx/modules-available/mod-http-auth-ldap.conf
```

Ahora ya podemos proceder a activar la autenticación. Primero añade un bloque ldap_server en la sección http de tu configuración de Nginx. Este define cómo se conecta Nginx al servidor LDAP para autenticar usuarios. En `/etc/nginx/nginx.conf` :

```
http {
    ldap_server mi_servidor_ldap {
        url ldap://IPSERVIDOR/ou=usuarios,dc=daw,dc=ieselcaminas?uid?sub;
        binddn "cn=admin,dc=daw,dc=ieselcaminas";
        binddn_passwd "ieselcaminas";
        group_attribute member;
        group_attribute_is_dn on;

        require valid_user;
    }

    include /etc/nginx/sites-enabled/*;
}
```

Cambia IPSERVIDOR por la IP externa de la máquina virtual con el servidor LDAP.

Fíjate que el bloque `ldap-server` ha de estar antes de la directiva `include /etc/nginx/sites-enabled/*` para que el servidor esté configurado antes de hacer uso de él en la configuración del sitio virtual. Vamos a ella. Modifica `/etc/nginx/sites-available/sitioldap` así:

```
server {
    listen 80;
    server_name sitioldap;
    root /var/www/sitioldap;
    index index.html;

    # Configuración LDAP
    location / {
        try_files $uri $uri/ =404;
        auth_ldap "Protected Area";
        auth_ldap_servers mi_servidor_ldap;
    }
}
```

Antes de nada prueba que las configuraciones son correctas con:

```
sudo nginx -t
```

Si no hay errores puedes recargar el servidor Nginx y acceder a `http://sitioldap` y comprobar si la autenticación LDAP funciona. Recuerda que creamos varios usuarios como "profe01/profe01" para probar.


## Módulos en NGINX

En esta práctica hemos necesitado instalar un módulo adicional en NGINX.

En [esta página](https://deb.myguard.nl/nginx-modules/) puedes encontrar multitud de módulos para instalar. La mayoría de ellos se encuentran en git y deben ser descargados y compilados.

Ya sabes usar git para clonar un repositorio remoto, así que esa parte no debería suponerte ningún problema. Para compilarlos sigue las instrucciones incluidas en cada uno de ellos.

En el caso del módulo que hemos tenido que usar en esta práctica, `nginx-auth-ldap`, puedes acceder en https://github.com/jessp01/nginx-auth-ldap.

Este módulo ofrece la opción de compilarlo dentro del propio binario de nginx o, en el caso de Debian/Ubuntu, crear un paquete .deb y después instalarlo. Nosotros hemos usado la segunda opción. Siguiendo las instrucciones del módulo lo hemos descargado con un `git clone`, hemos entrado en la carpeta que se ha creado y hemos ejecutado los comandos que nos indica:

```
sudo apt install build-essential dpkg-dev libssl-dev libldap2-dev
cd /path/to/nginx-auth-ldap/source
dpkg-buildpackage -b -uc
sudo dpkg -i ../libnginx-mod-http-auth-ldap_1.0.0-1_amd64.deb
```

En nuestro debian, al ejecutar `dpkg-buildpackage -b -uc` obtenemos un error, debido a un problema de dependencias. Hemos de actualizar el sistema y verificar que tenemos los repositorios contrib y non-free habilitados en tu archivo /etc/apt/sources.list.

    sudo apt update

Instala las herramientas de desarrollo y las dependencias faltantes:

    sudo apt install -y build-essential debhelper dh-sequence-nginx

Después de esto ya puedes continuar con el paso que daba error.
