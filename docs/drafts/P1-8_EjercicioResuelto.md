# Ejercicio resuelto de ramas Git
## Objetivos
Los objetivos de este ejercicio son:
- Conocer cómo crear y eliminar ramas.
- Conocer cómo realizar cambios en una rama.
- Conocer cómo cambiar de rama.
- Conocer cómo fusionar ramas.
- Conocer cómo cambiar la base de una rama.
- Conocer cómo resolver conflictos en la fusión de ramas.
- Conocer cómo resolver conflictos en el cambio de base de una rama.

---
## Ejercicio
### Inicialización
1. Comprueba el estado del repositorio con:

```bash
git status
git lga
```

Después de cada orden, interpreta los diferentes estados de los ficheros.

2. Crea el nuevo repositorio en una carpeta independiente para evitar conflictos con ejercicios anteriores.

3. Crea un directorio llamado `bloc2_exercici` e inicializa el repositorio:

```bash
mkdir bloc2_exercici
cd bloc2_exercici
git init
```

4. Crea un fichero llamado `llibres.txt` y añade tres libros que te gusten:

```bash
echo "Libro 1" > llibres.txt
echo "Libro 2" >> llibres.txt
echo "Libro 3" >> llibres.txt
git add llibres.txt
git commit -m "Añadidos tres libros iniciales"
```

5. Cambia el nombre de la rama principal a `main`:

```bash
git branch -M main
```

---
### Configuración de alias para historial visual

```bash
git config --global alias.lg "log --graph --abbrev-commit --decorate \
--format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) \
%C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'"

git config --global alias.lga "lg --all"
```

!!! note
    - `git lg` muestra el historial de commits de la rama actual en formato gráfico y colorido.
    - `git lga` muestra todas las ramas (locales y remotas).
    - Estos alias ayudan a visualizar de forma clara el historial y las fusiones.

---
## Fusión directa

1. Crea una rama llamada `musica` y cámbiate a ella:

```bash
git switch -c musica
```

2. Crea el archivo `musica.txt` con tres canciones que te gusten y haz commit.

3. Vuelve a `main` y fusiona la rama `musica`:

```bash
git switch main
git merge musica
```

---
## Fusión de ramas divergentes

1. Desde `main`, crea las ramas `mes-llibres` y `mes-musica`.
2. En `mes-llibres`, añade un libro a `llibres.txt` y haz commit.
3. En `mes-musica`, añade una canción a `musica.txt` y haz commit.
4. Fusiona ambas con `main`:

```bash
git switch main
git merge mes-llibres
git merge mes-musica
```

!!! note
    En este punto se produce una **fusión divergente**, ya que `main` debe integrar los commits de ambas ramas.

---
## Resolución de conflictos en la fusión

1. Desde `main`, crea las ramas `llibres-ciencia-ficcio` y `llibres-fantasia`.
2. En cada una, añade un nuevo libro a `llibres.txt` y haz commit.
3. Fusiona primero `llibres-ciencia-ficcio` con `main`, y después `llibres-fantasia`.

!!! warning
    Al fusionar `llibres-fantasia` con `main`, Git detectó que `llibres.txt` había sido modificado también en `llibres-ciencia-ficcio`.
    Se generó un conflicto porque Git no puede decidir automáticamente qué líneas conservar.

**Resolución:**

1. Edita el archivo `llibres.txt`, elimina las marcas de conflicto (`<<<<<<<`, `=======`, `>>>>>>>`) y conserva ambas líneas.
2. Ejecuta:

```bash
git add llibres.txt
git commit
```

El resultado es un **commit de fusión (merge commit)** que integra correctamente ambas ramas.

---
## Eliminación de una rama

1. Desde `main`, crea las ramas `series` y `pelicules`.
2. En `series`, crea el archivo `series.txt`, añade una serie y haz commit.
3. Elimina ambas ramas:

```bash
git branch -D pelicules
git branch -D series
```

!!! note
    Al eliminar la rama `series` con `-D`, el commit que contenía se pierde porque no se había fusionado con `main`.

!!! warning
    El commit queda **huérfano**, ya que ninguna rama apunta a él. Git lo eliminará automáticamente durante el proceso de *garbage collection*.
    Esta acción es correcta en este caso, ya que se trata de una rama de prueba sin relevancia.

---
## Cambio de base de una rama (Rebase)

1. Desde `main`, crea las ramas `series` y `pelicules`.
2. En `series`, añade una serie y haz commit.
3. En `pelicules`, añade una película y haz commit.
4. Fusiona `pelicules` con `main`:

```bash
git switch main
git merge pelicules
```

5. Cambia la base de `series` a `main`:

```bash
git switch series
git rebase main
```

6. Fusiona `series` con `main`:

```bash
git switch main
git merge series
```

!!! note
    Este proceso permite mantener la historia **lineal**.
    Con el rebase de `series`, los commits se aplican sobre la versión actualizada de `main`.

---
## Resolución de conflictos en el cambio de base

1. Desde `main`, crea las ramas `series-accio` y `series-drama`.
2. En cada una, modifica `series.txt` añadiendo una serie diferente.
3. Fusiona `series-accio` con `main`.
4. Realiza el rebase de `series-drama` sobre `main`.

!!! warning
    Al ejecutar `git rebase main` desde `series-drama`, se generó un conflicto en `series.txt`, ya que `series-accio` había modificado el mismo archivo.

**Resolución:**

1. Edita el archivo `series.txt` para mantener ambas series.
2. Ejecuta los comandos:

```bash
git add series.txt
git rebase --continue
```

El conflicto quedó resuelto y el historial de `main` se mantuvo lineal.

---
## Evidencias (capturas)

A continuación se incluyen las capturas extraídas del documento `Ejercicio - Ramas_v3.pdf` en el mismo orden en que aparecen:

![Captura ramas_v3_p1_1.png](img_ramas_v3/ramas_v3_p1_1.png)

![Captura ramas_v3_p2_1.png](img_ramas_v3/ramas_v3_p2_1.png)

![Captura ramas_v3_p2_2.png](img_ramas_v3/ramas_v3_p2_2.png)

![Captura ramas_v3_p2_3.jpeg](img_ramas_v3/ramas_v3_p2_3.jpeg)

![Captura ramas_v3_p2_4.png](img_ramas_v3/ramas_v3_p2_4.png)

![Captura ramas_v3_p2_5.png](img_ramas_v3/ramas_v3_p2_5.png)

![Captura ramas_v3_p3_1.png](img_ramas_v3/ramas_v3_p3_1.png)

![Captura ramas_v3_p3_2.png](img_ramas_v3/ramas_v3_p3_2.png)

![Captura ramas_v3_p3_3.jpeg](img_ramas_v3/ramas_v3_p3_3.jpeg)

![Captura ramas_v3_p3_4.png](img_ramas_v3/ramas_v3_p3_4.png)

![Captura ramas_v3_p3_5.jpeg](img_ramas_v3/ramas_v3_p3_5.jpeg)

![Captura ramas_v3_p4_1.png](img_ramas_v3/ramas_v3_p4_1.png)

![Captura ramas_v3_p4_2.jpeg](img_ramas_v3/ramas_v3_p4_2.jpeg)

![Captura ramas_v3_p4_3.jpeg](img_ramas_v3/ramas_v3_p4_3.jpeg)

![Captura ramas_v3_p4_4.png](img_ramas_v3/ramas_v3_p4_4.png)

![Captura ramas_v3_p4_5.jpeg](img_ramas_v3/ramas_v3_p4_5.jpeg)

![Captura ramas_v3_p5_1.png](img_ramas_v3/ramas_v3_p5_1.png)

![Captura ramas_v3_p5_2.png](img_ramas_v3/ramas_v3_p5_2.png)

![Captura ramas_v3_p5_3.jpeg](img_ramas_v3/ramas_v3_p5_3.jpeg)

![Captura ramas_v3_p5_4.png](img_ramas_v3/ramas_v3_p5_4.png)

![Captura ramas_v3_p5_5.png](img_ramas_v3/ramas_v3_p5_5.png)

![Captura ramas_v3_p6_1.png](img_ramas_v3/ramas_v3_p6_1.png)

![Captura ramas_v3_p6_2.png](img_ramas_v3/ramas_v3_p6_2.png)

![Captura ramas_v3_p6_3.png](img_ramas_v3/ramas_v3_p6_3.png)

![Captura ramas_v3_p7_1.png](img_ramas_v3/ramas_v3_p7_1.png)

![Captura ramas_v3_p7_2.png](img_ramas_v3/ramas_v3_p7_2.png)

![Captura ramas_v3_p7_3.png](img_ramas_v3/ramas_v3_p7_3.png)

![Captura ramas_v3_p7_4.png](img_ramas_v3/ramas_v3_p7_4.png)

![Captura ramas_v3_p7_5.png](img_ramas_v3/ramas_v3_p7_5.png)

![Captura ramas_v3_p8_1.png](img_ramas_v3/ramas_v3_p8_1.png)

![Captura ramas_v3_p8_2.png](img_ramas_v3/ramas_v3_p8_2.png)

![Captura ramas_v3_p8_3.png](img_ramas_v3/ramas_v3_p8_3.png)

![Captura ramas_v3_p8_4.jpeg](img_ramas_v3/ramas_v3_p8_4.jpeg)

![Captura ramas_v3_p8_5.png](img_ramas_v3/ramas_v3_p8_5.png)

![Captura ramas_v3_p9_1.jpeg](img_ramas_v3/ramas_v3_p9_1.jpeg)

![Captura ramas_v3_p9_2.jpeg](img_ramas_v3/ramas_v3_p9_2.jpeg)

![Captura ramas_v3_p9_3.png](img_ramas_v3/ramas_v3_p9_3.png)

![Captura ramas_v3_p9_4.png](img_ramas_v3/ramas_v3_p9_4.png)

![Captura ramas_v3_p10_1.jpeg](img_ramas_v3/ramas_v3_p10_1.jpeg)

![Captura ramas_v3_p10_2.png](img_ramas_v3/ramas_v3_p10_2.png)

![Captura ramas_v3_p10_3.png](img_ramas_v3/ramas_v3_p10_3.png)

![Captura ramas_v3_p10_4.png](img_ramas_v3/ramas_v3_p10_4.png)

![Captura ramas_v3_p11_1.jpeg](img_ramas_v3/ramas_v3_p11_1.jpeg)

![Captura ramas_v3_p12_1.png](img_ramas_v3/ramas_v3_p12_1.png)

![Captura ramas_v3_p12_2.png](img_ramas_v3/ramas_v3_p12_2.png)

![Captura ramas_v3_p12_3.jpeg](img_ramas_v3/ramas_v3_p12_3.jpeg)

![Captura ramas_v3_p13_1.jpeg](img_ramas_v3/ramas_v3_p13_1.jpeg)

![Captura ramas_v3_p13_2.jpeg](img_ramas_v3/ramas_v3_p13_2.jpeg)

![Captura ramas_v3_p13_3.png](img_ramas_v3/ramas_v3_p13_3.png)

![Captura ramas_v3_p14_1.png](img_ramas_v3/ramas_v3_p14_1.png)

![Captura ramas_v3_p14_2.png](img_ramas_v3/ramas_v3_p14_2.png)

![Captura ramas_v3_p14_3.jpeg](img_ramas_v3/ramas_v3_p14_3.jpeg)

![Captura ramas_v3_p14_4.png](img_ramas_v3/ramas_v3_p14_4.png)

![Captura ramas_v3_p15_1.png](img_ramas_v3/ramas_v3_p15_1.png)

![Captura ramas_v3_p15_2.png](img_ramas_v3/ramas_v3_p15_2.png)

![Captura ramas_v3_p15_3.png](img_ramas_v3/ramas_v3_p15_3.png)

![Captura ramas_v3_p15_4.jpeg](img_ramas_v3/ramas_v3_p15_4.jpeg)

![Captura ramas_v3_p15_5.jpeg](img_ramas_v3/ramas_v3_p15_5.jpeg)

![Captura ramas_v3_p16_1.jpeg](img_ramas_v3/ramas_v3_p16_1.jpeg)

![Captura ramas_v3_p16_2.jpeg](img_ramas_v3/ramas_v3_p16_2.jpeg)

![Captura ramas_v3_p17_1.jpeg](img_ramas_v3/ramas_v3_p17_1.jpeg)

![Captura ramas_v3_p17_2.jpeg](img_ramas_v3/ramas_v3_p17_2.jpeg)

![Captura ramas_v3_p18_1.png](img_ramas_v3/ramas_v3_p18_1.png)

![Captura ramas_v3_p18_2.png](img_ramas_v3/ramas_v3_p18_2.png)

![Captura ramas_v3_p18_3.jpeg](img_ramas_v3/ramas_v3_p18_3.jpeg)

![Captura ramas_v3_p18_4.png](img_ramas_v3/ramas_v3_p18_4.png)

![Captura ramas_v3_p18_5.png](img_ramas_v3/ramas_v3_p18_5.png)

![Captura ramas_v3_p19_1.jpeg](img_ramas_v3/ramas_v3_p19_1.jpeg)

![Captura ramas_v3_p19_2.png](img_ramas_v3/ramas_v3_p19_2.png)

![Captura ramas_v3_p19_3.jpeg](img_ramas_v3/ramas_v3_p19_3.jpeg)

![Captura ramas_v3_p19_4.png](img_ramas_v3/ramas_v3_p19_4.png)

![Captura ramas_v3_p20_1.jpeg](img_ramas_v3/ramas_v3_p20_1.jpeg)

![Captura ramas_v3_p20_2.png](img_ramas_v3/ramas_v3_p20_2.png)

![Captura ramas_v3_p20_3.png](img_ramas_v3/ramas_v3_p20_3.png)

![Captura ramas_v3_p21_1.png](img_ramas_v3/ramas_v3_p21_1.png)

![Captura ramas_v3_p21_2.png](img_ramas_v3/ramas_v3_p21_2.png)

![Captura ramas_v3_p21_3.png](img_ramas_v3/ramas_v3_p21_3.png)

![Captura ramas_v3_p22_1.png](img_ramas_v3/ramas_v3_p22_1.png)

![Captura ramas_v3_p22_2.png](img_ramas_v3/ramas_v3_p22_2.png)

![Captura ramas_v3_p22_3.jpeg](img_ramas_v3/ramas_v3_p22_3.jpeg)

![Captura ramas_v3_p23_1.jpeg](img_ramas_v3/ramas_v3_p23_1.jpeg)

---
## Conclusión

Este ejercicio permite practicar los conceptos fundamentales de Git:

- Creación y gestión de ramas.
- Fusiones directas y divergentes.
- Resolución manual de conflictos.
- Eliminación de ramas y commits huérfanos.
- Uso del rebase para mantener un historial limpio.

!!! tip
    Las decisiones tomadas (mantener ambas inserciones, eliminar ramas de prueba y resolver conflictos manualmente) son correctas y coherentes con el flujo de trabajo profesional en Git.
