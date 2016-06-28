#!/bin/bash
#Descarga e instala la última versión de Peazip para GTK en i386.
#Requiere wget, gdebi-gtk

#~ HACER: si ya está instalado Peazip, ofrecer desinstalarlo primero

#La depencia parece no ser necesaria en junio 2016, por lo que se desactiva
dependencia(){
cd /tmp
paquete="peazip"
servidor="https://packages.debian.org/squeeze/i386/libgmp3c2/download"

tempo=$(mktemp)
wget -qO- $servidor|sed -n 's/.*href="\([^"]*\).*/\1/p'|grep .deb$ |sort -r > $tempo
paque=$(cat $tempo| head -n1)
wget -c $paque && sudo cp -vu `basename $paque` /var/cache/apt/archives

sudo gdebi-gtk `basename $paque`
}

#~dependencia
###############################

servidor="https://github.com/giorgiotani/PeaZip/releases/"

#Para QT
#~modo=Qt

#Para GTK
modo=GTK2

if [ $(uname -m) == 'i686' ]; then
plataforma=i386
else
plataforma=all
fi

paque=$(wget -qO- $servidor|sed -n 's/.*href="\([^"]*\).*/\1/p'|grep -E "*.$modo-2_$plataforma.deb"|sort|tail -n1)

destino=/var/tmp

echo "

##################### 
A descargar:
https://github.com/$paque
en $destino"

wget -P$destino -c https://github.com/$paque
#~&& sudo cp -vu `basename $paque` /var/cache/apt/archives

sudo gdebi-gtk $destino/`basename $paque`

read -p "Listo"
