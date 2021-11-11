ARG APACHE_VERSION=""
FROM httpd:${APACHE_VERSION:+${APACHE_VERSION}-}alpine

COPY ./testhttps.jcadaw.tech.conf /usr/local/apache2/conf/

RUN echo "Include /usr/local/apache2/conf/testhttps.jcadaw.tech.conf" \
    >> /usr/local/apache2/conf/httpd.conf

RUN apk update \
    apk upgrade

#RUN apk add netcat-openbsd bc curl wget git bash openssl libressl
RUN apk add certbot certbot-apache bash

RUN rm /var/cache/apk/*

COPY ./verificar-letsencrypt.sh /usr/local/bin/verificar-letsencrypt.sh
RUN chmod +x /usr/local/bin/verificar-letsencrypt.sh

CMD /bin/bash /usr/local/bin/verificar-letsencrypt.sh
