#!/bin/bash
#Repositorio: https://github.com/jjgomera/pychemqt

#python, version 2.7 required
paquete="python2.7"

#pyqt4, developed with version 4.9
paquete=$(echo $paquete pyqt4{-dev-tools,.qsci-dev})

#Numpy-scipy: python library for mathematical computation
paquete=$(echo $paquete python-{numpy,scipy})

#matplotlib: python library for graphical representation of data
paquete=$(echo $paquete python-matplotlib)

#python-graph: python library for working with graphs
paquete=$(echo $paquete python-pygraph)

#############################
#Para Coolprop:
paquete=$(echo $paquete python-pip cmake git g++ p7zip libpython-dev)

echo $paquete

sudo aptitude install --visual-preview $paquete
#############################

#CoolProp
sudo pip install CoolProp -U

#ezodf
sudo pip install ezodf -U


#Con dependencias y todo:
paquetes=$(echo python-{pygraph,qscintilla2,pysqlite1.1,matplotlib,numpy,reportlab,scipy} sqlite3 libsqlite3-0 \
libcdt5 libcgraph6 libpathplan4 libxdot4 libgvc6 libgvpr2 graphviz libqscintilla2-l10n python-pydot \
python2.7 scons gcc gsl-bin cmake git g++ p7zip libpython-dev pyqt4{-dev-tools,.qsci-dev} ipython{,-notebook}  bkchem python-{cairo,pip,numpy,matplotlib,reportlab,scipy,qt4,qt4-dev,graphy,sip,pandas,sympy,nose})

sudo aptitude install --visual-preview $paquetes

#Para desinstalar:
#sudo aptitude markauto --visual-preview $paquetes


curl -OL https://github.com/jjgomera/pychemqt/archive/master.zip
unzip master.zip
cd pychemqt-master
python pychemqt.py
