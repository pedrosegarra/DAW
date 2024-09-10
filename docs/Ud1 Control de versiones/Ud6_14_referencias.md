---
title: '1.14 Terminología y referencias'
---

## Terminología

Al trabajar con git haremos uso de cierta terminología común a todos los usuarios de este sistema. Aquí tienes una lista de términos que te servirán de referencia en un futuro.

Repositorio ("repository")
: El repositorio es el lugar en el que se almacenan los datos actualizados e históricos de cambios.

Revisión ("revision")
: Una revisión es una versión determinada de la información que se gestiona. Hay sistemas que identifican las revisiones con un contador (Ej. subversion). Hay otros sistemas que identifican las revisiones mediante un código de detección de modificaciones (Ej. git usa SHA1).

Etiqueta ("tag")
: Los tags permiten identificar de forma fácil revisiones importantes en el proyecto. Por ejemplo se suelen usar tags para identificar el contenido de las versiones publicadas del proyecto.

Rama ("branch")
: Un conjunto de archivos puede ser ramificado o bifurcado en un punto en el tiempo de manera que, a partir de ese momento, dos copias de esos archivos se pueden desarrollar a velocidades diferentes o en formas diferentes de forma independiente el uno del otro.

Cambio ("change")
: Un cambio (o diff, o delta) representa una modificación específica de un documento bajo el control de versiones. La granularidad de la modificación que es considerada como un cambio varía entre los sistemas de control de versiones.

Desplegar ("checkout")
: Es crear una copia de trabajo local desde el repositorio. Un usuario puede especificar una revisión en concreto u obtener la última. El término 'checkout' también se puede utilizar como un sustantivo para describir la copia de trabajo.

Confirmar ("commit")
: Confirmar es escribir o mezclar los cambios realizados en la copia de trabajo del repositorio. Los términos 'commit' y 'checkin' también se pueden utilizar como sustantivos para describir la nueva revisión que se crea como resultado de confirmar.

Conflicto ("conflict")
: Un conflicto se produce cuando diferentes partes realizan cambios en el mismo documento, y el sistema es incapaz de conciliar los cambios. Un usuario debe resolver el conflicto mediante la integración de los cambios, o mediante la selección de un cambio en favor del otro.

Cabeza ("head")
: También a veces se llama tip (punta) y se refiere a la última confirmación, ya sea en el tronco ('trunk') o en una rama ('branch'). El tronco y cada rama tienen su propia cabeza, aunque HEAD se utiliza a veces libremente para referirse al tronco.

Tronco ("trunk")
: La única línea de desarrollo que no es una rama (a veces también llamada línea base, línea principal o máster).

Fusionar, integrar, mezclar ("merge")
: Una fusión o integración es una operación en la que se aplican dos tipos de cambios en un archivo o conjunto de archivos. Algunos escenarios de ejemplo son los siguientes:

- Un usuario, trabajando en un conjunto de archivos, actualiza o sincroniza su copia de trabajo con los cambios realizados y confirmados, por otros usuarios, en el repositorio.
- Un usuario intenta confirmar archivos que han sido actualizado por otros usuarios desde el último despliegue ('checkout'), y el software de control de versiones integra automáticamente los archivos (por lo general, después de preguntarle al usuario si se debe proceder con la integración automática, y en algunos casos sólo se hace si la fusión puede ser clara y razonablemente resuelta).
- Un conjunto de archivos se bifurca, un problema que existía antes de la ramificación se trabaja en una nueva rama, y la solución se combina luego en la otra rama.
- Se crea una rama, el código de los archivos es independiente editado, y la rama actualizada se incorpora más tarde en un único tronco unificado.


# Referencias

- [Aula de Software Libre de la Universidad de Córdoba](https://www.uco.es/aulasoftwarelibre).
- [Documentación oficial en inglés](http://git-scm.com/documentation).
- [Documentación oficial en español (quizás incompleta)](http://git-scm.com/book/es).
- [Curso de Git (inglés)](http://gitimmersion.com/lab_01.html). La mayoría de la documentación de este manual está basada en este curso.
- [Curso interactivo de Git (inglés)](http://try.github.io/levels/1/challenges/1).
- [Página de referencia de todas las órdenes de Git (inglés)](http://gitref.org/).
- [Chuleta con las órdenes más usuales de Git](http://byte.kde.org/~zrusin/git/git-cheat-sheet-large.png).
- [Gitmagic (ingles y español). Otro manual de Git](http://www-cs-students.stanford.edu/~blynn/gitmagic/intl/es/)
- [Artículo técnico: Un modelo exitoso de ramificación en Git ](http://nvie.com/posts/a-successful-git-branching-model/).
- [Curso detallado y gratuito sobre Git y github](https://www.udacity.com/course/how-to-use-git-and-github--ud775)
- [Otra guia rápida de git](https://github.com/github/training-kit/blob/master/downloads/github-git-cheat-sheet.pdf)
- [Guía de estilos según Udacity](http://udacity.github.io/git-styleguide/)
- [Flujo de trabajo de Gitflow](https://www.atlassian.com/es/git/tutorials/comparing-workflows/gitflow-workflow)
- [Libro Pro Git](https://git-scm.com/book/en/v2)
