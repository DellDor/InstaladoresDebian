#!/bin/bash
#Implementación de lo establecido en:
#http://wiki.flightgear.org/Building_FlightGear_-_Debian
#Mejorado con ideas de:
#https://sourceforge.net/p/flightgear/fgmeta/ci/next/tree/download_and_compile.sh#l21

#Menciona algunas alternativas en dependencias: http://wiki.flightgear.org/Talk:Scripted_Compilation_on_Linux_Debian/Ubuntu

#Se deben desinstalar de repositorio los paquetes a instalar

#HACER: Crear variable booleana para deterinar si es git o no y poner todo en función de ello.
#HACER: crear variable con la versión correspondiente.
#HACER: añadir menú al inicio con yad para los distintos pasos. Se pudiera separar descargadatos en otra terminal independiente. 
#HACER: revisar si las dependencias están instaladas antes de proceder con instalarlas. 
version=$(git ls-remote --heads git://git.code.sf.net/p/flightgear/flightgear|grep '\/release\/'|cut -f4 -d'/'|sort -t . -k 1,1n -k2,2n -k3,3n|tail -1)
#~ version=2016.1
#Subversión (donde aplique):
version2=1
export FG_INSTALL_DIR=/usr/local/games/FG-$version
export FG_SRC_DIR=/var/tmp/FGsrc
mkdir -p $FG_SRC_DIR

lapausa(){
read -p "Pulsa Enter para seguir con " a
}

0eliminaprevio(){
sudo aptitude remove fgo fgrun flightgear flightgear-data-{ai,aircrafts,all,base,models} libplib1
}

1dependencias(){
	#MEJORA: Hacer metapaquete con dependenciasm choques y recomendaciones. En las dependencias debe ir paralelos los que pueden serlo.
#~ sudo apt-get update
#~ sudo rm /var/lib/apt/lists/*

#Herramientas:
paquetes="automake cmake g++ gcc git make sed subversion"
sudo aptitude install $paquetes

#Depenencias:
paquetes="freeglut3-dev libboost-dev libcurl4-openssl-dev  libdbus-1-dev libfltk1.3-dev libgtkglext1-dev libjpeg62-turbo-dev libopenal-dev libopenscenegraph-dev librsvg2-dev libxml2-dev"

#Adicionales:
paquetes="$paquetes libudev-dev qt5-default libqt5opengl5-dev"

sudo aptitude install $paquetes #--visual-preview
 
#~ for i in $(echo $paquetes); do
#~ sudo aptitude install --visual-preview $i
#~ sleep 5
#~ done
}

Ninstaladatos() {
#Datos 2016.1(1.3 Gb):
# axel -an3 
#~ aria2c -c -k1M -x3 -d $FG_SRC_DIR https://sourceforge.net/projects/flightgear/files/release-$version/FlightGear-$version.$version2-data.tar.bz2/download && \
tar vxjf $FG_SRC_DIR/FlightGear-$version.$version2-data.tar.bz2 -C $FG_SRC_DIR && \

sudo mkdir -p $FG_INSTALL_DIR && sudo rsync --remove-source-files -a -v $FG_SRC_DIR/fgdata $FG_INSTALL_DIR
 find $FG_SRC_DIR/fgdata -empty -delete

#Datos (Git)
#~ cd $FG_INSTALL_DIR
#~ git clone git://git.code.sf.net/p/flightgear/fgdata fgdata
}

2instalaplib() {
#plib
cd $FG_SRC_DIR
svn co https://svn.code.sf.net/p/plib/code/trunk plib.svn
cd plib.svn
sed s/PLIB_TINY_VERSION\ \ 5/PLIB_TINY_VERSION\ \ 6/ -i src/util/ul.h
./autogen.sh
./configure --prefix=$FG_INSTALL_DIR
make -j2 && sudo make install
}

3instalasimgear(){
#SimGear
cd $FG_SRC_DIR
git clone git://git.code.sf.net/p/flightgear/simgear simgear.git
#Solo 2016.1
cd simgear.git
git checkout release/$version

#2016 y git
mkdir $FG_SRC_DIR/build-sg; cd $FG_SRC_DIR/build-sg
cmake -D CMAKE_INSTALL_PREFIX:PATH="$FG_INSTALL_DIR" $FG_SRC_DIR/simgear.git
make -j2 && sudo make install
}

4instalafligtgear(){
#Flightgear
cd $FG_SRC_DIR
git clone git://git.code.sf.net/p/flightgear/flightgear flightgear.git

cd flightgear.git
git checkout release/$version

mkdir $FG_SRC_DIR/build-fg; cd $FG_SRC_DIR/build-fg
cmake -D CMAKE_INSTALL_PREFIX:PATH="$FG_INSTALL_DIR" $FG_SRC_DIR/flightgear.git
make -j2 && sudo make install
}

5pruebaflightgear(){
#Prueba final:
export LD_LIBRARY_PATH=$FG_INSTALL_DIR/lib/:$LD_LIBRARY_PATH
$FG_INSTALL_DIR/bin/fgfs --fg-root=$FG_INSTALL_DIR/fgdata

#Si todo bien, se puede cambiar:
read -p "¿Se ejecutó bien? (s/n)" a
if [ "$a" = "s" ]; then
echo "Activando /bin/fgfs"
sudo ln -s $FG_INSTALL_DIR/bin/fgfs /bin/fgfs
fi
}

6instalafgrun(){
#Fgrun
sudo aptitude install fluid
cd $FG_SRC_DIR
git clone git://git.code.sf.net/p/flightgear/fgrun fgrun.git
#2016.1
cd fgrun.git
git checkout release/$version
mkdir $FG_SRC_DIR/build-fgrun; cd $FG_SRC_DIR/build-fgrun
cmake -D CMAKE_INSTALL_PREFIX:PATH="$FG_INSTALL_DIR" $FG_SRC_DIR/fgrun.git
make -j2 && sudo make install
}

7pruebafgrun() {
#Probar Fgrun:
export LD_LIBRARY_PATH=$FG_INSTALL_DIR/lib/:$LD_LIBRARY_PATH
$FG_INSTALL_DIR/bin/fgrun

#HACER: automatizar la ubicación de lo sigueinte en ~/.fltk/flightgear.org/fgrun.prefs

#Binario:
#~ /usr/local/games/FG-2016.2/bin/fgfs

#Inicio (Datos):
#~ /usr/local/games/FG-2016.2/fgdata

#Aviones:
#~/usr/local/games/FG-2016.2/fgdata/Aircraft

#Escenario:
#~ /usr/local/games/FG-2016.2/fgdata/Scenery/

#Cache aeropuertos:
#~ ~/.fltk/flightgear.org/fgrun/airports.txt
}

desinstala(){
sudo rm -vri /bin/fgfs
sudo rm -rv $FG_INSTALL_DIR
rm -rv $HOME/.{fgfs,fltk/flightgear.org,fgo}
}

principal(){
0eliminaprevio
1dependencias
#~ Ninstaladatos
#~ lapausa
2instalaplib
lapausa
3instalasimgear
lapausa
4instalafligtgear
lapausa
5pruebaflightgear
lapausa
6instalafgrun
7pruebafgrun
}

principal
#~ desinstala
