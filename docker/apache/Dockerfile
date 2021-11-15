ARG APACHE_VERSION=""
FROM httpd:${APACHE_VERSION:+${APACHE_VERSION}-}alpine

# copiamos el fichero de configuración de ejemplo para los VirtualHost de apache
COPY ./dominio.conf /usr/local/apache2/conf/

# añadimos el Include al finals del fichero httpd.conf
RUN echo "Include /usr/local/apache2/conf/dominio.conf" \
    >> /usr/local/apache2/conf/httpd.conf

# certbot para los certificados
# bash para el script que ejecutamos al iniciar el contenedor
# screen para lanzar cron 
# tzdaa para poner la hora de nuestro zona horaria
RUN apk add --no-cache certbot bash screen tzdata

# configuramos la zona horaria, por defecto Europe/Madrid
ARG TZDATA=""
RUN cp /usr/share/zoneinfo/${TZDATA:-Europe/Madrid} /etc/localtime

# copiamos, damos permisos de ejecución al script para reiniciar apache. 
# El script mata al proceso httpd padre, por lo que el contenedor terminar.
# Al estar configurada la opción del servicio (en docker-compose.yml)
# de "restart: always", se inicia automáticamente, ejecutando al iniciar 
# el script del CMD 'verificar-letsencrypt', iniciando el proceso de renovación
# en caso de ser necesario
COPY ./reiniciar-apache.sh /usr/local/bin/reiniciar-apache.sh
RUN chmod +x /usr/local/bin/reiniciar-apache.sh

ARG APACHE_CRON_MINUTO=""
ARG APACHE_CRON_HORA=""
ARG APACHE_CRON_DIA_MES=""
ARG APACHE_CRON_MES=""
ARG APACHE_CRON_DIA_SEMANA=""

# si no le damos valores en el build a los argumentos APACHE_CRON_XXX,
# por defecto reiniciará apache todos los días a las 02:00 a.m.
#ARG cmd_cron="${APACHE_CRON_MINUTO:-0} \
#	${APACHE_CRON_HORA:-2} \
#	${APACHE_CRON_DIA_MES:-*} \
#	${APACHE_CRON_MES:-*} \
#	${APACHE_CRON_DIA_SEMANA:-*} \
#	/usr/local/bin/reiniciar-apache.sh\n"

# programamos crontab para que se reinicie
RUN crontab -l > mi-cron \
  && echo -e "Añadiendo al cron:\n\t" \
  && echo -e "${APACHE_CRON_MINUTO:-0}\t${APACHE_CRON_HORA:-2}\t${APACHE_CRON_DIA_MES:-*}\t${APACHE_CRON_MES:-*}\t${APACHE_CRON_DIA_SEMANA:-*}\t/usr/local/bin/reiniciar-apache.sh\n" \
	| tee -a mi-cron \
  && crontab mi-cron \
  && rm mi-cron

# copiamos, damos permisos de ejecución y lanzamos al iniciar el contenedor
# el script que se encarga de solicitar los certificados y renovarlos
COPY ./verificar-letsencrypt.sh /usr/local/bin/verificar-letsencrypt.sh
RUN chmod +x /usr/local/bin/verificar-letsencrypt.sh
CMD /bin/bash /usr/local/bin/verificar-letsencrypt.sh

