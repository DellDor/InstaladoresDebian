#!/bin/bash
#Crear paquete con adicionales en Debian, independiente del escritorio
#TODO: falta completar lo necesario para que no de error lintian 

nombre="dd.adicionales"

sugiere="ttf-liberation, suckless-tools, musescore, devscripts, lshw-gtk, libreoffice-help-es, hypen-es, manpages-es, manpages-es-extra, iceweasel-l10n-es-es, mintmenu, lshw-gtk, peazip|ark, aspell-es,husnpell-es|myspell-es"

rompe="dpkg (<< 0.5~)"
#live-boot live-config

recomienda="aptitude-doc-es, localepurge, unshield, pv, wifite, macchanger, fslint, keepass2, xdotool, meld, gtkorphan, foremost, geany, testdisk, cadaver, youtube-dl, winetricks"

fecha=$(date +%F|tr '-' '.')
descripcion="Metapaquete de adicionales
 Metapaquete de los adicionales que suelo usar, 
 independiente del escritorio.
 Revisión: $fecha.
 .
 Por Miguel Dell'Uomini
 .
 DellDor"

#Versión del metapaquete
version=$fecha

directorio0=`mktemp -d`
directorio=$directorio0/$nombre
mkdir -p $directorio/DEBIAN 

echo "Package: $nombre
Essential: no
Section: metapackages
Maintainer: Miguel Dell'Uomini (DellDor) <delldor@gmail.com>
Architecture: all
Priority: optional
Version: $version
Provides: $nombre
Homepage: http://delldor.blogspot.com/
Depends: dpkg, deborphan
Recommends: $recomienda
Suggests: $sugiere
Breaks: $rompe
Description: $descripcion" > $directorio/DEBIAN/control

#Crea el metapequete en sí
dpkg -b $directorio

#Lo copia a la carpeta desde dónde se llamó el guión
cp -v $directorio0/$nombre.deb `dirname "$1"`
