---
title: 'Práctica 5 - Dockerización de servidor LDAP'
---

# Práctica 5 - Dockerización de servidor LDAP

Para dockerizar la instalación de OpenLDAP vamos a hacer uso de la imagen oficial de OpenLdap en Docker Hub, que se llama [osixia/openldap](https://hub.docker.com/r/osixia/openldap) 

Si vamos a la página de ayuda, que está en GitHub, y buscamos la zona de "Beninner Guide" encontraremos este ejemplo:

```
docker run \
	--env LDAP_ORGANISATION="My Company" \
	--env LDAP_DOMAIN="my-company.com" \
	--env LDAP_ADMIN_PASSWORD="JonSn0w" \
	--detach osixia/openldap:1.5.0
```

Lanza el contenedor y usa docker exec para comprobar si se ha creado correctamente la base de datos

```
$ docker exec NOMBRECONTENEDOR slapcat
dn: dc=my-company,dc=com
objectClass: top
objectClass: dcObject
objectClass: organization
o: My Company
dc: my-company
structuralObjectClass: organization
entryUUID: 43981890-445c-103f-8edc-4796c2319b7e
creatorsName: cn=admin,dc=my-company,dc=com
createTimestamp: 20241201181726Z
entryCSN: 20241201181726.949230Z#000000#000#000000
modifiersName: cn=admin,dc=my-company,dc=com
modifyTimestamp: 20241201181726Z
```

Vemos, pues, que es muy rápido y sencillo crear un contenedor LDAP. Borra el contenedor creado y crea uno nuevo, con la misma base de datos que creamos en la "Práctica 3 - Configuración de un servidor LDAP"

```
docker run \
    --name ldap-service \
    --env LDAP_ORGANISATION="daw.ieselcaminas" \
	--env LDAP_DOMAIN="daw.ieselcaminas" \
	--env LDAP_ADMIN_PASSWORD="ieselcaminas" \
    --detach osixia/openldap
```

Y prueba si se ha creado la base de datos openldap correctamente

```
$ docker exec ldap-service slapcat
dn: dc=daw,dc=ieselcaminas
objectClass: top
objectClass: dcObject
objectClass: organization
o: daw.ieselcaminas
dc: daw
structuralObjectClass: organization
entryUUID: 26a0e0d8-445b-103f-9969-692c79a37c92
creatorsName: cn=admin,dc=daw,dc=ieselcaminas
createTimestamp: 20241201180928Z
entryCSN: 20241201180928.856139Z#000000#000#000000
modifiersName: cn=admin,dc=daw,dc=ieselcaminas
modifyTimestamp: 20241201180928Z
```

Ahora ya podríamos rellenar la base de datos mediante ficheros ldif como vimos en la práctica anterior. Pero si preferimos usar el interfaz gráfico de phpldapadmin tenemos otro contenedor oficial a nuestra disposición [https://hub.docker.com/r/osixia/phpldapadmin](https://github.com/osixia/docker-phpLDAPadmin).

Para seguir la práctica borra el contenedor ldap-service porque lo volveremos a crear ligeramente modificado.

Como el contenedor que contendrá la base de datos de openldap y el que contendrá phpldapadmin deben interactuar, podríamos hacer uso de la opción `--link` que hemos usado en otras ocasiones y que nos propone la ayuda del contenedor. Pero esa opción ya está obsoleta y es mejor usar redes docker. Es una buena excusa para introducirlas. Una red docker es una red virtual que pueden usar los contenedores para comunicarse entre ellos. Crearemos una red que llamaremos `ldap-netword` y que usarán ambos contenedores. Además, le daremos un `hostname` dentro de la red a cada uno para que puedan referirse uno al otro.

```
docker network create ldap-network

docker run \
	--net ldap-network \
    --hostname ldap-service \
    --name ldap-service \
    --env LDAP_ORGANISATION="daw.ieselcaminas" \
	--env LDAP_DOMAIN="daw.ieselcaminas" \
	--env LDAP_ADMIN_PASSWORD="ieselcaminas" \
    --detach osixia/openldap

docker run \
    --net ldap-network \
    --name phpldapadmin-service \
    --publish 443:443 \
    --hostname phpldapadmin-service \
    --env PHPLDAPADMIN_LDAP_HOSTS=ldap-service \
    --detach osixia/phpldapadmin
```

El primer comando creará la red que usarán ambos. Con `--net` les diremos que usen dicha red. Y con `--hostname` les asignaremos un nombre de red.

Al crear el contenedor de `phpldapadmin-service` usaremos `--env PHPLDAPADMIN_LDAP_HOSTS=ldap-service` para decirle a phpldapadmin cuál es el host que contiene el servidor ldap al que debe acceder.

Si todo va bien podremos acceder a phpldapadmin desde el navegador con `https://IPSERVIDOR`

!!! Tarea  
    Hemos lanzado los 2 servicios usando comandos docker run. ¿Podrías crear ambos contenedores usando docker-compose para levantar todo el servicio en un solo comando?