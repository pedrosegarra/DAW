---
title:  "Linux Server en AWSAcademy"
---
# Linux Server en AWS Academy

En esta nota veremos cómo crear un servidor Linux en AWS. El servidor Linux no tendrá entorno gráfico, sólo de comandos, por lo que nos bastará acceder a él por SSH.

Primero, debemos acceder al [portal de AWS Academy](https://www.awsacademy.com/vforcesite/LMS_Login){:target="_blank"} utilizando nuestra cuenta de AWS Academy.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/01_1.png)

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/01_2.png)

En las siguientes imágenes, mostraremos con un cuadro rojo las opciones a selecciona o en aquellas que deben cambiarse o revisarse. Puedes olvidarte del resto de las opciones disponibles por ahora.

Accede al LMS, donde encontrarás los cursos disponibles.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/01_3.png)

Busca el **Learner Lab** que tu profesor ha preparado para este curso. Previamente te habrá invitado y habrás tenido que aceptar la invitación para tener acceso al mismo.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/01_4.png)

Selecciona "Módulos" para acceder al laboratorio.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/02.png)

Abre el "Laboratorio de Aprendizaje".

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/03.png)

Inicia el laboratorio:

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/04.png)

Una vez iniciado, verás un punto verde junto a **AWS**. Haz clic allí para abrir la consola de AWS y comenzar a trabajar.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/05.png)

Ahora tienes acceso a la consola de AWS. Dependiendo de tu uso previo de esta consola, es posible que veas diferentes elementos en la pantalla.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/06.png)

En AWS, los servidores virtuales se llaman EC2, así que comencemos por crear un EC2. Puedes hacerlo de diferentes maneras. Veamos una de ellas. Desplázate hacia abajo hasta "Crear una solución" y haz clic en "Iniciar una máquina virtual"

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/07.png)

Ahora debemos proporcionar los parámetros necesarios para crear la máquina. Sigue las pantallas con los datos proporcionados.

Vamos a crear un servidor linux Debian. En primer lugar seleccionamos un nombre y tipo de servidor:

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/08.png)

A continuación, en "Tipo de instancia" seleccionaremos el procesador y la memoria. Ten en cuenta que a mayor potencia, mayor costo. Para esta práctica nos bastará el más sencillo.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/09.png)

La sección de "Par de claves" (inicio de sesión) es muy importante, ya que aquí crearemos el par de claves que nos permitirá acceder al servidor de forma remota. Creemos un nuevo par de claves que nos pueden servir para el resto del curso.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/10.png)

Asegúrate de guardar el par de claves en tu computadora o no podrás acceder al servidor después.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/11.png)

Ahora, tras volver a la pantalla anterior, selecciona el par de claves generadas.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/12.png)

Debemos definir la configuración de red de nuestra VM. En AWS al Firewall se le denomina "Grupo de seguridad", y en él definiremos todas las reglas necesarias para permitir y denegar accesos a nuestra VM. En este caso sólo habilitaremos el acceso por SSHpara gestionar la máquina, así que bastará con aceptar la configuración por defecto ofrecida.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/13.png)

Finalmente, debemos configurar el almacenamiento. Proporcionemos un volumen de 20 GiB.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/14.png)

Verifica todas las opciones seleccionadas y lanza la instancia.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/15.png)

Si todo va bien, la instancia se creará y obtendremos un mensaje que lo indica.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/16.png)

Si hacemos click sobre el código de la instancia pasaremos a la consola de EC2 y veremos que la VM está en ejecución y todos sus datos relacionados, entre ellos la dirección IP pública que necesitaremos más tarde para acceder a la misma.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/17.png)

Ahora podemos acceder al servidor utilizando SSH. Primero haz clic en "Conectar" para permitir la conexión. Selecciona el cliente SSH. Ahí tienes toda la información necesaria para realizar la conexión.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/18.png)

Recuerda el "par de claves" que te dije que almacenaras en tu computadora previamente. Ese es el que debes usar ahora. AWS asume que se guardó con extensión `.pem` pero si se ha guardado con otra extensión, cámbialo previamente. Aquí te muestro una secuencia de conexión, asumiendo que el certificado se guardó con extensión `.cer`.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/19.png)

Como verás, ya estás dentro del servidor debian que hemos instalado.

Podemos comprobar cómo la capacidad del disco y la memoria coinciden con la que configuramos en la consola AWS.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/20.png)



> RECUERDA
>
> La IP pública de la VM podría cambiar. Comprueba antes de cada conexión la IP de la máquina.

## Finaliza el laboratorio

Al finalizar cada sesion de trabajo recuerda que debes finalizar el laboratorio. Ve a la consola de AWS Academy y presiona "Finalizar laboratorio". Si no lo haces, el laboratorio se cerrará automáticamente después de 4 horas pero habrás gastado más saldo del necesario.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/21.png)

Comprueba que el laboratorio esta parado. El punto junto a AWS deberá estar de color rojo.

![LinuxServerInstallationAWS](img/Linux_Server_in_AWSAcademy/22.png)