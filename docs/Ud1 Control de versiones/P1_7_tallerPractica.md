# Práctica 1.4 – Ciclo de despliegue: de local a publicado en web

## Objetivo
Completar el ciclo de despliegue web desde el equipo local hasta la publicación en un servidor accesible por Internet.

---

## 1. Preparar el entorno local

En tu ordenador local, abre un terminal y ejecuta:

```bash
mkdir P1_4
cd P1_4
code .
```

---

## 2. Crear `index.html`

Ejemplo de contenido para `index.html`:

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Práctica 1.4 - Despliegue Web</title>
</head>
<body>
  <h1>Alumno: Juan García Pérez</h1>
  <p><strong>Email:</strong> juan.garcia01@alu.edu.gva.es</p>
  <p><strong>Curso:</strong> 2º DAW</p>
</body>
</html>
```

---

## 3. Subir el proyecto a GitHub

En el terminal integrado de Visual Studio Code:

```bash
git init
git add .
git commit -m "Subida inicial práctica P1_4"
```

Configura la rama principal y el remoto (usa **main** por defecto en GitHub; si usas **master**, sustitúyelo en los comandos de push/pull):

```bash
git branch -M main          # o: git branch -M master
git remote add origin git@github.com:tu_usuario/P1_4.git
git push -u origin main     # o: git push -u origin master
```

Crea una etiqueta para esta entrega:

```bash
git tag -a P1_4 -m "Entrega práctica 1.4"
git push origin P1_4
```

---

## 4. Conexión al servidor remoto (AWS)

Debes tener una instancia creada y una clave `.pem`. Asigna permisos:

```bash
chmod 400 mi_clave.pem
```

Conéctate (el usuario SSH es tu nombre de subdominio asignado por el profesor):

```bash
ssh -i "ruta/mi_clave.pem" subdominio@<IP_PUBLICA_AWS>
```

Ejemplo:

```bash
ssh -i "~/.ssh/mi_clave.pem" psegarracabedo@54.200.123.45
```

---

## 5. Generar claves SSH para el servidor del profesor (`iespublico.com`)

En tu servidor AWS, genera un par de claves para acceder al servidor del profesor:

```bash
ssh-keygen -t ed25519 -C "tu_correo@alu.edu.gva.es" -f ~/.ssh/iespublico
```

No compartas la clave privada. Entrega la clave pública en Aules:

```bash
cat ~/.ssh/iespublico.pub
```

El profesor la añadirá al servidor `iespublico.com` para permitir tu acceso.

---

## 6. Conexión al servidor `iespublico.com` y despliegue

Conéctate al servidor con tu subdominio como usuario:

```bash
ssh -i ~/.ssh/iespublico subdominio@subdominio.iespublico.com
```

En el servidor, genera un par de claves para conectar con GitHub y añade la clave pública en tu cuenta de GitHub (Settings → SSH and GPG keys → New SSH key):

```bash
ssh-keygen -t ed25519 -C "tu_correo@alu.edu.gva.es" -f ~/.ssh/github
cat ~/.ssh/github.pub
```

Ve al directorio público de tu sitio y descarga el repositorio:

```bash
cd /var/www/subdominio/public_html

# Si ya existe el repo remoto configurado en esta carpeta
git pull origin main    # o: git pull origin master

# Si es la primera vez
git clone git@github.com:tu_usuario/P1_4.git .
```

Comprueba que `index.html` está en `public_html` y accede a:

```
https://subdominio.iespublico.com
```
