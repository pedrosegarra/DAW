---
title: 'Práctica 5.1 - Configuración de un servidor DNS'
---

# Práctica 5.1 - Configuración de un servidor DNS

!!!note "Nota importante"
    Es muy importante que antes de empezar esta práctica eliminéis las entradas que habéis ido introduciendo hasta ahora en vuestro archivo ```/etc/hosts``` para asegurarnos que realmente la resolución de nombres va a nuestro servidor DNS. Si no hacéis esto, resolverá los nombres, pensaréis que está bien pero en realidad estará mal.

## Creación de la máquina virtual

Para empezar, entra en AWS Academy y crea un nuevo EC2 Debian con estas características. 

* Llámale P5ServidorDNS.
* Dale los recursos que te ofrece por defecto.
* Crea un Grupo de seguridad con el nombre P5ServidorDNS y abre los puertos necesarios para que una máquina externa pueda consultarlo.
* Arranca la máquina y actualízala para que cuente con las últimas versiones de todos los paquetes.

Para esta práctica es interesante que nuestro servidor DNS tenga una IP fija y no cambie cada vez que arranquemos nuestro servidor. 

En Amazon Web Services (AWS), las direcciones IP elásticas se utilizan para proporcionar direcciones IP fijas a instancias de Amazon EC2 u otros recursos de AWS. Aquí hay una guía básica para asignar una dirección IP elástica a una instancia de EC2 en AWS:

1. Inicia sesión en la Consola de AWS.
  
2. Ve al panel de EC2.

3. En el panel de navegación izquierdo, haz clic en "Direcciones IP elásticas" bajo "Redes y Seguridad".

4. Asigna una nueva dirección IP elástica:

    1. Haz clic en "Asignar la dirección IP elástica".
        Simplemente haz clic en "Asignar" para obtener una nueva.

5. Asocia la dirección IP elástica a una instancia:

    1. Selecciona la dirección IP elástica recién creada.
    
    2. Haz clic en "Acciones" y selecciona "Asociar la dirección IP elástica".
    
    3. Selecciona la instancia a la que deseas asignar la dirección IP elástica y haz clic en "Associate". Asígnala a la instancia, no a la IP privada.
     
Después de estos pasos, la instancia de EC2 tendrá una dirección IP elástica asociada, proporcionándote una IP fija para esa instancia. Ten en cuenta que las direcciones IP elásticas no son gratuitas cuando no están asociadas a una instancia en ejecución, por lo que es una buena práctica desasociarlas y liberarlas cuando no las estás utilizando.
  
## Herramientas de diagnóstico de resolución de nombres.

Los programas `dig`, `host` y `nslookup` son herramientas de línea de comandos para realizar consultas a servidores de nombres. 

* `dig`

    `dig` es la herramienta más versátil y completa de estas utilidades de consulta. Tiene dos modos: un modo interactivo simple para una sola consulta y un modo por lotes que ejecuta una consulta para cada línea en una lista de varias líneas de consulta.

* `host`

    La utilidad `host` enfatiza la simplicidad y facilidad de uso. Por defecto, convierte entre nombres de host y direcciones de Internet-

* `nslookup`

    `nslookup` tiene dos modos: interactivo y no interactivo. El modo interactivo permite al usuario consultar servidores de nombres para obtener información sobre varios hosts y dominios, o imprimir una lista de hosts en un dominio. El modo no interactivo se utiliza para imprimir solo el nombre y la información solicitada para un host o dominio.

Para instalar estas herramientas en nuestra Debian usaremos: 

```sh
sudo apt-get install dnsutils 
```

Comprobemos primero cuál es el servidor de nombres que tenemos configurado en nuestra EC2. Podemos saberlo con: 

```sh
$ cat /etc/resolv.conf 
...

nameserver 172.31.0.2
search .
```

Toma nota de la IP del "nameserver", es decir, la IP del equipo al que nuestra máquina enviará las consultas de resolución de nombres. En este caso nuestro DNS es 172.31.0.2.

Vamos a probar con `host`.

```sh
$ host cisco.com
cisco.com has address 72.163.4.185
cisco.com has IPv6 address 2001:420:1101:1::185
cisco.com mail is handled by 30 aer-mx-01.cisco.com.
cisco.com mail is handled by 10 alln-mx-01.cisco.com.
cisco.com mail is handled by 20 rcdn-mx-01.cisco.com.
```

La salida es simple. Nos responde con los registros. En muchos casos esta información es más que suficiente. Aunque no sabemos qué servidor DNS nos está dando la respuesta, si es autoritativa o no. Para nuestras pruebas se queda un poco corto.

Probemos ahora con `dig`.

```yaml hl_lines="15 18"
$ dig cisco.com

; <<>> DiG 9.18.19-1~deb12u1-Debian <<>> cisco.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 57177
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;cisco.com.			IN	A

;; ANSWER SECTION:
cisco.com.		111	IN	A	72.163.4.185

;; Query time: 3 msec
;; SERVER: 172.31.0.2#53(172.31.0.2) (UDP)
;; WHEN: Sat Nov 25 08:30:24 UTC 2023
;; MSG SIZE  rcvd: 54
```

Vemos que obtenemos más información. No sólo nos devuelve la respuesta de la IP sino que además nos dice qué servidor DNS nos la está proporcionando.

Y finalmente vamos a probar con nslookup:

```yaml  hl_lines="3 7 8"
$ nslookup cisco.com 
Server:		172.31.0.2 #(1)
Address:	172.31.0.2#53 #(2)

Non-authoritative answer: #(3)
Name:	cisco.com
Address: 72.163.4.185 #(4)
Name:	cisco.com
Address: 2001:420:1101:1::185 #(5)
```

1. Servidor DNS que nos está dando la respuesta

2. IP y puerto del servidor DNS que nos da la respuesta

3. El servidor DNS que nos contesta no tiene autoridad sobre la zona 

4. La IP de cisco.com en IPv4

5. La IP de cisco. com en IPv6


Fíjate que en tu caso la IP de Server y Address pueden ser distintas si tu máquina virtual pregunta a un servidor DNS diferente. Prueba a ejecutar el mismo comando desde tu ordenador anfitrión (el de casa o el aula). ¿Coinciden los campos de Server y Address? ¿Y la IP de Cisco.com?

nslookup nos da una funcionalidad adicional. Podemos decirle cuál es el servidor DNS al que queremos consultar. Prueba a realizar la consulta anterior a un DNS de Google y observa la diferencia en la respuesta. Esto nos será muy útil para consultar a nuestro servidor DNS desde cualquier máquina que no lo tenga configurado como servidor DNS principal.

```yaml
$ nslookup cisco.com 8.8.8.8
Server:		8.8.8.8
Address:	8.8.8.8#53

Non-authoritative answer:
Name:	cisco.com
Address: 72.163.4.185
Name:	cisco.com
Address: 2001:420:1101:1::185
```
Esta consulta lo que está haciendo es buscar la información de DNS para el dominio "cisco.com" utilizando el servidor DNS público de Google, que tiene la dirección IP 8.8.8.8.

## Instalación de servidor DNS

Bind es el estándar de facto para servidores DNS. Es una herramienta de software libre y se distribuye con la mayoría de plataformas Unix y Linux, donde también se le conoce con el sobrenombre de named (name daemon). Bind9 es la versión recomendada para usarse y es la que emplearemos.

Para instalar el servidor DNS en un servidor Debian, usaremos los repositorios oficiales. Por ello, podremos instalarlo como cualquier paquete en Debian:

```sh
sudo apt-get install bind9 bind9utils bind9-doc 
```

Comprueba si el servicio bind 9 ya está funcionando.

Una vez instalado el servicio ya funcionará con las opciones básicas. 

En una prueba anterior hemos probado a preguntar al servidor DNS que tenemos configurado, pero lo que nos interesa ahora es preguntarle al que acabamos de instalar. Desde nuestro servidor Debian vamos a preguntarle al servidor bind9.

```yaml
$ nslookup cisco.com 127.0.0.1 #(1)
Server:		127.0.0.1
Address:	127.0.0.1#53

Non-authoritative answer:
Name:	cisco.com
Address: 72.163.4.185
Name:	cisco.com
Address: 2001:420:1101:1::185
```

1. Incluímos al final la IP del servidor al que queremos preguntar. Vemos como en Server y Address nos está contestando 127.0.0.1 que no es más que localhost, nuestra propia máquina. Comprobamos cómo nuestro servidor DNS y es capaz de darnos respuesta.

Prueba ahora a consultar a nuestro servidor DNS desde tu máquina anfitrión. Para ello deberás consultar a su IP pública. ¿Obtienes respuesta? ¿Por qué crees que obtienes esa respuesta? Lo veremos más adelante.

Una vez comprobado que nuestro servidor DNS está funcionando correctamente vamos a cambiar el DNS al que consulta nuestro servidor Debian en ```/etc/resolv.conf```. Sin embargo, este archivo puede ser gestionado automáticamente y sobrescrito por herramientas como `systemd-resolved` o `dhclient`. Para hacer cambios permanentes en los servidores DNS, es recomendable modificar la configuración en el lugar correspondiente.

Nuestro sistema usa `systemd-resolved`. Para cambiar la configuración DNS de forma permanente, edita el archivo de configuración `/etc/systemd/resolved.conf`. Dentro del archivo, busca la sección [Resolve] y agrega o modifica la línea DNS= con tus servidores DNS preferidos, separados por espacios. En nuestro caso usaremos la propia máquina 127.0.0.1.

```sh
[Resolve]
DNS=127.0.0.1
```

Reinicia systemd-resolved para aplicar la nueva configuración:

```bash
sudo systemctl restart systemd-resolved
```

Comprueba ahora que en `/etc/resolv.conf` tienes `nameserver=127.0.0.1` como primera opcion.

Prueba ahora a consultar la IP de cisco.com con `dig` y `nslookup` y comprueba que servidor te responde.

Es importante recordar aquí que no tenemos configurada en ninguna parte la IP de ningún servidor DNS externo. Por tanto, ¿cómo es capaz nuestro servidor de contestarnos cuando le preguntamos por la IP de cisco.com? Por defecto bind9 realizará una resolución iterativa, preguntando primero a ls servidores raiz de internet, si estos no tienen a los servidores TLD, después a los serfidores autoritativos de dominio.


## Configuración del servidor

<!-- 
Puesto que sólo vamos a utilizar IPv4, vamos a decírselo a Bind, en su archivo general de configuración, que es el siguiente:

```linuxconf
/etc/default/named
```

Y para indicarle que sólo use IPv4, debemos modificar la línea siguiente con el texto resaltado:

```linuxconf
OPTIONS = "-u bind -4"
```


En primer lugar vamos a repasar el fichero de configuración de bind ```/etc/default/named```:

```sh
$ cat /etc/default/named 
#
# run resolvconf?
RESOLVCONF=no

# startup options for the server
OPTIONS="-u bind"
```

La variable RESOLVCONF indica si BIND9 debe interactuar con resolvconf. Si está configurado en yes, BIND9 utilizará resolvconf para gestionar los archivos de configuración de resolución de DNS. Es decir, que lo que bind9 no sepa resolver se lo preguntará al servicio reslovconf igual que le pregunta cualquier otro programa, como el navegador web. Por eso, sin necesidad de configurar nada más, bind sabrá respondernos a cualquier pregunta de resolución. Aquellas que no sepa, las consultará a resolvconf.
-->

El archivo de configuración principal de Bind es:

```linuxconf
/etc/bind/named.conf
```

Si lo consultamos veremos lo siguiente:

```
$ cat /etc/bind/named.conf
// This is the primary configuration file for the BIND DNS server named.
//
// Please read /usr/share/doc/bind9/README.Debian for information on the
// structure of BIND configuration files in Debian, *BEFORE* you customize
// this configuration file.
//
// If you are just adding zones, please do that in /etc/bind/named.conf.local

include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.default-zones";
```

Este archivo sirve simplemente para aglutinar o agrupar a los archivos de configuración que usaremos. Estos 3 includes hacen referencia a los 3 diferentes archivos donde deberemos realizar la verdadera configuración, ubicados en el mismo directorio.

### configuración *named.conf.options*

Es una buena práctica que hagáis siempre una copia de seguridad de un archivo de configuración cada vez que vayáis a realizar algún cambio:

```sh
sudo cp /etc/bind/named.conf.options /etc/bind/named.conf.options.backup
```

Recuerda que si preguntabas antes con nslookup desde el propio servidor obteníamos respuesta pero si le hacemos la consulta desde nuestra máquina local nos daba "REFUSED". Esto es porque BIND9 solo permite consultas locales por defecto. Para permitir todas las solicitudes añadiríamos la directiva:

```sh
allow-query { any; };
```

Puedes comprobar que el archivo de configuración es correcto con:

```sh
sudo named-checkconf
```

Si no aparecen errores, entonces todo está en orden. Reinicia el servicio y prueba a consultar nuevamente desde tu máquina anfitrión. ¿Recibe ahora la respuesta esperada?

Con esta configuración básica ya hemos comprobado que nuestro servidor DNS está funcionando y respondiendo a peticiones de la propia máquina y de otras externas. 

#### Configuración como forwarder

Hemos visto que por defecto nuestro servidor hará consultas iterativas. Para que realice consultas recursivas preguntando a un servidor DNS configurado por nosotros, todo lo que se requiere es simplemente agregar los números de IP de los servidores DNS deseados.

Simplemente descomenta y edita lo siguiente en /etc/bind/named.conf.options:

```yaml
    forwarders {
            8.8.8.8;
            8.8.4.4;
    };
```

Aquí hemos configurado los DNS de google.

#### Comprobación del funcionamiento de la caché

Por defecto bind9 tiene la caché habilitada. Podemos probar su funcionamiento de una forma rápida y sencilla.

Haz un dig a un dominio que no hayas consultado nunca antes y fíjate en el "Query time". Inmediatamente vuelve a realizar la misma consulta y comprubeba el "Query time" ahora. Debería haber habido un descenso drástico debido al uso de la caché. ¿Es así?

Podríamos configurar muchas otras cosas, pero para nuestros objetivos actuales es suficiente.

<!-- 
Ahora editaremos el archivo `named.conf.options` e incluiremos los siguientes contenidos:

 + Si, por motivos de seguridad, quisiéramos que solo los equipos de nuestra red local o empresarial pudieran hacer consultas recursivas al servidor, incluiríamos una lista de acceso.

    Imagina que los hosts confiables fueran los de la red 192.168.X.0/24 (donde la X depende de vuestra red de casa). Así pues, justo antes del bloque ```options {…}```, al principio del archivo, añadiríamos algo así:

    ![](P5_1/3.1.bind_2.png)

    En el caso que nuestro servidor se encuentre en AWS no podemos saber, a priori, con qué IP pública llegarán al servidor bind9 nuestras peticiones, así que no incluiremos esta directiva.

+ Si nos fijamos el servidor por defecto ya viene configurado para ser un DNS caché. El directorio donde se cachearán o guardarán las zonas es `/var/cache/bind`.

    ```linuxconf
    /var/cache/bind
    ```


+ Que sólo se permitan las consultas recursivas a los hosts que hemos decidido en la lista de acceso anterior

+ No permitir transferencia de zonas a nadie, de momento

+ Configurar el servidor para que escuche consultas DNS en el puerto 53 (por defecto DNS utiliza puerto 53 UDP) y en la IP de su interfaz de la red privada. <u>**Deberéis colocar la IP de la interfaz de vuestra Debian**</u>, puesto que resolverá las consultas DNS del cliente/s de esa red.

+ Permitir las consultas recursivas, ya que en el primer punto ya le hemos dicho que sólo puedan hacerlas los hosts de la ACL.

+ Además, vamos a comentar la línea que pone `listen-on-v6 { any; };` puesto que no vamos a responder a consultas de IPv6. Para [comentarla](http://astro.uni-tuebingen.de/software/bind/comments.html) basta añadir al principio de la línea dos barras `//`. También podría hacerse con una almohadilla pero aparecería resaltado con color ya que estos comentarios los suele utilizar el administrador para aclarar algún aspecto de la configuración.

    ![](P5_1/3.1.bind_3.png)



Vayamos paso por paso. En p
Podemos comprobar si nuestra configuración es correcta con el comando:

![](P5_1/3.1.bind_4.png)

Si hay algún error, nos lo hará saber. En caso contrario, nos devuelve a la línea de comandos. 

Reiniciamos el servidor y comprobamos su estado:

![](P5_1/3.1.bind_5.png)
-->

### Configuración *named.conf.local*

En este archivo configuraremos aspectos relativos a nuestras zonas. Vamos a declarar la zona “deaw.es”. Por ahora simplemente indicaremos que el servidor DNS es maestro para esta zona y donde estará ubicado el archivo de zona que crearemos más adelante:

```sh
//
// Do any local configuration here
//

// Consider adding the 1918 zones here, if they are not used in your
// organization
//include "/etc/bind/zones.rfc1918";

zone "deaw.es" {
        type master;
        file "/etc/bind/db.deaw.es";  //Ruta donde ubicamos nuestro archivo de zona
};
```

### Creación del archivo de zona

Vamos a crear el archivo de zona de resolución directa justo en el directorio que hemos indicado antes y con el mismo nombre que hemos indicado antes.

El contenido de `/etc/bind/db.deaw.es` será algo así (procurad respetar el formato):

```sh
$TTL 1d
$ORIGIN deaw.es. ; base domain-name
@   IN  SOA     ns1.deaw.es. admin.deaw.es. (
                  2023112301  ; Serial
                  8H          ; Refresh
                  2H          ; Retry
                  4W          ; Expire
                  1D )        ; Minimum TTL
; Name Servers
    IN  NS      ns1.deaw.es.
; A records
ns1 IN  A       3.85.104.173
www IN  A       3.85.104.173
```

Ojo, las últimas IP son la IP que tiene tu servidor Debian. Cámbiala por la que proceda.

Explicación de las partes del archivo:

* $TTL: Tiempo de vida predeterminado para los registros de la zona. En este caso, se establece en 1 día.

* SOA (Start of Authority): Indica información sobre la zona, como el nombre del servidor primario, el contacto del administrador y detalles de tiempo.

    * Recuerda también incrementar el número de serie cada vez que realices cambios para que las actualizaciones se propaguen correctamente.
  
* NS: Registra los servidores de nombres autoritativos para la zona.

* A: Registra la dirección IP asociada con un nombre de host específico.

Guarda el archivo. Comprueba que no hay errores con `named-checkconf` de una forma más avanzada. En este caso necesitará 2 parámetros: el nombre de zona y el archivo de zona:

```sh
$ sudo named-checkzone deaw.es /etc/bind/db.deaw.es
zone deaw.es/IN: loaded serial 2023112301
OK
```

Vemos cómo si va todo bien nos dirá el número de serie y Ok. Si hubiera algún error nos diría algo como 

```sh
zone deaw.es/IN: NS 'ns1.deaw.es' has no address records (A or AAAA)
zone deaw.es/IN: not loaded due to errors.
```

Si va todo bien reinicia el servicio.

Prueba a preguntar por www.deaw.es o ns1.deaw.es a tu servidor.

```sh
nslookup www.deaw.es            //desde el propio servidor
nslookup www.deaw.es IP_SERVER  //desde tu equipo local
```

Prueba a preguntar con `dig` por el dominio deaw.es:

```sh
$ dig deaw.es

; <<>> DiG 9.18.19-1~deb12u1-Debian <<>> deaw.es
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 31053
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 535eb708a167a587010000006560f94758cba602eeb2f207 (good)
;; QUESTION SECTION:
;deaw.es.			IN	A

;; AUTHORITY SECTION:
deaw.es.		86400	IN	SOA	ns1.deaw.es. admin.deaw.es. 2023112301 28800 7200 2419200 86400

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Fri Nov 24 19:28:07 UTC 2023
;; MSG SIZE  rcvd: 110
```

Observa los datos que te devuelve y compáralos con el fichero de configuración de la zona. 

!!!task
    Haz un dig de otros dominios conocidos como cisco.com o google.com y analiza el resultado

### Creación del archivo de zona para la resolución inversa

Recordad que deben existir ambos archivos de zona, uno para la resolución directa y otro para la inversa. Vamos pues a crear el archivo de zona inversa.

En primer lugar, debemos añadir las líneas correspondientes a esta zona inversa en el archivo
**`/etc/bind/named.conf.local`**, igual que hemos hecho antes con la zona de resolución directa:

```sh
zone "104.85.3.in-addr.arpa" {
    type master;
    file "/etc/bind/db.3.85.104";  # Ruta al archivo de zona inversa
};
```
Y la configuración de la zona de resolución inversa:

```sh
$TTL 1d
$ORIGIN 104.85.3.IN-ADDR.ARPA.
@   IN  SOA     ns1.deaw.es. admin.deaw.es. (
                  2023112301  ; Serial
                  8H          ; Refresh
                  2H          ; Retry
                  4W          ; Expire
                  1D )        ; Minimum TTL

; Name Servers
    IN  NS      ns1.deaw.es.

; PTR record
173 IN  PTR     ns1.deaw.es. ; fully qualified domain name (FQDN)
```

Vuelve a omprobar que la configuración es correcta:

```sh
sudo named-checkzone 104.85.3.in-addr.arpa /etc/bind/db.3.85.104 
```

Reinicia el servicio y ejecuta los comandos de comprobación.

```sh
nslookup 3.85.104.173           //desde el propio servidor
nslookup 3.85.104.173 IP_SERVER //desde tu equipo local
```

Comprueba con `dig -x` la resolución inversa:

```sh
$ dig -x 3.85.104.173

; <<>> DiG 9.18.19-1~deb12u1-Debian <<>> -x 3.85.104.173
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 44375
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 727f64c781f9f648010000006560f9ee4cbddffde4f5df09 (good)
;; QUESTION SECTION:
;173.104.85.3.in-addr.arpa.	IN	PTR

;; ANSWER SECTION:
173.104.85.3.IN-ADDR.ARPA. 86400 IN	PTR	ns1.deaw.es.

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Fri Nov 24 19:30:54 UTC 2023
;; MSG SIZE  rcvd: 132
```

## Cuestiones finales

!!!Task "Cuestión 1"
    ¿Qué pasará si un cliente de una red diferente a la tuya intenta hacer uso de tu DNS de alguna manera, le funcionará?¿Por qué, en qué parte de la configuración puede verse?
    
!!!Task "Cuestión 2"
    ¿Por qué tenemos que permitir las consultas recursivas en la configuración?
    
!!!Task "Cuestión 3"
    El servidor DNS que acabáis de montar, ¿es autoritativo? ¿Por qué?

!!!Task "Cuestión 4"
    ¿Dónde podemos encontrar la directiva $ORIGIN y para qué sirve?

!!!Task "Cuestión 5"
    ¿Una zona es idéntico a un dominio? 

!!!Task "Cuestión 6"
    ¿Pueden editarse los archivos de zona de un servidor esclavo/secundario?

!!!Task "Cuestión 7"
    ¿Por qué podría querer tener más de un servidor esclavo para una misma zona?

!!!Task "Cuestión 8"
    ¿Cuántos servidores raíz existen?

!!!Task "Cuestión 9"
    ¿Qué es una consulta iterativa de referencia?
