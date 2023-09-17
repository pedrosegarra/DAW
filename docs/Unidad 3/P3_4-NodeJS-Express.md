---
title: 'Práctica 3.4 - Despliegue de aplicaciones con Node Express'
---

# Práctica 3.4: Despliegue de aplicaciones con Node Express

## Introducción

En esta práctica vamos a realizar el despliegue de aplicaciones Node.js sobre un servidor Node Express. Lo curioso de este caso es que el despliegue aquí cambia un poco puesto que no se hace sobre el servidor, sino que la aplicación *es* el servidor.

## Creación de la máquina virtual

Para empezar, entra en AWS Academy y crea un nuevo EC2 Debian con estas características.

* Llámale P3NodeJs. 
* Dale los recursos que te ofrece por defecto. 
* El acceso al servidor se realiza por el puerto TCP 3000. Puedes modificar el Grupo de seguridad ahora para permitir el acceso por http, https y TCP 3000 ahora o editarlo más tarde.

## Instalación de Node.js, Express y test de la primera aplicación

La primera parte de la práctica es muy sencilla. 

Consistirá en instalar sobre nuestra Debian tanto Node.js como Express y tras ello crear un archivo `.js` de prueba para comprobar que nuestro primer despliegue funciona correctamente.

### Instalacion de Node.js

Seguiremos las instrucciones de instalación que encontramos [aquí](https://github.com/nodesource/distributions).

1. Descargar e importar la clave GPG de Nodesource

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
```

2. Crear el repositorio deb

```bash
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
```

Opcional: Puedes cambiar NODE_MAJOR dependiendo de la versión que necesites.
* NODE_MAJOR=16
* NODE_MAJOR=18
* NODE_MAJOR=20

3. Ejecutar la actualización e instalación

```bash
sudo apt-get update
sudo apt-get install nodejs -y
```

En lugar de acceder a `http://localhost:3000`, debéis acceder desde vuestra máquina local a `http://IP-maq-virtual:3000`, utilizando la IP concreta de vuestra máquina virtual.

### Instalación de Express

Ejecutamos el siguiente comando

```bash
sudo npm install -g express
```

Obtendremos una salida similar a esta:

```bash
$ sudo npm install -g express

added 58 packages in 3s

8 packages are looking for funding
  run `npm fund` for details
npm notice 
npm notice New major version of npm available! 9.8.1 -> 10.1.0
npm notice Changelog: https://github.com/npm/cli/releases/tag/v10.1.0
npm notice Run npm install -g npm@10.1.0 to update!
npm notice 
```

Si leemos con atención nos dice que hay una versión más actual y que actualicemos. Pues lo haremos según lo que nos indique, en el caso de arriba:

```bash
sudo npm install -g npm@10.1.0
```

### Creación del primer proyecto

Vamos a probar que la instalación funciona creando un sencillo proyecto.

Crea la carpeta del proyecto:

```bash
mkdir proyecto
cd proyecto
```
Inicializa el proyecto

```bash
npm init -y
```
Instala Express.js para este proyecto de manera local:

```bash
npm install express
```
Ahora crea un archivo de muestra:

```bash
sudo nano app.js
```

Y agrega lo siguiente:

```bash
const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
    res.send('Hello. Welcome to this blog')
})

app.listen(port, () => {
    console.log(`Example app listening at http://localhost:${port}`)
})
```

Ahora ejecuta el proyecto con el siguiente comando:

```bash
node app.js
```

Obtendrás la siguiente salida.

```bash
Example app listening at http://localhost:3000
```

Abre un navegador web y ve a la dirección indicada o la dirección de tu servidor. En nuestro caso deberás sustituir `localhost` por la IP pública de nuestra EC2. Si tienes problemas para acceder recuerda que debiste permitir el acceso al puerto TCP 3000 en el Grupo de Seguridad de AWS.

Recordad parar el servidor (CTRL+C en el terminal conectado a la máquina virtual) al acabar la práctica.

## Despliegue de una nueva aplicación

Vamos ahora a realizar el despliegue de una aplicación de terceros para ver cómo es el proceso.

Se trata de un "prototipo" de una especie de CMS que podéis encontrar en este [repositorio de Github](https://github.com/contentful/the-example-app.nodejs). 

Tal y como indican las instrucciones del propio repositorio, los pasos a seguir son, en primer lugar, clonar el repositorio a nuesta máquina:

```sh
git clone https://github.com/contentful/the-example-app.nodejs.git
```
Movernos al nuevo directorio:

```sh
cd the-example-app.nodejs
```

Instalar las librerías necesarias (paciencia, este proceso puede tardar un buen rato):

```sh
npm install
```

Y, por último, iniciar la aplicación:

```sh
npm run start:dev
```

!!!warning
    No te preocupes por el contenido o si salen errores. Lo importante es ver cómo en unos pocos comandos hemos desplegado una aplicación de terceros, no el contenido de la misma.

## Cuestiones

Cuando ejecutáis el comando `npm run start:dev`, lo que estáis haciendo es ejecutar un script:

- ¿Donde podemos ver que script se está ejecutando?

- ¿Qué comando está ejecutando?

Como ayuda, podéis consultar [esta información](https://www.freecodecamp.org/espanol/news/node-js-npm-tutorial/).

## Referencias

[How to install ExpressJS on Debian 11?](https://unixcop.com/how-to-install-expressjs-on-debian-11/)

[Node.js installation](https://github.com/nodesource/distributions)
