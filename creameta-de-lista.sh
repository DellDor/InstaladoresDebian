#!/bin/bash
#Crea metapaquete desde listados de paquetes publicados en la red, como recomendaciones y sugerencias. Pensado para Sparky linux (sourceforge.net) ser llamado desde otro guión con la información de la fuente.
#Builds metapackages with packages listed on web (sourceforge.net) as recommends and suggests. Thinked to use with Sparkylinux and from another script. 

#Variables:
export servidor="http://sourceforge.net/projects/sparkylinux/files"
export sector="lxqt" 
export version="4.3-i686"
export descargar="$servidor/$sector/sparkylinux-$version-$sector.iso.package-list.txt"

#~ Hacer:Corregir los errores que plantea Lintian // Solve issues reported by lintian
#~ E: delldor.sparky.mate-4.2-i586: debian-changelog-file-missing
#~ E: delldor.sparky.mate-4.2-i586: no-copyright-file
#~ W: delldor.sparky.mate-4.2-i586: essential-no-not-needed

#Crea directorio temporal de trabajo // Creates temporal working folder
tempo=$(mktemp -d sparkyXXX)
cd $tempo
#Descarga lista // Download list
wget -c $descargar

#Añade a las depedencias todos los paquetes como recomendaciones, sin versión // Add packages as recommends without its versions.
#Se puede usar como archivo lo que viene de otra máquina ejecutando dpkg -l
archivo="sparkylinux-$version-$sector.iso.package-list.txt"
recomienda=$(cat $archivo|grep ^ii |awk '{print $2}'|awk '{gsub(":i386","");print}'|awk '{printf "%s, ", $0}'| sed 's/,.$//')
echo $recomienda

#Añade a las depedencias todos los paquetes como sugerencias, con versiones // Add packages as suggests with its versions
sugiere=$(cat $archivo|grep ^ii |awk '{print $2" (>="$3")"}'|awk '{gsub(":i386","");print}'|awk '{printf "%s, ", $0}'| sed 's/,.$//')
echo $sugiere

####################################################
fecha=`date +%F|tr '-' '.'`

nombre="delldor.sparky.$sector-$version"

descripcion="Metapapackage from list in web
 Sparky $sector $version.
 Builded $fecha.
 Package list download from
 $servidor
 .
 By Miguel Dell'Uomini
 .
 DellDor"


#Directorio para control y demás // Folder for control, etc
directorio=$tempo/$nombre
mkdir -p $directorio/DEBIAN

echo "Package: $nombre
Essential: no
Section: metapackages
Maintainer: Miguel Dell'Uomini (DellDor) <delldor@gmail.com>
Architecture: all
Priority: optional
Version: $version
Provides: $nombre
Homepage: http://delldor.wordpress.com/
Depends: gdebi (>=0.7)
Recommends: aptitude, $recomienda
Suggests: $sugiere
Description: $descripcion" > $directorio/DEBIAN/control

dpkg -b $directorio && {
read -p "Listo el paquete. Pulse Enter para instalarlo. // Metapackage ready. Press Enter to install." a
sudo gdebi  $tempo/$nombre.deb

#Lo copia a la carpeta desde donde se llamó el guión
#cp -v $directorio0/$nombre.deb `dirname "$1"`

#~ Hacer: Ejecutar solo si no está bloqueado el manejo de paquetes.
read -p "Enter para llamar a aptitude para revisar las recomendaciones // Enter for execute aptitude for check recommends" a
sudo aptitude -S $nombre
}
