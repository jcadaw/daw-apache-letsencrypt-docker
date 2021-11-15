#!/bin/bash

#para arrancar el cron
screen -dmS crond crond -f -l 0

echo "------------------------------------------------------------------------"
echo " Ejecutando $0 para comprobar el certificado letsencrypt y su renovación"
echo "------------------------------------------------------------------------"
clavePrivada="/etc/letsencrypt/live/${LETS_ENCRYPT_DIR}/privkey.pem"

echo "Comprobando si existe el certificado: $clavePrivada."
if [ -f $clavePrivada ]; then
  echo "Existe el certificado: $clavePrivada. Verificando si hay que renovarlo..."
  cmd="certbot renew --no-random-sleep-on-renew --apache --no-self-upgrade"
  echo -e "Solicitando la renovación con el comando:\n\t$cmd"
  eval $cmd
else
  echo "NO existe el certificado: $clavePrivada "

  if [ -z $LETS_ENCRYPT_DOMINIOS ]; then
    echo "LETS_ENCRYPT_DOMINIOS no está definida, no se solicita la solicitud de los certificados..."
  else
    DOMAIN_CMD="$(echo '-d' $LETS_ENCRYPT_DOMINIOS | sed 's/,/ -d /g')"
    cmd="certbot -n certonly --no-self-upgrade --agree-tos --standalone --cert-name $LETS_ENCRYPT_DIR -m \"$LETS_ENCRYPT_EMAIL\" $DOMAIN_CMD"
    echo -e "Solicitando certificados con el comando:\n\t$cmd"
    eval $cmd
  fi
fi


echo "------------------------------------------------------------------------"
echo " Lanzando apache... `date`"
echo "------------------------------------------------------------------------"
httpd-foreground

