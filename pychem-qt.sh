#!/bin/bash
#Instalador manual de pychem-qt para Debian. Por DellDor en correo de google punto com
#Depende de aptitude, dpkg, wget, chmod, unzip, sed

#wget -P/tmp https://raw.githubusercontent.com/DellDor/InstaladoresDebian/master/pychem-qt.sh && chmod a+x /tmp/pychem-qt.sh && bash /tmp/pychem-qt.sh

#Repositorio del programa: https://github.com/jjgomera/pychemqt

#HACER: Generar entrada correcta en el menú de programas. Se puede estudiar lo del paquete freesteam-gtk
#HACER: El objetivo a largo plazo es generar un paquete de manera correcta. 

###############GENERALES
#Directorio dónde se descargarán los archivos. En /var/tmp no se borran los archivos al apagar la PC,en /tmp sí.
export temporal=/var/tmp
#export temporal=/tmp

#Si no se quiere especificar versión del repositorio de dónde se descargarán los paquetes, por ejemplo para estable, descomentar la segunda línea.
repositorio="-t testing"
#unset repositorio
###############DEPENDENCIAS:

#python, version 2.7 required
paquete="python2.7 p7zip"

#pyqt4, developed with version 4.9
paquete=$(echo $paquete pyqt4{-dev-tools,.qsci-dev,qscintilla2})

#Numpy-scipy: python library for mathematical computation
paquete=$(echo $paquete python-{numpy,scipy,sympy})

#matplotlib: python library for graphical representation of data
paquete=$(echo $paquete python-matplotlib)

#python-graph: python library for working with graphs
paquete=$(echo $paquete python-pygraph)

###############DEPENDENCIAS PARA ADICIONALES:
#Para Coolprop y ezodf:
paquete=$(echo $paquete python-pip build-essential libpython-dev)
#git cmake g++

#Para freesteam
paquete=$(echo $paquete libgsl0ldbl) #libgsl0-dev sustituido por libgsl-dev para no romper otras dependencias . scons gcc gsl-bin debhelper libgsl-dev

#Para Oasa https://packages.debian.org/stretch/all/bkchem/filelist:
export paquete=$(echo $paquete bkchem)

#pkcon install $paquete ||
sudo -E bash -c 'aptitude install --visual-preview $repositorio $paquete
echo "################# #################### #################




Responda que no a la siguiente pregunta. Sirve para marcar como automático lo que corresponda
################# #################### #################"
aptitude markauto -P $paquete'

###############CON TODAS LAS DEPENDENCIAS Y PAQUETES AUXILIARES. Se puede empezar directamente por aquí
#Con dependencias y todo:
#paquetes=$(echo python-{pygraph,qscintilla2,pysqlite1.1,matplotlib,numpy,reportlab,scipy} sqlite3 libsqlite3-0 libcdt5 libcgraph6 libpathplan4 libxdot4 libgvc6 libgvpr2 graphviz libqscintilla2-l10n python-pydot python2.7 p7zip libpython-dev pyqt4{-dev-tools,.qsci-dev} ipython{,-notebook} bkchem python-{cairo,pip,numpy,matplotlib,reportlab,scipy,qt4,qt4-dev,graphy,sip,pandas,sympy,nose} libgsl0ldbl build-essential)
#scons gcc gsl-bin cmake git g++

#sudo aptitude install --visual-preview $repositorio $paquetes
#echo "################# #################### #################




#Responda que no a la siguiente pregunta. Sirve para marcar como automático lo que corresponda
################# #################### #################"
#sudo aptitude markauto -P $paquetes

###############ADICIONALES VÍA PIP

#CoolProp (propiedades termodinámicas:3.6Mb) y ezodf (ofimática ods:125 kb) 
sudo pip install CoolProp ezodf -U

###############OTROS ADICIONALES
#HACER:pyelemental (tabla periódica)

#OASA  used to show compound extended formula in database

#wget -cN -P$temporal http://bkchem.zirael.org/download/oasa-0.13.1.tar.gz
#tar -zxvf $temporal/oasa-0.13.1.tar.gz
#sudo python $temporal/oasa-0.13.1/setup.py install

#Luego de instalado bkchem, no hace falta lo precedente, que descargaba manualmente
sudo python /usr/lib/bkchem/bkchem/oasa/setup.py install


#Freesteam:  package for calculating thermodynamic properties of water by IAPWS-IF97
#El -gtk no es requerido, pero ya que se instalarán los demás...
#https://sourceforge.net/projects/freesteam/files/freesteam/2.1/libfreesteam1_2.1-0~ubuntu1204_i386.deb
#https://sourceforge.net/projects/freesteam/files/freesteam/2.1/python-freesteam_2.1-0~ubuntu1204_i386.deb
#https://sourceforge.net/projects/freesteam/files/freesteam/2.1/freesteam-gtk_2.1-0~ubuntu1204_i386.deb
#sudo aptitude install --visual-preview libgsl0ldbl #ATENCIÓN, libgsl0ldbl rompe libgsl2, dependencia de Inkscape y otros 

fuente="https://sourceforge.net/projects/freesteam/files/freesteam/2.1"
versiones="_2.1-0~ubuntu1204_i386.deb"
wget -Nc -P$temporal $fuente/{libfreesteam1,python-freesteam,freesteam-gtk}$versiones 
sudo dpkg -i $temporal/{libfreesteam1,python-freesteam,freesteam-gtk}$versiones

###############PROGRAMA EN SÍ
#Descarga y descomprime
wget -Nc -P$temporal https://github.com/jjgomera/pychemqt/archive/master.zip
unzip $temporal/master.zip -d $temporal

#Se cambia la dirección del home del autor por una automática para que muestren las imágenes
cambiame="\"\/home\/jjgomera\/pychemqt\/\""
poreste="os.path.abspath(\'\')"
sed -i -e 's/'"$cambiame"'/'"$poreste"'/g' $temporal/pychemqt-master/tools/UI_databank.py
sed -i -e 's/'"$cambiame"'/'"$poreste"'/g' $temporal/pychemqt-master/tools/dependences.py

sudo -E bash -c 'mkdir -p /opt/pychemqt
cp -vra $temporal/pychemqt-master/* /opt/pychemqt
chmod a+x /opt/pychemqt/pychemqt.py'

#Se creaq un .desktop en el escritorio para ejcutarlo.

cat <<FDA >$(xdg-user-dir DESKTOP)/pychemqt.desktop 
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Name=Pychem-Qt
Comment=Simulador de procesos Químicos
Path=/opt/pychemqt
Exec=python -v pychemqt.py
Type=Application
Terminal=false
Icon=/opt/pychemqt/images/pychemqt.png
Categories=Utility;Application;
FDA
chmod a+x $(xdg-user-dir DESKTOP)/pychemqt.desktop

#Para deshacer todo lo anterior, ejecutar aparte
desinstalar(){
sudo pip uninstall CoolProp ezodf

paquetes=$(echo python-{pygraph,qscintilla2,pysqlite1.1,matplotlib,numpy,reportlab,scipy} sqlite3 libsqlite3-0 \
libcdt5 libcgraph6 libpathplan4 libxdot4 libgvc6 libgvpr2 graphviz libqscintilla2-l10n python-pydot \
python2.7 scons gcc gsl-bin cmake git g++ p7zip libpython-dev pyqt4{-dev-tools,.qsci-dev} ipython{,-notebook} bkchem python-{cairo,pip,numpy,matplotlib,reportlab,scipy,qt4,qt4-dev,graphy,sip,pandas,sympy,nose} build-essential)
sudo aptitude markauto --visual-preview $paquetes

temporal=/var/tmp
rm -v $(xdg-user-dir DESKTOP)/pychemqt.desktop $temporal/master.zip $temporal/*freesteam*.deb $temporal/pychemqt-master/
sudo rm -rv /opt/pychemqt
}
