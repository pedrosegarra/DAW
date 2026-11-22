# Guía: servidor web y servidor de aplicaciones con Docker

En esta guía vas a montar paso a paso una aplicación PHP repartida en dos contenedores: **Nginx** como servidor web y **PHP-FPM** como servidor de aplicaciones. En cada paso tienes el comando, lo que debe salir en pantalla y la explicación de qué está pasando. Ve haciéndolo en tu equipo y compara tus salidas con las de la guía.

!!! info "Antes de empezar"
    Necesitas Docker con el plugin Compose (`docker compose version` debe responder), `curl`, el puerto 8080 libre y conexión a internet. Los números de versión, las IP, los identificadores y las fechas que verás serán distintos de los de la guía: lo que importa es que aparezcan los mismos campos y el mismo comportamiento.

## La arquitectura que vas a montar

```text
Navegador ──HTTP──▶ web (Nginx) ──FastCGI :9000──▶ app (PHP-FPM) ──▶ libro.db (volumen)
                       │
                       └── estatico.html lo sirve Nginx directamente
```

Es el flujo que has visto en la teoría: el servidor web recibe todas las peticiones del cliente. Si piden algo estático, lo sirve él. Si piden algo dinámico, se lo pasa al servidor de aplicaciones, que ejecuta el código y le devuelve el resultado. Aquí el «código» es PHP y la base de datos es un fichero SQLite guardado en un volumen.

## Paso 1 — Crear los ficheros

Crea esta estructura de carpetas:

```bash
mkdir -p ej-appserver/app
cd ej-appserver
```

```text
ej-appserver/
├── compose.yaml
├── nginx.conf
└── app/
    ├── index.php
    └── estatico.html
```

### La aplicación: app/index.php

Es un libro de visitas: guarda mensajes en SQLite y muestra qué software ha atendido la petición.

```php
<?php
$db = new PDO('sqlite:/var/www/datos/libro.db');
$db->exec('CREATE TABLE IF NOT EXISTS mensajes (id INTEGER PRIMARY KEY, texto TEXT, fecha TEXT)');

if (!empty($_POST['texto'])) {
    $st = $db->prepare("INSERT INTO mensajes (texto, fecha) VALUES (?, datetime('now'))");
    $st->execute([$_POST['texto']]);
    header('Location: /');
    exit;
}

$filas = $db->query('SELECT texto, fecha FROM mensajes ORDER BY id DESC')->fetchAll();
?>
<h1>Libro de visitas</h1>
<p>Servidor web: <?= $_SERVER['SERVER_SOFTWARE'] ?></p>
<p>Servidor de aplicaciones: PHP <?= PHP_VERSION ?> · contenedor <?= gethostname() ?></p>
<form method="post">
  <input name="texto" placeholder="Escribe un mensaje">
  <button>Enviar</button>
</form>
<ul>
<?php foreach ($filas as $f): ?>
  <li><?= htmlspecialchars($f['texto']) ?> (<?= $f['fecha'] ?>)</li>
<?php endforeach; ?>
</ul>
```

Fíjate en dos líneas:

- `$_SERVER['SERVER_SOFTWARE']` lo rellena el servidor web al pasar la petición. Aquí dirá `nginx`.
- `PHP_VERSION` y `gethostname()` los da el servidor de aplicaciones: la versión de PHP y el nombre del contenedor donde se ejecuta.

### La página estática: app/estatico.html

```html
<h1>Página estática</h1>
<p>Esta página la sirve Nginx sin pasar por PHP.</p>
```

### El servidor web: nginx.conf

```nginx
server {
    listen 80;
    root /var/www/html;
    index index.php index.html;

    resolver 127.0.0.11 valid=5s;
    set $php_app app:9000;

    location ~ \.php$ {
        fastcgi_pass $php_app;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

Línea a línea:

- `root /var/www/html`: carpeta donde Nginx busca los ficheros.
- `index index.php index.html`: si piden `/`, prueba primero `index.php`.
- `location ~ \.php$`: todo lo que termine en `.php` va a este bloque. El resto lo sirve Nginx como fichero estático.
- `fastcgi_pass $php_app`: envía la petición al servidor de aplicaciones, el servicio `app`, por el puerto 9000. El protocolo entre los dos es **FastCGI**, no HTTP.
- `SCRIPT_FILENAME`: le dice a PHP-FPM qué fichero tiene que ejecutar, por ejemplo `/var/www/html/index.php`.
- `resolver 127.0.0.11` y la variable `$php_app`: `127.0.0.11` es el DNS interno de Docker, que sabe qué IP tiene `app`. Con la variable, Nginx vuelve a preguntar la IP cada 5 segundos. Si pusieras `fastcgi_pass app:9000;` directamente, Nginx la preguntaría una sola vez, al arrancar. El día que el contenedor de PHP se recreara con otra IP (lo harás en el paso 5), Nginx seguiría llamando a la antigua.

### Los servicios: compose.yaml

```yaml
services:
  web:
    image: nginx:1.27-alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - ./app:/var/www/html:ro
    depends_on:
      - app

  app:
    image: php:8.3.10-fpm
    volumes:
      - ./app:/var/www/html:ro
      - datos:/var/www/datos
    command: sh -c "mkdir -p /var/www/datos && chown www-data:www-data /var/www/datos && exec php-fpm"

volumes:
  datos:
```

Qué hace cada parte:

- **web** usa la imagen oficial de Nginx. Publica su puerto 80 en el 8080 de tu equipo y monta tu configuración y tu código.
- **app** usa la imagen oficial de PHP en su variante `fpm`, que trae PHP-FPM escuchando en el puerto 9000. Empezamos con la versión 8.3.10, que es antigua y tiene vulnerabilidades publicadas.
- **app no tiene `ports`**: nadie de fuera puede hablar con él directamente. Solo le llega lo que le pasa Nginx por la red interna que crea Compose. Así el servidor de aplicaciones queda protegido detrás del servidor web.
- Los dos montan el código en **la misma ruta**, `/var/www/html`. Nginx necesita ver los ficheros estáticos y PHP-FPM los `.php`. Además, la ruta que Nginx manda en `SCRIPT_FILENAME` tiene que existir dentro del contenedor de PHP.
- **datos** es un volumen con nombre: la base de datos queda fuera del contenedor y sobrevive aunque este se borre.
- **command**: antes de arrancar PHP-FPM, crea la carpeta de datos y se la da al usuario `www-data`, que es con el que se ejecuta PHP. Sin esto, PHP no podría escribir la base de datos.

## Paso 2 — Arrancar y ver quién atiende cada petición

```bash
docker compose up -d
docker compose ps
```

Salida orientativa:

```text
NAME                 IMAGE               SERVICE   STATUS         PORTS
ej-appserver-app-1   php:8.3.10-fpm      app       Up 3 seconds   9000/tcp
ej-appserver-web-1   nginx:1.27-alpine   web       Up 3 seconds   0.0.0.0:8080->80/tcp
```

`web` tiene una flecha (`8080->80`): está publicado. `app` solo muestra `9000/tcp`: escucha en ese puerto, pero únicamente dentro de la red de Docker.

Abre `http://localhost:8080` y escribe dos o tres mensajes. Verás algo así:

```text
Libro de visitas
Servidor web: nginx/1.27.x
Servidor de aplicaciones: PHP 8.3.10 · contenedor 3f2a9c1e5b7d
```

**Compara las cabeceras de una página estática y de una dinámica**

```bash
curl -I http://localhost:8080/estatico.html
```

```http
HTTP/1.1 200 OK
Server: nginx/1.27.x
Content-Type: text/html
Content-Length: ...
Last-Modified: ...
ETag: "..."
Accept-Ranges: bytes
```

```bash
curl -I http://localhost:8080/index.php
```

```http
HTTP/1.1 200 OK
Server: nginx/1.27.x
Content-Type: text/html; charset=UTF-8
X-Powered-By: PHP/8.3.10
```

Qué te dicen:

- Las dos llevan `Server: nginx`: quien habla con el cliente es siempre el servidor web.
- Solo `index.php` lleva `X-Powered-By: PHP/8.3.10`: esa petición ha pasado por el servidor de aplicaciones.
- `estatico.html` lleva `Last-Modified`, `ETag` y `Content-Length`, que Nginx saca directamente del fichero en disco. No ha hecho falta ejecutar nada.

**Mira los registros de cada servicio**

Abre en el navegador `http://localhost:8080/estatico.html` y después `http://localhost:8080/index.php`. Luego mira los registros:

```bash
docker compose logs --tail 10 web
```

```text
web-1  | 172.18.0.1 - - [...] "GET /estatico.html HTTP/1.1" 200 ...
web-1  | 172.18.0.1 - - [...] "GET /index.php HTTP/1.1" 200 ...
```

```bash
docker compose logs --tail 10 app
```

```text
app-1  | 172.18.0.3 -  [...] "GET /index.php" 200
```

El servidor web registra todas las peticiones; el de aplicaciones, solo las dinámicas. Fíjate también en la IP que ve PHP-FPM: no es la de tu navegador, sino la del contenedor de Nginx, porque su único cliente es el servidor web.

## Paso 3 — Parar el servidor de aplicaciones

```bash
docker compose stop app
curl -I http://localhost:8080/estatico.html
curl -I http://localhost:8080/index.php
```

```text
HTTP/1.1 200 OK            ← estatico.html
HTTP/1.1 502 Bad Gateway   ← index.php
```

Busca el motivo en el registro de Nginx:

```bash
docker compose logs --tail 5 web
```

```text
web-1  | ... [error] ... app could not be resolved (3: Host not found) ...
```

Qué está pasando: Nginx sigue en marcha, así que lo estático funciona. Pero al parar `app`, Docker lo saca de la red, el nombre `app` deja de existir y Nginx no tiene a quién pasar la petición dinámica. El código **502 Bad Gateway** significa justo eso: «yo estoy bien, pero el servidor que hay detrás de mí no responde».

Vuelve a arrancarlo:

```bash
docker compose start app
```

Espera unos segundos y recarga `http://localhost:8080`: la página vuelve y los mensajes siguen ahí, porque están en el volumen `datos`.

## Paso 4 — Hacer una copia de seguridad del volumen

Antes de actualizar se hace siempre una copia. Primero busca el nombre real del volumen:

```bash
docker volume ls
```

```text
DRIVER    VOLUME NAME
local     ej-appserver_datos
```

Compose le pone delante el nombre del proyecto, que es el de la carpeta. Ahora haz la copia con un contenedor temporal de Alpine que monta el volumen y tu carpeta actual:

```bash
docker run --rm \
  -v ej-appserver_datos:/datos:ro \
  -v "$PWD":/backup \
  alpine tar czf /backup/datos-antes.tar.gz -C /datos .
tar tzf datos-antes.tar.gz
```

```text
./
./libro.db
```

`--rm` borra el contenedor de Alpine en cuanto termina: solo lo usamos para ejecutar `tar`. El fichero `datos-antes.tar.gz` queda en tu carpeta.

## Paso 5 — Actualizar solo el servidor de aplicaciones

Supón que acaba de publicarse un aviso de seguridad que afecta a PHP 8.3.10. El fallo está en el servidor de aplicaciones, así que Nginx no hay que tocarlo.

**Anota cómo están las cosas ahora**

```bash
docker compose ps --format 'table {{.Service}}\t{{.Image}}\t{{.CreatedAt}}'
```

```text
SERVICE   IMAGE               CREATED AT
app       php:8.3.10-fpm      2026-11-21 10:01:58 +0100 CET
web       nginx:1.27-alpine   2026-11-21 10:01:58 +0100 CET
```

Guarda también el identificador exacto de la imagen actual, por si hay que volver atrás:

```bash
docker image inspect --format '{{index .RepoDigests 0}}' php:8.3.10-fpm
```

```text
php@sha256:...
```

**Cambia la imagen de app**

En `compose.yaml`, cambia solo la línea `image` del servicio `app`:

```yaml
  app:
    image: php:8.3-fpm
```

La etiqueta `8.3-fpm` sigue la rama 8.3: cada vez que sale un parche de seguridad, pasa a apuntar a la versión nueva.

**Descarga y recrea**

```bash
docker compose pull app
docker compose up -d
```

`pull` solo descarga la imagen: no toca nada de lo que está en marcha. `up -d` compara lo que hay en marcha con `compose.yaml` y solo recrea lo que ha cambiado. En la salida verás que `app` se recrea y `web` sigue como estaba.

**Comprueba el resultado**

```bash
docker compose ps --format 'table {{.Service}}\t{{.Image}}\t{{.CreatedAt}}'
```

```text
SERVICE   IMAGE               CREATED AT
app       php:8.3-fpm         2026-11-21 10:25:40 +0100 CET
web       nginx:1.27-alpine   2026-11-21 10:01:58 +0100 CET
```

```bash
curl -I http://localhost:8080/index.php
```

```http
HTTP/1.1 200 OK
Server: nginx/1.27.x
X-Powered-By: PHP/8.3.xx
```

Recarga `http://localhost:8080`:

- La versión de PHP es la última 8.3 publicada, mayor que 8.3.10.
- El identificador del contenedor de aplicaciones ha cambiado: es un contenedor nuevo.
- La fecha de creación de `web` es la misma de antes: el servidor web no se ha reiniciado.
- Los mensajes siguen ahí, porque están en el volumen.

Esta es la ventaja de tener las capas separadas: el parche se aplica solo donde hace falta. Lo estático no se corta en ningún momento y, si algo sale mal, solo hay que deshacer un cambio.

## Paso 6 — Volver atrás

Imagina que la versión nueva de PHP rompe algo en la aplicación. Vuelve a la anterior:

1. En `compose.yaml` pon otra vez `image: php:8.3.10-fpm` en el servicio `app`. Para fijar exactamente la misma imagen, puedes usar el digest que anotaste: `image: php@sha256:…`.
2. Aplica el cambio:

    ```bash
    docker compose up -d
    ```

3. Recarga la página: vuelves a PHP 8.3.10 con los mismos mensajes.

Volver atrás es igual que actualizar: cambias la imagen y se recrea el contenedor. Los datos no se tocan. Cuando termines, deja otra vez `image: php:8.3-fpm` y ejecuta `docker compose up -d`.

## Paso 7 — Limpiar

```bash
docker compose down
docker volume ls
docker image rm php:8.3.10-fpm
docker image prune
```

- `docker compose down` borra los contenedores y la red, pero **no** el volumen: `ej-appserver_datos` sigue en la lista. Con `docker compose down -v` sí lo borraría.
- `docker image prune` solo borra imágenes que se han quedado sin etiqueta. `php:8.3.10-fpm` tiene etiqueta, así que hay que borrarla a mano con `docker image rm`.

## Si algo falla

| Lo que ves | Por qué pasa | Qué hacer |
| --- | --- | --- |
| `File not found.` al abrir la página | `web` y `app` no montan el código en la misma ruta, o falta la línea `SCRIPT_FILENAME` | Revisa que los dos usen `/var/www/html` y repasa `nginx.conf` |
| `502 Bad Gateway` que no se va | `app` está parado, o tu `nginx.conf` no tiene `resolver` y la variable `$php_app` | `docker compose ps` para ver si `app` está en marcha, y revisa `nginx.conf` |
| `unable to open database file` | PHP no puede escribir en `/var/www/datos` | Comprueba la línea `command` del servicio `app` y haz `docker compose up -d` |
| `port is already allocated` | Otra práctica ya usa el puerto 8080 | `docker ps` y para lo que lo esté usando, o cambia a `"8081:80"` |
| La versión de PHP no cambia en el paso 5 | Has cambiado la imagen de `web` en vez de la de `app`, o no has hecho `pull` | Revisa `compose.yaml` y repite `pull` y `up -d` |
| `web` no arranca | Error de sintaxis en `nginx.conf` (falta un `;` o una llave) | `docker compose logs web` te dice la línea del error |

## Resumen

- El **servidor web** (Nginx) atiende todas las peticiones, sirve lo estático y pasa lo dinámico.
- El **servidor de aplicaciones** (PHP-FPM) ejecuta el código. No está expuesto: solo le habla el servidor web, por FastCGI.
- Si se cae el servidor de aplicaciones, lo estático sigue funcionando y lo dinámico da **502**.
- Separar las capas permite actualizar solo la que tiene el fallo, sin tocar las demás ni los datos, y volver atrás con el mismo procedimiento.
- Otros lenguajes tienen su propio servidor de aplicaciones: **Tomcat** en Java (el que ejecuta los servlets), **Gunicorn** o **Uvicorn** en Python y el propio proceso de **Node.js**. El esquema es el mismo: un servidor web delante y el servidor de aplicaciones detrás.
