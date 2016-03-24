#!/bin/bash
#Instalador de Mint Menu, para escritorio Mate, que ya debe estar instalado. El escritorio actual se puede revisar con:
#~echo $XDG_SESSION_DESKTOP 

#Hacer: añadir el menú vía código al panel

for i in $(curl http://packages.linuxmint.com/list.php?release=Betsy |grep -e mintmenu_ -e mint-translations_ -e mint-common_ | cut -d\" -f2); do 
sudo wget -N -P/var/cache/archives http://packages.linuxmint.com/$i
done

sudo dpkg -i /var/cache/apt/archives/mint{-common,-translations,menu}_*.deb

