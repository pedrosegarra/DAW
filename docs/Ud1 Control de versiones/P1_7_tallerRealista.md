---
title: "Taller 4: Ciclo de despliegue a local-repositorio-publicado"
---

En esta práctica vamos a realizar el ciclo de despliegue de local a publicado en web.

## ¿Qué tienes que hacer?

  1. Crea un par de claves privada y publica para conectarte al servidor web. Para ello realiza lo siguiente:
  ```
  ssh-keygen -t ed25519 -C "correo@alu.edu.gva.es" -f ~/.ssh/web
  ```
  Cambia correo por el tuyo propio. Y pega la clave pública en la tarea preparada en aules para tal fin.

  2. Ahora debes crear en tu ordenador local un index.html que contenga tu nombre y apellidos, tu correo y tu curso. No pongo el código de html para que lo realices tu en visualStudio. Para ello recuerda, crea en local una carpeta llamada por ejemplo P4, entra en ella y ejecuta code . (El punto te abrirá la carpeta en visualStudio)

     * Deberás tener instalado git
     * Inicializado git
     * Crear el index.html
     * y hacer los pasos necesarios para que index.html pase a la rama master.

  3. Conectate al repositorio de github, el que creaste o uno nuevo y realiza el push hacia el repositorio. Verás reflejado también en el repositorio el index.html.
    * Sería conveniente que en local veas también la publicación de la página. Pero lo veremos más adelante con algún servicio web.
  4. Conéctate a tu página web pública, será del estilo correo.iespublico.com. Si tu dirección de correo tenía un punto se sustituirá por un -, por ejemplo p.segarracabedo, la web será p-segarracabedo.iespublico.com
  De momento la web será sin certificado, a lo largo del curso aprenderemos a hacerla con certificado SSL.
  5. [Tarea explicada en clase] Ahora debes conectarte al servidor correspondiente por ssh y realizar desde allí un pull a tu github para subir el index.html. Debes "estudiar" dónde se guardan las páginas web en un servidor Apache. La estructura será en ......../el_nombre_del_subdominio.
  Si todo ha ido bien [Después de la explicación, la realizarás en casa o en AWS] , veremos en tu subdominio.iespublico.com, tu index.html publicado.
  




!!!Task "¿Qué tienes que entregar?"
    1. La URL de GitHub para acceder al fichero que has creado.
    2. La URL de tu subdominio.iespublico.com
    3. Captura de que el index.html se vé correcto en tu subdominio.iespublico.com
