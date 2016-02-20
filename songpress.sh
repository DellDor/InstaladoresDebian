#!/bin/bash
# Manejador de letras con acordes en formato chrodpro
#http://www.skeed.it/songpress

#ToDo: Identificar si está instalado el paquete

if ! dpkg-query -l python-wxtools > /dev/null; then
echo "Instalando paquete requerido"
sudo apt-get install python-wxtools
fi

wget -P/var/tmp -c https://github.com/lallulli/songpress/archive/master.zip
unzip /var/tmp/master.zip
sudo mkdir -p /opt/songpress
sudo mv -v /var/tmp/songpress-master/src/* /opt/songpress
cd /opt/songpress
python main.py
