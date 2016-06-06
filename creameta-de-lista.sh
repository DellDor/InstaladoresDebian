#!/bin/bash
#Crea metapaquete desde listados de paquetes publicados en la red.
#Para ser llamado desde otro guión con la información de la fuente.

#Usa las siguientes variables exportadas de otro guión:
#export servidor="http://sourceforge.net/projects/sparkylinux/files"
#export sector="mate" 
#export version="4.2-i586"
#export descargar="$servidor/$sector/sparkylinux-$version-$sector.iso.package-list.txt"

#~ TODO:Corregir los errores que plantea Lintian
#~ E: delldor.sparky.mate-4.2-i586: debian-changelog-file-missing
#~ E: delldor.sparky.mate-4.2-i586: no-copyright-file
#~ W: delldor.sparky.mate-4.2-i586: essential-no-not-needed


tempo=/var/tmp/sparky
mkdir -p  $tempo

cd $tempo

wget -c $descargar

archivo="sparkylinux-$version-$sector.iso.package-list.txt"

recomienda=$(cat $archivo|grep ^ii |awk '{print $2}'|awk '{gsub(":i386","");print}'|awk '{printf "%s, ", $0}'| sed 's/,.$//')
echo $recomienda

sugiere=$(cat $archivo|grep ^ii |awk '{print $2" (>="$3")"}'|awk '{gsub(":i386","");print}'|awk '{printf "%s, ", $0}'| sed 's/,.$//')
echo $sugiere

####################################################
fecha=`date +%F|tr '-' '.'`

nombre="delldor.sparky.$sector-$version"

descripcion="Metapaquete de paquetes desde red
 Sparky $sector $version.
 Armado el $fecha.
 Lista de paquetes descargado desde
 $servidor
 .
 Por Miguel Dell'Uomini
 .
 DellDor"

#Versión del metapaquete
#~ version=$fecha

#directorio0=`mktemp -d`
#~ directorio0=/var/tmp/sparky

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
Recommends: $recomienda
Suggests: $sugiere
Description: $descripcion" > $directorio/DEBIAN/control

dpkg -b $directorio && {
read -p "Listo el paquete. Pulse Enter para instalar instalará" a
sudo gdebi  $tempo/$nombre.deb

#Lo copia a la carpeta desde donde se llamó el guión
#cp -v $directorio0/$nombre.deb `dirname "$1"`

#~ TODO: Ejecutar solo si no está bloqueado el manejo de paquetes.
read -p "Enter para llamar aptitude para revisar las recomendaciones" a
sudo aptitude -S $nombre
}
