#!/bin/bash
#~ Instalador y desinstalador de Flightgear
desinstala(){
sudo pkcon remove flightgear fgrun
rm -rv $HOME/.{fltk,fgfs}
sudo find /usr -iname "*flightgear*" -type d -exec rm -rvi {} \;
}

instala() {
cosa="pkcon"
cosa="aptitude --visual-preview"

sudo $cosa install flightgear fgrun
sudo chmod a+rw -R $HOME/.fgfs
}

instala
