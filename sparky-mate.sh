#!/bin/bash
#~ chmod a+x /var/tmp/sparky-mate.sh
#Inicia la creación de metapaquete de Sparky Mate.

#~cd /tmp
#~wget -c https://raw.githubusercontent.com/DellDor/InstaladoresDebian/master/sparky-mate.sh

#6 junio 2016
#31 enero 2016

cd `mktemp -d`
export servidor="http://sourceforge.net/projects/sparkylinux/files"
export sector="mate" 
export version="4.3-i686"
export descargar="$servidor/$sector/sparkylinux-$version-$sector.iso.package-list.txt"

wget -c https://raw.githubusercontent.com/DellDor/InstaladoresDebian/master/creameta-de-lista.sh
chmod a+x creameta-de-lista.sh

exec ./creameta-de-lista.sh
