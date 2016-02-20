#!/bin/bash
#Instalador con packagekit de manejador de letras con acordes en formato chrodpro
#http://www.skeed.it/songpress

#if ! dpkg-query -l python-wxtools > /dev/null; then
if ! LANGUAGE=C pkcon search name python-wxtools| grep Installed > /dev/null; then
echo "Instalando paquete requerido"
pkcon install python-wxtools
fi

wget -P/var/tmp -c https://github.com/lallulli/songpress/archive/master.zip
unzip /var/tmp/master.zip
sudo sh -c "mkdir -p /opt/songpress
cp -vur /var/tmp/songpress-master/src/* /opt/songpress
chmod a+x /opt/songpress/main.py"

#Crea acceso en escritorio
#TODO: Generar y crear entrada en menú de aplicaciones
cat <<EOD >$(xdg-user-dir DESKTOP)/songpress.desktop 
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Name=Songpress
Comment=Lyrics with chords editor
Comment[es]=Editor de letras con acordes
Path=/opt/songpress
Exec=python main.py
Type=Application
Terminal=false
Icon=/opt/songpress/img/songpress.png
Categories=Utility;Application;
EOD

chmod a+x $(xdg-user-dir DESKTOP)/songpress.desktop
