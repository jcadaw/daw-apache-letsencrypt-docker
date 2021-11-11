#!/bin/bash

echo "------------------------------------------------------------------------"
echo " Ejecutando $0 para comprobar el certificado letsencrypt y su renovación"
echo "------------------------------------------------------------------------"
privateKeyHome="/etc/letsencrypt/live/${LETS_ENCRYPT_DIRECTORIO}"
privateKeyFile="$privateKeyHome/privkey.pem"

echo "Comprobando si existe el certificado: $privateKeyFile."
if [ -f $privateKeyFile ]; then
  echo "Existe el certificado: $privateKeyFile. Verificando si hay que renovarlo..."
  cmd="certbot renew --no-random-sleep-on-renew --apache --no-self-upgrade"
  echo -e "Solicitando la renovación con el comando:\n\t$cmd"
  eval $cmd
else
  echo "NO existe el certificado: $privateKeyFile "

  if [ -z $LETS_ENCRYPT_DOMINIOS ]; then
    echo "LETS_ENCRYPT_DOMINIOS no está definida, no se solicita la solicitud de los certificados..."
  else
    DOMAIN_CMD="$(echo '-d' $LETS_ENCRYPT_DOMINIOS | sed 's/,/ -d /g')"
    cmd="certbot -n certonly --no-self-upgrade --agree-tos --standalone --cert-name $LETS_ENCRYPT_DIRECTORIO -m \"$LETS_ENCRYPT_EMAIL\" $DOMAIN_CMD"
    echo -e "Solicitando certificados con el comando:\n\t$cmd"
    eval $cmd
  fi
fi


echo "Lanzando apache2"
httpd-foreground

