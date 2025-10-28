# Práctica P2 – Fase 2: Publicación en GitHub Container Registry (GHCR)

**Centro:** IES El Caminàs  
**Módulo:** Despliegue de Aplicaciones Web  
**Curso:** 2025/2026  

---

## Objetivo de la fase

Publicar la imagen Docker creada en la Fase 1 en el **GitHub Container Registry (GHCR)** y verificar que es **accesible de forma pública**.  
En esta fase **no** se realiza el despliegue en el servidor del profesor. Ese paso se abordará en una fase posterior.

---

## Requisitos previos

- Haber completado la **Fase 1** (imagen local construida como `p2:1.0`).  
- Repositorio Git en GitHub para el código fuente (acceso por **SSH**).  
- Docker instalado en el equipo local.

!!! note "Recordatorio"
    GHCR requiere autenticación mediante **token personal (PAT)** para `docker login/push`.  
    Las **claves SSH** se usan únicamente para Git (código fuente), no para GHCR.

---
 

## 1. Subir el proyecto a GitHub (por SSH)

Desde la carpeta del proyecto `P2`:

```bash
git init
git add .
git commit -m "Versión inicial Fase 2"
git branch -M main
git remote add origin git@github.com:usuario/P2.git
git push -u origin main
```

!!! note "Conexión SSH"
    Asegúrate de tener configurado `~/.ssh/config`:
    ```bash
    Host github.com
      HostName github.com
      User git
      IdentityFile ~/.ssh/id_ed25519
    ```

---
!!! note "Cuidado"
    En vez de poner id_ed25519, pon tu clave
    
---

## 2. Etiquetar la imagen local con el espacio de nombres de GHCR

```bash
docker tag p2:1.0 ghcr.io/usuario/p2:1.0
```

!!! note "Sustitución obligatoria"
    Cambia `usuario` por tu **nombre real de cuenta GitHub**.  
    Ejemplo: `https://github.com/juanperez01` → usuario = `juanperez01`.

---

## 3. Crear token personal y autenticarse en GHCR

1. GitHub → **Settings → Developer settings → Personal access tokens → Tokens (classic)**.  
2. Generar un token con permisos:
   - `write:packages`
   - `read:packages`
   - `delete:packages` (opcional, solo si quieres poder borrar).

Iniciar sesión en GHCR:

```bash
echo "TOKEN_AQUI" | docker login ghcr.io -u usuario --password-stdin
```

Salida esperada:
```
Login Succeeded
```

!!! warning "Importante"
    GHCR **no** acepta claves SSH para `push/pull` de imágenes. Usa **token**.

---

## 4. Publicar la imagen en GHCR

```bash
docker push ghcr.io/usuario/p2:1.0
```

!!! success "Resultado esperado"
    La imagen `p2:1.0` se sube correctamente.  
    Podrás verla en tu perfil de GitHub → pestaña **Packages**.

---

## 5. Hacer la imagen pública

Por defecto, la imagen queda **privada**. Cambiar a **pública**:

1. GitHub → **Profile → Packages** → seleccionar el paquete `p2`.  
2. **Package settings** → **Change visibility** → **Public**.

!!! warning "Obligatorio"
    Si no cambias la visibilidad, otros no podrán descargar tu imagen desde GHCR.

---

## 6. Verificaciones finales

### 6.1. Comprobar desde la web
- Ve a **Profile → Packages** y confirma que aparece el paquete `p2` con la etiqueta `1.0`.
- Debe indicarse que la visibilidad es **Public**.

### 6.2. Comprobar con `docker pull` (opcional)
Haz logout y prueba a descargar **sin credenciales**:

```bash
docker logout ghcr.io
docker pull ghcr.io/usuario/p2:1.0
```
Usuario es tu usuario de github. 
Si funciona sin pedir login, la imagen es realmente pública.

---

## 7. Entrega de la Fase 2

El alumno entregará:
1. URL del repositorio GitHub del proyecto:  
   `https://github.com/usuario/P2`  
2. URL pública del paquete GHCR (captura o enlace):  
   `ghcr.io/usuario/p2:1.0`  
3. Captura de pantalla de **Packages** mostrando el paquete `p2` como **Public** y la etiqueta `1.0`.

---

## 8. Problemas comunes y soluciones

!!! warning "denied: requested access to the resource is denied"
    - Causa: no has hecho `docker login ghcr.io` con token válido, o `usuario` no coincide con tu cuenta GitHub.  
    - Solución:
      ```bash
      echo "TOKEN_AQUI" | docker login ghcr.io -u usuario --password-stdin
      docker tag p2:1.0 ghcr.io/usuario/p2:1.0
      docker push ghcr.io/usuario/p2:1.0
      ```

!!! warning "name unknown: repository not found"
    - Causa: estás empujando a `ghcr.io/usuario/p2:1.0` con `usuario` incorrecto.  
    - Verifica tu perfil: `https://github.com/<usuario>`.

!!! note "La imagen no aparece en Packages"
    - Asegúrate de haber ejecutado `docker push ghcr.io/usuario/p2:1.0` sin errores.  
    - Recarga la página del perfil de GitHub.

!!! tip "Comprobar etiquetas locales"
    - Lista las imágenes locales:
      ```bash
      docker images
      ```
    - Debes ver dos etiquetas con **el mismo IMAGE ID**: `p2:1.0` y `ghcr.io/usuario/p2:1.0`.

---

## 9. Resumen de comandos

```bash
# 1) Subir código a GitHub (SSH)
git init && git add . && git commit -m "Versión inicial Fase 2"
git branch -M main
git remote add origin git@github.com:usuario/P2.git
git push -u origin main

# 2) Etiquetar imagen para GHCR
docker tag p2:1.0 ghcr.io/usuario/p2:1.0

# 3) Autenticación GHCR
echo "TOKEN_AQUI" | docker login ghcr.io -u usuario --password-stdin

# 4) Publicar imagen
docker push ghcr.io/usuario/p2:1.0

# 5) Verificación opcional
docker logout ghcr.io
docker pull ghcr.io/usuario/p2:1.0
```

---

## Resultado de la Fase 2

La imagen Docker `p2:1.0` ha sido publicada en **GHCR** bajo el espacio de nombres del alumno, con visibilidad pública y verificación de descarga. El despliegue en el servidor del profesor se realizará en una fase posterior.
