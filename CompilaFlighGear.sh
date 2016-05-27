#!/bin/bash
#Implementación de lo establecido en:
#http://wiki.flightgear.org/Building_FlightGear_-_Debian
#Usa: git aria2

#Más detalles en http://wiki.flightgear.org/Scripted_Compilation_on_Linux_Debian/Ubuntu
#Se puede mejorar revisando:
#https://sourceforge.net/p/flightgear/fgmeta/ci/next/tree/download_and_compile.sh#l21

parametros(){
version=$(git ls-remote --heads git://git.code.sf.net/p/flightgear/flightgear|grep '\/release\/'|cut -f4 -d'/'|sort -t . -k 1,1n -k2,2n -k3,3n|tail -1)
#~ version=2016.1 && version2=2
#Subversión (donde aplique):
version2=1
export FG_INSTALL_DIR=/usr/local/games/flightg
export FG_SRC_DIR=/var/tmp/FGsrc
mkdir -p $FG_SRC_DIR
nucleos=3
}

#Menciona algunas alternativas en dependencias: http://wiki.flightgear.org/Talk:Scripted_Compilation_on_Linux_Debian/Ubuntu

#HACER: Emplear íconos en $FG_SRC_DIR/flightgear.git/icons para accesos directos y elementos del menú
#MEJORA: Crear variable booleana para deterinar si es git o no y poner todo en función de ello.
#MEJORA: añadir menú al inicio con yad para los distintos pasos. Se pudiera separar descargadatos en otra terminal independiente. 
#MEJORA: revisar si las dependencias están instaladas antes de proceder con instalarlas.
#HACER: usar nproc --all para ver la cantidad de nucleos y usar n-1 en la compilación (j)
#MEJORA: revisar http://wiki.flightgear.org/FlightGear_configuration_via_XML que hablan de la configuración predeterminada
#Mejora: Empaquetar en lugar de guión. Revisar https://community.linuxmint.com/tutorial/view/162 básicamente es usar sudo checkinstall en lugar del make install. Seguir https://www.debian.org/doc/manuals/maint-guide/index.es.html revisabdo https://www.debian.org/doc/manuals/maint-guide/build.es.html#git-buildpackage

lapausa(){
read -p "
Pulsa Enter para seguir con $1." a
}

0eliminaprevio(){
#Se deben desinstalar de repositorio los paquetes a instalar
lapausa "eliminar FG de repositorio"
sudo aptitude remove fgo fgrun flightgear flightgear-data-{ai,aircrafts,all,base,models} libplib1
}

1dependencias(){
lapausa "instalar dependencias para compilar"
#MEJORA: Hacer metapaquete con dependenciasm choques y recomendaciones. En las dependencias debe ir paralelos los que pueden serlo.
#~ sudo apt-get update
#~ sudo rm /var/lib/apt/lists/*

#Herramientas:
paquetes="automake cmake g++ gcc git make sed subversion"
sudo aptitude install $paquetes

#Depenencias:
paquetes="freeglut3-dev libboost-dev libcurl4-openssl-dev  libdbus-1-dev libfltk1.3-dev libgtkglext1-dev libjpeg62-turbo-dev libopenal-dev libopenscenegraph-dev librsvg2-dev libxml2-dev"

#Adicionales:
#Para Fgrun
paquetes="$paquetes fluid"

paquetes="$paquetes libudev-dev"

#Para launcher experimental Qt5 (fgfs --launcher en http://wiki.flightgear.org/FlightGear_Qt_launcher)
paquetes="$paquetes qt5-default libqt5opengl5-dev"

sudo aptitude install $paquetes #--visual-preview
 
#~ for i in $(echo $paquetes); do
#~ sudo aptitude install --visual-preview $i
#~ sleep 5
#~ done
}

Ainstaladatos() {
lapausa "descargar datos desde sourceforge ~1,5 Gb"
#Datos 2016.1(1.3 Gb):
# axel -an3 
aria2c -c -k1M -x3 -d $FG_SRC_DIR https://sourceforge.net/projects/flightgear/files/release-$version/FlightGear-$version.$version2-data.tar.bz2/download && echo -e "\n\nInicia descompresión" && \
tar vxjf $FG_SRC_DIR/FlightGear-$version.$version2-data.tar.bz2 -C $FG_SRC_DIR && \
sudo mkdir -p $FG_INSTALL_DIR && echo "\n\nInicia copiado" && sudo rsync --remove-source-files -a -v $FG_SRC_DIR/fgdata $FG_INSTALL_DIR
find $FG_SRC_DIR -empty -delete

#Datos (Git)
#~ cd $FG_INSTALL_DIR
#~ git clone git://git.code.sf.net/p/flightgear/fgdata fgdata
}

2instalaplib() {
lapausa "la compilación e instalación de plib"
#plib
cd $FG_SRC_DIR
svn co https://svn.code.sf.net/p/plib/code/trunk plib.svn
cd plib.svn
sed s/PLIB_TINY_VERSION\ \ 5/PLIB_TINY_VERSION\ \ 6/ -i src/util/ul.h
./autogen.sh
./configure --prefix=$FG_INSTALL_DIR
make -j $nucleos && sudo make install
}

3instalasimgear(){
lapausa "la compilación e instalación de SimGear"
#SimGear
cd $FG_SRC_DIR
git clone git://git.code.sf.net/p/flightgear/simgear simgear.git
#Solo 2016.1
cd simgear.git
git checkout release/$version

#2016 y git
mkdir $FG_SRC_DIR/build-sg; cd $FG_SRC_DIR/build-sg
cmake -D CMAKE_INSTALL_PREFIX:PATH="$FG_INSTALL_DIR" $FG_SRC_DIR/simgear.git
make -j $nucleos && sudo make install
}

4instalafligtgear(){
lapausa "la compilación e instalación de FlightGear"

#Flightgear
cd $FG_SRC_DIR
git clone git://git.code.sf.net/p/flightgear/flightgear flightgear.git

cd flightgear.git
git checkout release/$version

mkdir $FG_SRC_DIR/build-fg; cd $FG_SRC_DIR/build-fg
cmake -D CMAKE_INSTALL_PREFIX:PATH="$FG_INSTALL_DIR" $FG_SRC_DIR/flightgear.git
make -j $nucleos && sudo make install
}

5pruebaflightgear(){
lapausa "la prueba de FG"
#Prueba final:
export LD_LIBRARY_PATH=$FG_INSTALL_DIR/lib/:$LD_LIBRARY_PATH
$FG_INSTALL_DIR/bin/fgfs --fg-root=$FG_INSTALL_DIR/fgdata

#Si todo bien, se puede cambiar:
read -p "¿Se ejecutó bien? (s/n)" a
if [ "$a" = "s" ]; then
echo "Activando /bin/fgfs"
sudo ln -fs $FG_INSTALL_DIR/bin/fgfs /bin/fgfs
fi
}

6instalafgrun(){
lapausa "la compilación e instalación de fgrun"
#Fgrun
cd $FG_SRC_DIR
git clone git://git.code.sf.net/p/flightgear/fgrun fgrun.git
#2016.1
cd fgrun.git
git checkout release/$version
mkdir $FG_SRC_DIR/build-fgrun; cd $FG_SRC_DIR/build-fgrun
cmake -D CMAKE_INSTALL_PREFIX:PATH="$FG_INSTALL_DIR" $FG_SRC_DIR/fgrun.git
make -j $nucleos && sudo make install
}

6reconfigurafgrun() {
zcat $FG_INSTALL_DIR/fgdata/Airports/metar.dat.gz > ~/.fltk/flightgear.org/fgrun/airports.txt

cat << FDA > ${HOME}/.fltk/flightgear.org/fgrun.prefs
; FLTK preferences file format 1.0
; vendor: flightgear.org
; application: fgrun. Modificado por Delldor

[.]

fg_exe_init:
fg_exe:$FG_INSTALL_DIR/bin/fgfs
fg_aircraft_init:
fg_aircraft:${HOME}/.fgfs/Aircraft/Aeronaves:${HOME}/.fgfs/Aircraft/org.
+flightgear.official/Aircraft
fg_root:$FG_INSTALL_DIR/fgdata
fg_scenery:$FG_INSTALL_DIR/fgdata/Scenery
fg_scenery:${HOME}/.fgfs/terraGIT:${FG_INSTALL_DIR}/fgdata/Scenery
show_3d_preview:0
runway:<por defecto>
horizon_effect:1
enhanced_lighting:1
clouds3d:1
specular_highlight:1
random_objects:1
time_of_day_value:noon
time_of_day:1
random_trees:1
ai_models:1
ai_traffic:1
terrasync:1
fetch_real_weather:1
show_cmd_line:1
show_console:1
FDA
#~ http://wiki.flightgear.org/FlightGear_Launch_Control
}

7pruebafgrun() {
lapausa "la prueba de Fgrun"
export LD_LIBRARY_PATH=$FG_INSTALL_DIR/lib/:$LD_LIBRARY_PATH
$FG_INSTALL_DIR/bin/fgrun

#Si todo bien, se puede cambiar:
read -p "¿Se ejecutó bien? (s/n)" a
if [ "$a" = "s" ]; then
echo "Activando /bin/fgrun"
sudo ln -fs $FG_INSTALL_DIR/bin/fgrun /bin/fgrun
fi
}

8finales(){
if [ $(read -p "Pulse s para borrar las carpetas de compilación " a; echo $a) = "s" ]; then
sudo rm -rv $FG_SRC_DIR/build-*
fi
}

desinstala(){
sudo rm -vri /bin/fg{fs,run}
sudo rm -rv $FG_INSTALL_DIR
rm -rv $HOME/.{fgfs,fltk/flightgear.org,fgo}
}

9terragear(){
#http://wiki.flightgear.org/TerraGear
#http://wiki.flightgear.org/Building_TerraGear_in_Ubuntu_910_%2832-_or_64-bit%29#Automatic_Installation

wget -cP $FG_SRC_DIR http://clement.delhamaide.free.fr/download_and_compile_tg.sh
#~ mv -v $FG_SRC_DIR/download_and_compile.sh\?format\=raw $FG_SRC_DIR/download_and_compile.sh
chmod 755 $FG_SRC_DIR/download_and_compile.sh
$FG_SRC_DIR/download_and_compile.sh SIMGEAR TERRAGEAR
}

Baeronaves(){
#Hacer:Descomprimir y ubicar en lugar correcto.
#Mejora: Manejar con un mensaje si sale con error. Ejemplo: 13 ya existe el archivo.
#HACER: un instalador gráfico con yad
aria2c -c -k1M -x3 -d $FG_SRC_DIR --allow-overwrite=false --auto-file-renaming=false https://github.com/FGMEMBERS/JPack/archive/master.zip

if [ $(read -p "¿Quiere instalar el A320Neo? (s para proceder) " a; echo $a) = "s" ]; then
aria2c -c -k1M -x3 -d $FG_SRC_DIR --allow-overwrite=false --auto-file-renaming=false https://codeload.github.com/FGMEMBERS/A320neo/zip/master
fi

if [ $(read -p "¿Quiere instalar la familia CRJ700/900/1000? (s para proceder) " a; echo $a) = "s" ]; then
aria2c -c -k1M -x3 -d $FG_SRC_DIR --allow-overwrite=false --auto-file-renaming=false https://codeload.github.com/FGMEMBERS-NONGPL/CRJ700-family/zip/master
fi
}

CterraGit(){
#Foro oficial http://thejabberwocky.net/viewforum.php?f=51
mkdir -p ~/.fgfs
cd ~/.fgfs
#La clonación crea el directorio terraGIT automáticamente y descarga 400 Mb en objetos base
git config color.ui true
git clone https://github.com/FGMEMBERS-TERRAGIT/terraGIT || cd terraGIT && git pull 
#~ cd terraGIT
}

C1Caribe(){
~/.fgfs/terraGIT/install/tile w070n10
}

principal(){
parametros

0eliminaprevio
1dependencias
Ainstaladatos
2instalaplib
3instalasimgear
4instalafligtgear
5pruebaflightgear
6instalafgrun
6reconfigurafgrun
7pruebafgrun
8finales

Baeronaves

CterraGit
C1Caribe

}

principal
#~ desinstala
