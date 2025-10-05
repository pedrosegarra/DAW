# 🧩 Práctica 1.4 – Ciclo de despliegue: de local a publicado en web

## 🎯 Objetivo  
En esta práctica vas a realizar el **ciclo completo de despliegue web**, desde tu equipo local hasta la publicación en un servidor accesible por Internet.

---

## 🚀 ¿Qué tienes que hacer?

### 1. Preparar el entorno local

En tu ordenador local (Casa o Instituto), abre un **terminal** y ejecuta los siguientes comandos:

```bash
mkdir P1_4
cd P1_4
code .
```

Esto abrirá **Visual Studio Code** en la carpeta `P1_4`.

---

### 2. Crea un nuevo archivo llamado `index.html`

💻 **Ejemplo del contenido del archivo `index.html`:**

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

### 3. Subir el proyecto a GitHub

Ahora, en tu **ordenador local** y desde el **terminal integrado de Visual Studio Code**, ejecuta los comandos necesarios para subir tu código al repositorio de **GitHub** creado para esta práctica (`P1_4`).  

Recuerda que ya tienes **Git instalado** y has generado el par de claves SSH para conectarte a GitHub en prácticas anteriores.

#### 🧩 Pasos a seguir

1. **Inicializa el repositorio y realiza tu primer commit:**

   ```bash
   git init
   git add .
   git commit -m "Subida inicial práctica P1_4"
   ```

2. **Crea la rama principal y vincula tu repositorio local con el remoto de GitHub:**

   ```bash
   # Si usas main (por defecto en GitHub)
   git branch -M main

   # O si tu entorno usa master
   git branch -M master
   ```

3. **Añade el repositorio remoto (sustituye tu_usuario por tu nombre real de GitHub):**

   ```bash
   git remote add origin git@github.com:tu_usuario/P1_4.git
   ```

4. **Sube el contenido al repositorio remoto:**

   ```bash
   git push -u origin main
   ```

   (O `master`, si tu repositorio usa esa rama.)

5. **Crea una etiqueta (tag)** para identificar esta versión de entrega:

   ```bash
   git tag -a P1_4 -m "Entrega práctica 1.4"
   git push origin P1_4
   ```

---

### 4. Conexión al servidor remoto (AWS)

Como en el aula no es posible realizar conexiones SSH a servidores externos (salvo los dominios permitidos como **GitHub** o **AWS**), utilizaremos una **máquina virtual en AWS** para continuar con el proceso de despliegue.

Deberás haber creado una **instancia Debian** en AWS y generado el **par de claves `.pem`** para conectarte.

#### 🧩 Pasos previos

1. Descarga el archivo de clave privada (`mi_clave.pem`) al crear la instancia.  
2. Guarda el archivo en un lugar seguro, por ejemplo en `~/.ssh/`.
3. Asigna los permisos correctos al archivo para que SSH lo acepte:

   ```bash
   chmod 400 mi_clave.pem
   ```

#### 🔐 Conexión a la instancia AWS

Conéctate al servidor desde tu terminal local. En este entorno, el **usuario SSH** es tu **nombre de subdominio** asignado por el profesor (por ejemplo, `psegarracabedo`).

```bash
ssh -i "ruta/mi_clave.pem" psegarracabedo@<IP_PÚBLICA_DE_TU_INSTANCIA>
```

📌 **Ejemplo:**

```bash
ssh -i "~/.ssh/mi_clave.pem" psegarracabedo@54.200.123.45
```

Si la conexión es correcta, accederás a la terminal de tu servidor remoto en AWS.

---

### 5. Generar claves SSH para conexión al servidor remoto del profesor

Desde tu **servidor AWS**, ya puedes establecer conexiones **SSH** hacia servidores externos.  
En este paso vas a generar un nuevo **par de claves (privada y pública)** para conectarte al **servidor remoto** del profesor, dentro del dominio:

```
iespublico.com
```

#### 🧩 Pasos a seguir

1. Conéctate a tu servidor AWS y ejecuta:

   ```bash
   ssh-keygen -t ed25519 -C "tu_correo@alu.edu.gva.es" -f ~/.ssh/iespublico
   ```

   ⚠️ **Importante:**  
   - Sustituye `tu_correo@alu.edu.gva.es` por tu propio correo.  
   - Este comando generará dos archivos:
     - `iespublico` → **clave privada**
     - `iespublico.pub` → **clave pública**

2. **No entregues nunca la clave privada** (`iespublico`).  
   Guárdala en tu servidor AWS.

3. **Entrega la clave pública** (`iespublico.pub`):  

   ```bash
   cat ~/.ssh/iespublico.pub
   ```

   Copia su contenido y **pégalo en Aules** en el apartado que el profesor ha habilitado.  
   El profesor añadirá tu clave pública al servidor `iespublico.com` para permitir tu acceso.

---

### 6. Conexión al servidor del dominio `iespublico.com` y despliegue básico

Una vez que el profesor haya recibido tu **clave pública**, te habrá creado un **subdominio personalizado** dentro del dominio:

```
iespublico.com
```

Por ejemplo:  
👉 `psegarracabedo.iespublico.com`

---

#### 🧩 Conexión al servidor

Desde tu **instancia AWS**, conecta al servidor `iespublico.com` mediante SSH utilizando el par de claves que generaste para este servidor.  
El **nombre de usuario SSH** será el **mismo que tu subdominio**.

```bash
ssh -i ~/.ssh/iespublico psegarracabedo@psegarracabedo.iespublico.com
```

(Sustituye `psegarracabedo` por tu propio subdominio asignado por el profesor.)

Si todo está correcto, accederás al servidor remoto donde se aloja tu espacio web personal.

---

#### 🔐 Generar claves SSH para conexión con GitHub

Dentro del servidor `iespublico.com`, deberás generar **otro par de claves SSH**, esta vez para conectar el servidor directamente con tu repositorio de GitHub.

Ejecuta:

```bash
ssh-keygen -t ed25519 -C "tu_correo@alu.edu.gva.es" -f ~/.ssh/github
```

Copia el contenido de la clave pública y **añádela a GitHub** en:

👉 *Settings → SSH and GPG keys → New SSH key*

---

#### 📦 Descargar el repositorio en el servidor (`git pull`)

1. Accede al directorio de tu sitio web en el servidor:

   ```bash
   cd /var/www/psegarracabedo/public_html
   ```

   (Sustituye `psegarracabedo` por tu propio subdominio.)

2. Desde esa ubicación, ejecuta:

   ```bash
   git pull origin main
   ```

   o, si es la primera vez que traes el proyecto:

   ```bash
   git clone git@github.com:tu_usuario/P1_4.git .
   ```

   El punto (`.`) copia los archivos directamente en `public_html`.

3. Verifica que el archivo `index.html` está dentro de `public_html`.

---

#### 🌐 Resultado final

Si todo el proceso ha sido correcto, al abrir tu subdominio en el navegador:

```
https://psegarracabedo.iespublico.com
```

verás tu `index.html` publicado correctamente.

---

🧠 **Este ejercicio es una práctica base** para entender el ciclo completo de **despliegue web** desde local hasta producción.  
En este caso lo hemos hecho con un **HTML sencillo**, pero en prácticas posteriores realizaremos despliegues más avanzados con:

- **Docker**
- **Entornos LAMP (Linux, Apache, MySQL, PHP)**
- **Entornos LEMP (Linux, Nginx, MySQL, PHP)**
- y otros servicios web.
