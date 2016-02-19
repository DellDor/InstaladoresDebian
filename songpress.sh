#!/bin/bash
#Todo: Identificar si está instalado el paquete

#http://www.skeed.it/songpress

sudo apt-get install python-wxtools
cd /var/tmp
wget -c https://github.com/lallulli/songpress/archive/master.zip
unzip master.zip
sudo mkdir -p /opt/songpress
sudo mv -v /var/tmp/songpress-master/src/* /opt/songpress
cd /opt/songpress
python main.py
