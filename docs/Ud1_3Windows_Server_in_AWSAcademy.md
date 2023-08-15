---
title:  "Windows Server en AWSAcademy"
---
# Windows Server en AWS Academy

En esta nota veremos cómo crear un servidor Windows en AWS. La principal diferencia con un servidor Linux es que accederemos al servidor mediante un entorno gráfico mediante el protocolo RDP.

Primero, debemos acceder al [portal de AWS Academy](https://www.awsacademy.com/vforcesite/LMS_Login){:target="_blank"} utilizando nuestra cuenta de AWS Academy.

En las siguientes imágenes, mostraremos con un cuadro rojo las opciones que deben cambiarse o revisarse. Puedes olvidarte del resto de las opciones disponibles por ahora.

Una vez iniciada la sesión, busca el **Learner Lab** que tu profesor ha preparado para este curso.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/01.png)

Selecciona "Módulos" para acceder al laboratorio.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/02.png)

Abre el "Laboratorio de Aprendizaje".

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/03.png)

Inicia el laboratorio:

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/04.png)

Una vez iniciado, verás un punto verde junto a AWS. Haz clic allí para abrir la consola de AWS y comenzar a trabajar.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/05.png)

Ahora tienes acceso a la consola de AWS. Dependiendo de tu uso previo de esta consola, es posible que veas diferentes elementos en la pantalla.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/06.png)

En AWS, los servidores virtuales se llaman EC2. Comencemos por crear un EC2. Puedes hacerlo de diferentes maneras. Veamos una de ellas. Desplázate hacia abajo hasta "Crear una solución" y haz clic en "Iniciar una máquina virtual"

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/07.png)

Debemos proporcionar los parámetros para crear la máquina. Sigue las pantallas con los datos proporcionados.

Un Windows Server 2016 será suficiente para esta práctica:

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/08.png)

Vamos a crear una máquina potente. Podemos elegir un tipo de instancia t2.large con 2 CPU virtuales y 8 GiB de memoria.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/09.png)

La sección de "Par de claves" (inicio de sesión) es muy importante, ya que aquí crearemos el par de claves que nos permitirá acceder al servidor de forma remota. Creemos un nuevo par de claves. Si ya tuviéramos unas creadas y guardadas podríamos seleccionarlas.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/10.png)

Asegúrate de guardar el par de claves en tu computadora o no podrás acceder al servidor después.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/11.png)

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/12.png)

Debemos definir la configuración de red de nuestra VM. Necesitamos acceder a través de RDP. En el módulo de DAW vamos a instalar servicios web, así que vamos a habilitar también el acceso por HTTP y HTTPS. Permitamos RDP, HTTP y HTTPS desde Internet.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/13.png)

Finalmente, debemos configurar el almacenamiento. Proporcionemos un volumen de 80 GiB.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/14.png)

Verifica todas las opciones seleccionadas y lanza la instancia.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/15.png)

Si todo va bien, la instancia se creará y ahora podemos verla en la consola EC2.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/16.png)

En la consola de EC2, vemos que la VM está en ejecución y todos los datos relacionados, como la dirección IP pública que necesitaremos más tarde para acceder a la misma.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/17.png)

Ahora podemos acceder al servidor utilizando RDP. Primero haz clic en "Conectar" para permitir la conexión. Selecciona el cliente RDP. Y, en primer lugar, obtén la contraseña del administrador.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/18.png)

Recuerda el "par de claves" que te dije que almacenaras en tu computadora previamente. Ese es el que debes usar ahora. Usa "Cargar archivo de clave privada" y carga tu "par de claves" almacenado.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/19.png)

Una vez leído, puedes "Descifrar contraseña"

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/20.png)

Será una contraseña difícil de recordar. Solo cópiala y luego podrás cambiarla desde el interior del servidor Windows.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/21.png)

Es una buena práctica crear un documento de texto y copiar allí toda la información de la pantalla "Conectar a la instancia": ID de instancia, DNS público, nombre de usuario y contraseña. 

Ahora podemos usar un software de escritorio remoto para hacer la conexión. En Lliurex tenemos KRDC y Remmina. También podríamos usar Windows Remote Desktop en Windows o Mac.



## Conexión usando KRDC

En las siguientes imágenes, podemos ver cómo usar KRDC para hacer la conexión.

Simplemente selecciona el protocolo RDP y el DNS público (en lugar de la IP que se muestra en la imagen).

![WindowsServerInstallation](img/Windows_Server_in_AWSAcademy/19_2.png)

Podemos configurar algunas cosas, como la resolución de pantalla o el teclado. También puedes hacer una carpeta en tu disco duro disponible para tu VM, de la misma manera que usas carpetas compartidas en VirtualBox.

![WindowsServerInstallation](img/Windows_Server_in_AWSAcademy/20_2.png)

Luego te pedirá el usuario y la contraseña.

![WindowsServerInstallation](img/Windows_Server_in_AWSAcademy/21_2.png)

![WindowsServerInstallation](img/Windows_Server_in_AWSAcademy/22_2.png)

Y se establecerá la conexión.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/23.png)

## Conexión usando Microsoft Remote Desktop

Puedes usar Microsoft Remote Desktop en Windows y Mac.

Como en KRDC, podemos compartir carpetas entre nuestra computadora y la Máquina Virtual, de la misma manera que compartimos carpetas en un software de virtualización (como VirtualBox).

Descarga el software para Windows desde [Microsoft Store](https://apps.microsoft.com/){:target="_blank"} o para Mac en la [App Store](https://www.apple.com/es/app-store/){:target="_blank"}.

Ahora podemos "Descargar archivo de escritorio remoto" para acceder rápidamente al servidor. Simplemente descarga el archivo RDP desde AWS y luego haz doble clic en él.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/19.png)

Pero aconsejo hacerlo de esta otra manera para crear primero una carpeta compartida. Abre Microsoft Remote Desktop y ve al menú "Conexiones -> Agregar PC".

Luego sigue los pasos. Completa el nombre de PC con el DNS público de la VM. En la cuenta de usuario, crea una nueva para el usuario "Administrador" creado previamente con la contraseña obtenida.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/22.png)

En la pestaña "Carpetas", crea una carpeta compartida con tu computadora. Primero crea la carpeta local. Luego, usa el botón "+" para agregarla.

![WindowsServerInstallation](img/Windows_Server_in_AWSAcademy/22-2.png)

La próxima vez que abras la conexión, encontrarás una unidad de red en tu VM que es la carpeta local en tu PC. Es una forma muy conveniente de compartir archivos entre ambos sistemas.

![WindowsServerInstallation](img/Windows_Server_in_AWSAcademy/22-3.png)

Una vez que se haya completado toda la configuración, lo encontrarás en la página principal cada vez que abras la aplicación.

> RECUERDA
>
> La IP pública de la VM podría cambiar. Tendrás que editar la conexión creada cada vez que quieras conectarte a la VM, pero solo tendrás que cambiar la dirección IP, manteniendo el resto de la configuración.

![WindowsServerInstallation](img/Windows_Server_in_AWSAcademy/22-1.png)

## Finaliza el laboratorio

Al finalizar cada sesion de trabajo recuerda que debes finalizar el laboratorio. Ve a la consola de AWS Academy y presiona "Finalizar laboratorio". Si no lo haces, el laboratorio se cerrará automáticamente después de 4 horas pero habrás gastado más saldo del necesario.

![WindowsServerInstallationAWS](img/Windows_Server_in_AWSAcademy/24.png)