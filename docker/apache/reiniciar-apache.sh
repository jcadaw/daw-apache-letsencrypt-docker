#ª/bin/bash

echo "------------------------------------------------------------------------"
echo " Ejecutando $0 para reiniciar apache (paramos contenedor de docker)"
echo "------------------------------------------------------------------------"
kill $(ps -a | grep httpd | head -n1 | grep -o -e '[0-9]\+' | head -n1)

