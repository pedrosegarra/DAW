# Ejercicio guiado: servidor web y servidor de aplicaciones separados

Vas a montar con Docker Compose una aplicación PHP repartida en dos contenedores: **Nginx** como servidor web y **PHP-FPM** como servidor de aplicaciones. Verás qué peticiones atiende cada uno y actualizarás solo el servidor de aplicaciones, como si hubiera salido un aviso de seguridad de PHP, sin tocar el servidor web ni perder los datos.

Al terminar sabrás:

- Qué hace el servidor web y qué hace el servidor de aplicaciones, y cómo se comunican (FastCGI).
- Qué pasa cuando el servidor de aplicaciones se cae y el servidor web sigue en marcha.
- Cómo se actualiza solo una capa: copia, `pull`, `up -d`, comprobación y limpieza.
- Cómo volver a la versión anterior si algo falla.

!!! info "Requisitos"
    Docker con el plugin Compose (`docker compose version` debe responder), `curl`, el puerto 8080 libre y conexión a internet para descargar las imágenes. Tiempo estimado: 1 h 30 min.

## La arquitectura

```text
Navegador ──HTTP──▶ web (Nginx) ──FastCGI :9000──▶ app (PHP-FPM) ──▶ libro.db (volumen)
                       │
                       └── estatico.html lo sirve Nginx directamente
```

- **web**: recibe todas las peticiones. Los ficheros estáticos los sirve él; las peticiones a `.php` las pasa al servidor de aplicaciones.
- **app**: ejecuta el código PHP. No publica ningún puerto al exterior: solo le habla Nginx por la red interna de Compose.
- **datos**: volumen donde la aplicación guarda la base de datos SQLite.

## Preparación

Crea esta estructura:

```text
ej-appserver/
├── compose.yaml
├── nginx.conf
└── app/
    ├── index.php
    └── estatico.html
```

**app/index.php**: un libro de visitas que guarda mensajes en SQLite y muestra qué software atiende la petición.

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

**app/estatico.html**

```html
<h1>Página estática</h1>
<p>Esta página la sirve Nginx sin pasar por PHP.</p>
```

**nginx.conf**

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

`fastcgi_pass` envía las peticiones PHP al servicio `app` por el puerto 9000, donde escucha PHP-FPM. El nombre `app` lo resuelve el DNS interno de Docker, que está en `127.0.0.11`.

!!! note "¿Por qué `resolver` y una variable?"
    Si pusieras `fastcgi_pass app:9000;` directamente, Nginx buscaría la IP de `app` una sola vez, al arrancar, y la guardaría para siempre. Cuando el contenedor de PHP se recrea (en la fase 4), Docker le da otra IP y Nginx seguiría enviando las peticiones a la antigua: `502 Bad Gateway` hasta reiniciar Nginx. Con `resolver` y la variable `$php_app`, Nginx vuelve a preguntar la IP cada 5 segundos.

**compose.yaml**

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

Fíjate en tres cosas:

- Los dos servicios montan el código en la **misma ruta** (`/var/www/html`). Nginx necesita ver los estáticos y PHP-FPM necesita ver los `.php`. Si las rutas no coinciden, PHP-FPM responde *File not found*.
- Solo `web` publica un puerto. El servidor de aplicaciones queda escondido detrás del servidor web.
- PHP empieza en la versión 8.3.10, una versión antigua que tiene vulnerabilidades publicadas.

## Fase 1 — Quién atiende cada petición

1. Desde la carpeta `ej-appserver`, arranca los servicios:

    ```bash
    docker compose up -d
    docker compose ps
    ```

2. Abre `http://localhost:8080` y escribe dos o tres mensajes. Anota lo que pone en «Servidor web» y «Servidor de aplicaciones».
3. Compara las cabeceras de una página estática y de una dinámica:

    ```bash
    curl -I http://localhost:8080/estatico.html
    curl -I http://localhost:8080/index.php
    ```

4. Recarga cada página una vez en el navegador y mira los registros de cada servicio:

    ```bash
    docker compose logs --tail 10 web
    docker compose logs --tail 10 app
    ```

!!! success "Lo que debes ver"
    Las dos respuestas llevan `Server: nginx`, porque Nginx es quien habla siempre con el cliente. Solo la de `index.php` lleva `X-Powered-By: PHP/8.3.10`: esa petición ha pasado por el servidor de aplicaciones. En los registros, `web` muestra las dos peticiones y `app` solo las de `index.php`.

## Fase 2 — Se cae el servidor de aplicaciones

1. Para solo el servidor de aplicaciones:

    ```bash
    docker compose stop app
    ```

2. Prueba otra vez las dos páginas:

    ```bash
    curl -I http://localhost:8080/estatico.html
    curl -I http://localhost:8080/index.php
    ```

3. Vuelve a arrancarlo con `docker compose start app` y recarga `http://localhost:8080`.

!!! warning "Lo que debes ver"
    Con `app` parado, la página estática sigue funcionando y la dinámica devuelve `502 Bad Gateway`: Nginx está vivo, pero no tiene a quién pasar la petición. Al arrancar `app` de nuevo, los mensajes siguen ahí porque están en el volumen `datos`. Si justo después de arrancarlo ves otro 502, espera unos segundos: Nginx tarda hasta 5 s en volver a preguntar la IP.

## Fase 3 — Copia de seguridad antes de actualizar

Antes de tocar la versión se hace siempre una copia del volumen. Compose le pone delante el nombre del proyecto, así que se llama `ej-appserver_datos` (compruébalo con `docker volume ls`).

```bash
docker run --rm \
  -v ej-appserver_datos:/datos:ro \
  -v "$PWD":/backup \
  alpine tar czf /backup/datos-antes.tar.gz -C /datos .
tar tzf datos-antes.tar.gz
```

Debe aparecer `./libro.db`.

## Fase 4 — Actualizar solo el servidor de aplicaciones

Supongamos que acaba de publicarse un aviso de seguridad que afecta a PHP 8.3.10. El fallo está en el servidor de aplicaciones: Nginx no hay que tocarlo.

1. Anota cuándo se creó cada contenedor y la imagen exacta de PHP que usas ahora:

    ```bash
    docker compose ps --format 'table {{.Service}}\t{{.Image}}\t{{.CreatedAt}}'
    docker image inspect --format '{{index .RepoDigests 0}}' php:8.3.10-fpm
    ```

2. En `compose.yaml` cambia solo la imagen del servicio `app`:

    ```yaml
      app:
        image: php:8.3-fpm
    ```

    Esta etiqueta sigue la rama 8.3: cada vez que salga un parche, apuntará a la versión nueva.

3. Descarga la imagen nueva y recrea lo que haya cambiado:

    ```bash
    docker compose pull app
    docker compose up -d
    ```

4. Comprueba el resultado:

    ```bash
    docker compose ps --format 'table {{.Service}}\t{{.Image}}\t{{.CreatedAt}}'
    curl -I http://localhost:8080/index.php
    ```

    Recarga `http://localhost:8080`.

!!! success "Lo que debes ver"
    Solo se ha recreado `app`: su fecha de creación es nueva y la de `web` es la misma de antes. La cabecera `X-Powered-By` y la página muestran la última versión de PHP 8.3, el identificador del contenedor de aplicaciones ha cambiado y los mensajes siguen ahí. El servidor web no se ha enterado del cambio.

## Fase 5 — Volver atrás y limpiar

### Volver a la versión anterior

Imagina que la versión nueva de PHP rompe algo en tu aplicación.

1. En `compose.yaml` vuelve a poner `image: php:8.3.10-fpm` en el servicio `app`. Para fijar los bytes exactos, también puedes usar el digest que anotaste: `image: php@sha256:…`.
2. Ejecuta `docker compose up -d` y recarga la página: vuelves a PHP 8.3.10 con los mismos mensajes.
3. Deja otra vez `image: php:8.3-fpm` y ejecuta `docker compose up -d`.

### Limpieza

```bash
docker compose down
docker image rm php:8.3.10-fpm
docker image prune
```

`docker compose down` no borra el volumen `datos`; `docker compose down -v` sí lo borraría. `docker image prune` solo borra imágenes sin etiqueta, así que una etiqueta fija como `8.3.10-fpm` hay que borrarla a mano.

## Preguntas para entregar

Responde con tus palabras y añade las capturas de pantalla indicadas.

1. En la fase 1, ¿qué cabeceras cambian entre `estatico.html` e `index.php`? ¿Qué te dicen sobre quién ha atendido cada petición? Adjunta la salida de los dos `curl -I`.
2. ¿Por qué el servicio `app` no publica ningún puerto? ¿Cómo le llegan entonces las peticiones?
3. En la fase 2, ¿qué código de estado devuelve `index.php` con `app` parado? ¿Por qué la página estática sigue funcionando?
4. ¿Qué pasaría si `web` montara el código en `/usr/share/nginx/html` en vez de en `/var/www/html`? Pruébalo y explica el error.
5. En la fase 4, ¿qué contenedores se recrearon? Adjunta la salida de `docker compose ps` antes y después.
6. ¿Qué ventaja tiene, a la hora de aplicar un parche de seguridad, tener el servidor web y el de aplicaciones en contenedores distintos?
7. Busca el nombre del servidor de aplicaciones equivalente a PHP-FPM para Java, para Python y para Node.js.
