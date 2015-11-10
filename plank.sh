#!/bin/bash
#http://nksistemas.com/usar-la-barra-plank-en-debian-8/

#TODO: Añad8ir clave del repo

echo "deb http://ppa.launchpad.net/ricotz/docky/ubuntu precise main"|sudo tee /etc/apt/sources.list.d/plank.list

sudo apt-get update

sudo aptitude install plank --visual-preview
