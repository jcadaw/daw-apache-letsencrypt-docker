# daw-apache-letsencrypt-docker
Creación de un esqueleto para una aplicación web usando `Apache` y **certificados SSL** de **Let's Encrypt**, usando la imagen oficiales de apache `alpine`.
<div id="top"></div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Índice</summary>
  <ol>
    <li>
      <a href="#sobre-el-repo">Sobre el repo</a>
    </li>
    <li>
      <a href="#estructura-de-archivos">Estructura de archivos</a>
      <ul>
        <li><a href="#directorio-app">Directorio "./app"</a></li>
        <li><a href="#directorio-docker">Directorio "./docker"</a></li>
        <ul>
          <li><a href="#fichero-docker-composeyml">fichero docker-compose.yml</a></li>
          <li><a href="#fichero-env">fichero .env</a></li>
          <li><a href="#directorio-apache">directorio apache</a></li>
        </ul>
      </ul>
      <li><a href="#imágenes-de-docker-usadas">Imágenes de docker usadas</a></li>
      <li><a href="#empezando">Empezando</a></li>
      <ul>
        <li><a href="#prerrequisitos">Prerrequisitos</a></li>
        <li><a href="#instalación">Instalación</a></li>
        <li><a href="#uso">Uso</a></li>
      </ul>
      <li><a href="#contacto">Contacto</a></li>
    </li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## Sobre el repo

El objetivo de este repositorio es servir de ejemplo o punto de partida para una aplicación web con servidor `Apache` y **certificados SSL** con **Let's Encrypt** sobre `docker`. 

Se utiliza `certbot` para la solicitud de certificados en su forma `standalone`, se utiliza una tarea cron para reiniciar el contenedor y así poder renovar los certificados cuando sea necesario.


`Docker compose` creará 1 contenedor: 
* 1 contenedor con apache 2.4 y `certbot` (distribución alpine)

<p align="right">(<a href="#top">volver arriba</a>)</p>

## Estructura de archivos

La estructura de los directorios/archivos es la siguiente: 

```
.
├── app
│   └── index.html
├── docker
│   ├── apache
│   │   ├── Dockerfile
│   │   ├── dominio.conf
│   │   ├── reiniciar-apache.sh
│   │   └── verificar-letsencrypt.sh
│   ├── .env.default
│   └── docker-compose.yml
├── .gitignore
└── README.md

```
<p align="right">(<a href="#top">volver arriba</a>)</p>

### Directorio app

En `app` es donde crearemos nuestra aplicación web (obviamente es configurable).
Dentro existe un par de ejemplos: 
* `index.html` un ejemplo de web sencilla en html, para verificar que funciona


<p align="right">(<a href="#top">volver arriba</a>)</p>

### Directorio docker

En `docker` es donde está toda la configuración de docker para la creación de los contenedores. 

Desde este directorio ejecutaremos el siguiente comando para levantar los contenedores:

```docker
docker-compose up -d
```


#### fichero docker-compose.yml

En este fichero tenemos la configuración de docker compose, información sobre los servicios, volúmenes y redes que se van a configurar. 

En este repositorio se va a configurar un contenedor para `apache` usando la distribución `alpine`. 

Para determinar las versiones de las imágenes en las que nos vamos a basar, usamos el fichero de configuración `.env`

Creamos una redes: 
  - daw-red-www-ssl: en esta red están el contenedor de `apache` y `php`

Creamos dos volúmenes para la almacenar la configuración de Let's Encrypt : 
 - `daw-etcletsencrypt`
 - `daw-varletsencrypt`

<p align="right">(<a href="#top">volver arriba</a>)</p>

#### fichero .env

Fichero en el que configurar algunos parámetros para la creación de los contenedores. Actualmente las variables permitidas son: 

```
APACHE_VERSION=2.4.51
#Minutos (0-59), */15 cada quince minutos...
APACHE_CRON_MINUTO=0
#Hora (0-23)
APACHE_CRON_HORA=2
#Día de mes (1-31)
APACHE_CRON_DIA_MES=*
#Mes (1-12)
APACHE_CRON_MES=*
#Día de la semana (0-7) (Domingo=0 o 7)
APACHE_CRON_DIA_SEMANA=*


#ServerName global
APACHE_GLOBAL_ServerName=testhttps.example.com
#VirtualHost ServerName para puertos 80 y 443
APACHE_VH_ServerName=testhttps.example.com
#VirtualHost ServerAlias para puertos 80 y 443
APACHE_VH_ServerAlias=testhttps2.example.com


PROYECTO_RUTA=../app

LETS_ENCRYPT_EMAIL=usuario@email.com
LETS_ENCRYPT_DOMINIOS=testhttps.example.com,testhttps2.example.com
LETS_ENCRYPT_DIR=testhttps.example.com

TZDATA=Europe/Madrid
```

##### Variables de contrucción de la imagen (build.args)

Estas son variables que pueden ser utilizadas en la sección **build.args**: 

`APACHE_VERSION` número del tag de la imagen oficial de apache alpine que se quiere utilizar. Nota: "-alpine" se concatena automáticamente.

`APACHE_CRON_XXX`  hace referencia a la configuración cron que se va a utilizar:
`APACHE_CRON_MINUTO` minuto (0-59), */15 cada quince minutos...
`APACHE_CRON_HORA` hora (0-23)
`APACHE_CRON_DIA_MES` día de mes (1-31)
`APACHE_CRON_MES` mes (1-12)
`APACHE_CRON_DIA_SEMANA` día de la semana (0-7) (Domingo=0 o 7)
`TZDATA` zona horaria en la que se configura el contenedor

##### Variables de entorno (environment)

Estas son variables que pueden ser definidas en la sección **environment**:

`APACHE_GLOBAL_ServerName` ServerName a utilizar globalmente (fuera de los VirtualHosts)
`APACHE_VH_ServerName` ServerName utilizado para los 2 VirtualHosts que se crean por defecto (1 para el puerto 80 y otro para el 443)
`APACHE_VH_ServerAlias` ServerAlias utilizado para los 2 VirtualHosts que se crean por defecto (1 para el puerto 80 y otro para el 443). Por defecto, sólo para un alias...

`PROYECTO_RUTA` es el directorio donde está nuestra aplicación web, será nuestro *DocumentRoot* dentro del *VirtualHost* que crearemos en el contenedor de apache

`LETS_ENCRYPT_EMAIL` es el correo con al que se mandarán las notificaciones importantes de Let's Encrypt
`LETS_ENCRYPT_DOMINIOS` listado de dominios (separados por comas) para los que se quiere obtener el certificado
`LETS_ENCRYPT_DIR` subdirectorio en el que se almacenarán los certificados: /etc/letsencrypt/live/**${LETS_ENCRYPT_DIR}**/*


<p align="right">(<a href="#top">volver arriba</a>)</p>

#### directorio apache

Contiene el **Dockerfile** para construir la imagen, basicamente copiamos el fichero de ejemplo de **VirtualHost** (dominio.conf) e incluimos dicho fichero en el **httpd.conf** para que arranque automáticamente esa configuración y además lanzamos como CMD el script ***verificar-letsencrypt.sh***, mediante el cual solicitamos o renovamos el certificado para los dominios listados en **LETS_ENCRYPT_DOMINIOS**.

El script ***reiniciar-apache.sh*** lo utilizamos para matar el proceso httpd padre del contenedor, de manera que termina su ejecución, al tener configurado el servicio *apache* en el *docker-compose.yml* como **restart: always**, el contenedor se levanta automáticamente, iniciando el proceso de solicitud de certificado o renovación. 

El script anterior, se ejecuta automáticamente mediante una tarea cron que se puede configurar con las variables build de la imagen **APACHE_CRON_**XXX

El fichero ***dominio.conf*** contiene una configuración de ejemplo en el que se redireccionan todas las peticiones **http** a **https**



## Imágenes de docker usadas

Nos hemos basado en la imagen oficial de `apache`. Usamos además las distribuciones *alpine*.

* [apache](https://hub.docker.com/_/httpd)

<p align="right">(<a href="#top">volver arriba</a>)</p>



<!-- GETTING STARTED -->
## Empezando

Si quieres crear un proyecto con *apache* y certificados *ssl* usando contenedores *docker*, sigue las siguientes instrucciones:

### Prerrequisitos

Tienes que tener *docker* y *docker-compose* instalado en tu máquina

### Instalación

1. Clona el repo
   ```sh
   git clone https://github.com/jcadaw/daw-apache-letsencrypt-docker.git 
   ```
2. Ve al directorio *./docker*
   ```sh
   cd docker
   ```
3. Lanza *docker-compose*
   ```sh
   docker-compose up -d
   ```

<p align="right">(<a href="#top">volver arriba</a>)</p>



<!-- USAGE EXAMPLES -->
### Uso

A partir de aquí, siénte libre para crear tu aplicación web.
<p align="right">(<a href="#top">volver arriba</a>)</p>


## Contacto

José Carlos Álvarez - jca at alzago punto es

Repo: [https://github.com/jcadaw/daw-apache-letsencrypt-docker.git](https://github.com/jcadaw/daw-apache-letsencrypt-docker.git)

<p align="right">(<a href="#top">back to top</a>)</p>
