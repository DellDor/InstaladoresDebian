#!/bin/bash

#Actualizador y completador de Libreoffice en Debian. Pensado en LMDE, Sparky ocualquier otra dónde venga preinstalado.

#Actualización en Jessie
echo "Si no se añadió el Estable del guión repositorios Debian, se debe tener el repositorio Backports
deb http://httpredir.debian.org/debian jessie-backports main contrib non-free
y actualizar
sudo apt-get update"


#Actualizando a versión específica todo lo instalado que comience con libreoffice,ure y python3-uno, con alternativas
#Se puede verificar con: apt-cache policy libreoffice-writer
version=jessie-backports
#version=testing
#version=sid
dpkg -l |awk '/^ii  libreoffice/ || /^ii  ure/ || /^ii  python3-uno/ {print $2}'|xargs sudo apt-get install -y -t $version

#Adicionales:
sudo aptitude install --visual-preview -t $version libreoffice-{l10n,help}-es libreoffice-{pdfimport,nlpsolver,script-provider-python} {hyphen,myspell}-es

#Manual, por si hay problemas de versión
#Para Mate, lo que incluye Gtk, Gnome. Si es para lxqt, revisar si incluir KDE.
v1="5.1.1-1"
v2="1:$v1"

sudo apt-get install libreoffice-{writer,java-common,base,l10n-es,calc,base-drivers,base-core,gnome,gtk,draw,impress,math,common,help-es,core}=$v2 python3-uno=$v2 ure=$v1 myspell-es

#Marcamos como automáticos:
#sudo apt-mark auto \
#--visual-preview \
sudo aptitude markauto \ 
libreoffice-{help-es,base,base-drivers,base-core,common,calc,core,draw,impress,java-common,math,writer,gtk,style-galaxy,style-tango,style-mint,sdbc-hsqldb,report-builder-bin} ure python3-uno
