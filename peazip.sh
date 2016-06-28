#!/bin/bash
#~ TODO: si ya está instalado Peazip, ofrecer desinstalarlo primero
#~ Si ya está instalada la dependencia, no buscar descargarla ni instalarla

#La depencia parece no ser necesaria en junio 2016
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

###############################

paquete="peazip"
servidor="https://github.com/giorgiotani/PeaZip/releases/"

tempo=$(mktemp)
#~ Descarga lista de paquetes disponibles en ese servidor

wget -qO- $servidor|sed -n 's/.*href="\([^"]*\).*/\1/p'|grep .deb$ |sort > $tempo
cat $tempo

servidor="https://github.com/"

#~ Para QT
#~ paque=$(grep -E "*.Qt-2_i386.deb" $tempo|tail -n1)

#~ Para GTK
paque=$(grep -E "*.GTK2-2_i386.deb" $tempo|tail -n1)
destino=/var/tmp
echo "

##################### 
A descargar:
$servidor/$paque
en $destino"

wget -P$destino -c $servidor/$paque #&& sudo cp -vu `basename $paque` /var/cache/apt/archives

sudo gdebi-gtk `basename $paque`

read -p "Listo"
