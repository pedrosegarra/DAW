# Práctica P2 – Fase 1: Despliegue local con Docker y Visual Studio Code

**Centro:** IES El Caminàs  
**Módulo:** Despliegue de Aplicaciones Web  
**Curso:** 2025/2026  

---

## Objetivo de la práctica

Aprender a crear, ejecutar y explorar un contenedor **Apache** en entorno local utilizando **Docker** y **Visual Studio Code**, comprendiendo la estructura interna del servidor web y el flujo básico de despliegue local.

---

## 1. Preparar el entorno local

```bash
mkdir P2
cd P2
code .
```

Esto abrirá **Visual Studio Code** en la carpeta `P2`.

---

## 2. Crear el archivo `index.html`

Crea un archivo llamado `index.html` con el siguiente contenido:

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Práctica P2 - Apache en Docker</title>
</head>
<body>
  <h1>Alumno: Nombre del alumno</h1>
  <p><strong>Curso:</strong> 2º DAW</p>
  <p><strong>Centro:</strong> IES El Caminàs</p>
</body>
</html>
```

---

## 3. Crear el archivo `Dockerfile`

```dockerfile
FROM httpd:2.4
RUN mkdir -p /usr/local/apache2/htdocs/P2
COPY index.html /usr/local/apache2/htdocs/P2/index.html
RUN echo "ServerName localhost" >> /usr/local/apache2/conf/httpd.conf
```

!!! note "Información"
    La imagen oficial de Apache (`httpd:2.4`) no utiliza `/var/www/html` como las instalaciones clásicas de Apache en Linux.  
    El directorio raíz del servidor web dentro del contenedor es `/usr/local/apache2/htdocs`.

---

## 4. Construir la imagen Docker

```bash
docker build -t p2:1.0 .
```

!!! tip "Consejo"
    El punto final (`.`) indica que el *Dockerfile* se encuentra en el directorio actual.

---

## 5. Ejecutar el contenedor Apache

```bash
docker run -d --name p2 -p 8080:80 p2:1.0
```

Abre el navegador y accede a:

```
http://localhost:8080/P2
```

!!! success "Resultado esperado"
    Debe mostrarse tu página `index.html` con tus datos personales.

---

## 6. Explorar el contenedor en Visual Studio Code

1. Abre el panel **Docker** en VS Code (icono de la ballena).  
2. Localiza el contenedor **p2** en la sección **Containers**.  
3. Clic derecho → **Attach Visual Studio Code**.  
4. Navega hasta:
   ```
   /usr/local/apache2/htdocs/P2/index.html
   ```
5. Abre el archivo y verifica que coincide con la página servida en el navegador.

!!! tip "Extensiones necesarias"
    - Docker (Microsoft)  
    - Dev Containers (Microsoft)

---

## 7. Consultar el contenido desde el terminal (opcional)

```bash
docker exec -it p2 sh
cd /usr/local/apache2/htdocs/P2
ls
cat index.html
exit
```

---

## 8. Detener y eliminar el contenedor

```bash
docker stop p2
docker rm p2
```

---

## 9. Resumen de comandos útiles

```bash
# Crear proyecto
mkdir P2 && cd P2

# Crear imagen
docker build -t p2:1.0 .

# Ejecutar contenedor
docker run -d --name p2 -p 8080:80 p2:1.0

# Consultar contenido
docker exec -it p2 sh

# Detener y eliminar
docker stop p2 && docker rm p2
```

---

## 10. Notas finales

!!! info "Recordatorio"
    - El contenedor Apache usa la ruta `/usr/local/apache2/htdocs` como raíz del sitio web.  
    - Si el puerto 80 está ocupado, cambia `-p 8080:80` por otro puerto libre (ej. `-p 8081:80`).  
    - El aviso *“Could not reliably determine the server’s fully qualified domain name”* no es un error y puede ignorarse.

---

## Resultado de la Fase 1

Al finalizar esta fase, el alumno habrá creado una imagen Docker con Apache, ejecutado el contenedor localmente y comprobado su funcionamiento tanto desde el navegador como dentro de Visual Studio Code.

---
