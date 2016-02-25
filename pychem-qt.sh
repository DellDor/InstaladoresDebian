#!/bin/bash
#Repositorio: https://github.com/jjgomera/pychemqt

#python, version 2.7 required
paquete="python2.7"

#pyqt4, developed with version 4.9
paquete=$(echo $paquete pyqt4{-dev-tools,.qsci-dev})

#Numpy-scipy: python library for mathematical computation
paquete=$(echo $paquete python-{numpy,scipy,sympy})

#matplotlib: python library for graphical representation of data
paquete=$(echo $paquete python-matplotlib)

#python-graph: python library for working with graphs
paquete=$(echo $paquete python-pygraph)

#############################
#Para Coolprop:
paquete=$(echo $paquete python-pip cmake git g++ p7zip libpython-dev)

#Para freesteam
paquete=$(echo $paquete scons gcc gsl-bin python-dev debhelper libgsl0-dev)

echo $paquete

pkcon install $paquete || sudo aptitude install --visual-preview -t testing $paquete
sudo aptitude markauto $paquete
#############################

#CoolProp
sudo pip install CoolProp -U

#ezodf
sudo pip install ezodf -U

#Freesteam
fuente="https://sourceforge.net/projects/freesteam/files/freesteam/2.1"
versiones="_2.1-0~ubuntu1204_i386.deb"
#curl -LO
wget -Nc -P/var/tmp $fuente/{python-freesteam,libfreesteam1,freesteam-ascend,freesteam-gtk}$versiones
#https://sourceforge.net/projects/freesteam/files/freesteam/2.1/python-freesteam_2.1-0~ubuntu1204_i386.deb
#https://sourceforge.net/projects/freesteam/files/freesteam/2.1/libfreesteam1_2.1-0~ubuntu1204_i386.deb
#https://sourceforge.net/projects/freesteam/files/freesteam/2.1/freesteam-ascend_2.1-0~ubuntu1204_i386.deb
#https://sourceforge.net/projects/freesteam/files/freesteam/2.1/freesteam-gtk_2.1-0~ubuntu1204_i386.deb
sudo dpkg -i /var/tmp/{python-freesteam,libfreesteam1,freesteam-ascend,freesteam-gtk}$versiones


#Con dependencias y todo:
paquetes=$(echo python-{pygraph,qscintilla2,pysqlite1.1,matplotlib,numpy,reportlab,scipy} sqlite3 libsqlite3-0 \
libcdt5 libcgraph6 libpathplan4 libxdot4 libgvc6 libgvpr2 graphviz libqscintilla2-l10n python-pydot \
python2.7 scons gcc gsl-bin cmake git g++ p7zip libpython-dev pyqt4{-dev-tools,.qsci-dev} ipython{,-notebook}  bkchem python-{cairo,pip,numpy,matplotlib,reportlab,scipy,qt4,qt4-dev,graphy,sip,pandas,sympy,nose})

sudo aptitude install --visual-preview -t testing $paquetes
sudo aptitude markauto $paquetes

#Para desinstalar:
#sudo aptitude markauto --visual-preview $paquetes

#cd /var/tmp
#curl -OL 
wget -Nc -P/var/tmp https://github.com/jjgomera/pychemqt/archive/master.zip
unzip /var/tmp/master.zip
sudo bash -c 'mkdir -p /opt/pychemqt
sudo cp -vra /var/tmp/pychemqt-master/* /opt/pychemqt
chmod a+x /opt/pychemqt/pychemqt.py'

#TODO:Cambiar
#os.environ["pychemqt"]="/home/jjgomera/pychemqt/"
#por:
#os.environ["pychemqt"]=os.path.abspath('')
#en:
#/pychemqt-master/tools/UI_databank.py
#/pychemqt-master/tools/dependences.py

#Para ejecutar:
python -v /opt/pychemqt/pychemqt.py
