# Práctica 2 – Fase 3: Verificación de despliegue y acceso en servidor

**Centro:** IES El Caminàs  
**Módulo:** Despliegue de Aplicaciones Web
**Profesor:** Pedro Segarra  
**Curso:** 2025/2026  

---

## Objetivo

Comprobar que la imagen Docker publicada en GitHub Container Registry (GHCR) funciona correctamente tanto en local como en el servidor del profesor (`iespublico.com`).

Esta fase reproduce el ciclo completo de despliegue profesional:

1. Descargar la imagen publicada desde GHCR.  
2. Ejecutarla en local.  
3. Verificar el acceso en el navegador local.  
4. Verificar el acceso remoto en el servidor del profesor.

---

## 1. Preparar el entorno local

Verifica que Docker está instalado y operativo:

```bash
docker --version
```

!!! info "Comprobación del entorno"
    Si el comando devuelve un número de versión (por ejemplo `24.0.6`), puedes continuar.  
    Si no reconoce el comando, revisa la instalación de Docker.

---

## 2. Descargar la imagen publicada desde GHCR

Comprueba que tu imagen es pública y accesible.  
Sustituye `<usuario>` por tu nombre de usuario en GitHub:

```bash
docker pull ghcr.io/<usuario>/p2:1.0
```

!!! success "Resultado esperado"
    Si se descarga correctamente, verás un mensaje similar a:

    ```
    Status: Downloaded newer image for ghcr.io/<usuario>/p2:1.0
    ghcr.io/<usuario>/p2:1.0
    ```

!!! warning "Posibles errores"
    Si aparece un error de autenticación o “not found”, revisa:
    - Que en GitHub → *Profile → Packages* la imagen esté marcada como **Public**.
    - Que el nombre y el tag (`p2:1.0`) sean correctos.
    - Que no hayas cerrado tu cuenta o eliminado el paquete.

---

## 3. Ejecutar la imagen en local

Ejecuta tu contenedor simulando el despliegue en un servidor web:

```bash
docker run -d --name p2test -p 8080:80 ghcr.io/<usuario>/p2:1.0
```

!!! info "Descripción del comando"
    Este comando ejecuta el servidor Apache dentro del contenedor y lo publica localmente en el puerto **8080**.  
    Si ya tienes un contenedor con el mismo nombre, puedes cambiarlo (`--name p2test2`) o eliminar el anterior.

---

## 4. Verificar el acceso local

Abre el navegador y accede a:

```
http://localhost:8080/P2/
```

!!! success "Resultado esperado"
    Debería mostrarse el archivo `index.html` con tus datos.

!!! warning "Errores comunes"
    - Si se muestra la página *It works*, significa que el `index.html` no está en la ruta correcta.  
    - Si aparece un error 404, revisa:
      - Que el `Dockerfile` incluya `COPY . /usr/local/apache2/htdocs/P2/`.  
      - Que el nombre de la carpeta `P2` coincida exactamente.

---

## 5. Parar y eliminar el contenedor local

Una vez verificado el funcionamiento, detén y elimina el contenedor:

```bash
docker stop p2test
docker rm p2test
```

!!! info "Recomendación"
    Es buena práctica detener los contenedores una vez validados, para evitar conflictos en el puerto 8080 o consumo innecesario de recursos.

---

## 6. Verificación en el servidor del profesor

Cuando el profesor despliegue las imágenes en el servidor `iespublico.com`, cada alumno tendrá una dirección pública con su subdominio:

```
http://<tu_subdominio>.iespublico.com/P2/
```

Ejemplo:

```
http://peseca.iespublico.com/P2/
```

!!! success "Resultado esperado"
    La página debe mostrarse igual que en local.  
    Si se visualiza correctamente, el despliegue ha sido exitoso.

!!! warning "En caso de error"
    - Avisa al profesor si tu subdominio no carga o muestra otra página.  
    - Comprueba que tu imagen sigue siendo pública en GHCR.

---

## 7. Entrega en Aules

Debes entregar una **captura de pantalla** que muestre:

1. Tu navegador con `http://localhost:8080/P2/` funcionando.  
2. La página publicada en `http://<tu_subdominio>.iespublico.com/P2/` una vez desplegada.

Incluye también un breve comentario indicando si la descarga (`docker pull`) y el despliegue funcionaron correctamente.

!!! info "Formato de entrega"
    - Formato recomendado: imagen PNG o PDF.  
    - Nombra el archivo con tu usuario GitHub, por ejemplo: `peseca_fase3.png`.

---

## 8. Consejos finales

- Si `docker pull` pide autenticación, tu imagen no es pública.  
- Si el servidor remoto no muestra tu página, contacta con el profesor para revisar el despliegue.  
- No elimines tu imagen de GHCR hasta final de curso.  
- Revisa periódicamente que sigue visible en tu perfil de GitHub, sección **Packages**.

---

## Resultado esperado

!!! success "Práctica completada correctamente"
    - La imagen `ghcr.io/<usuario>/p2:1.0` se descarga sin errores.  
    - La página se muestra en local en `http://localhost:8080/P2/`.  
    - La página se muestra en el servidor del profesor en `http://<subdominio>.iespublico.com/P2/`.

---

**Fin de la Fase 3**  
IES El Caminàs – Módulo Despliegue de Aplicaciones Web
