#!/bin/bash
#Añade repositorios y actualiza el sistema, empleando yad como interfaz para las preguntas
#Por ahora debe ejecutarse desde una terminal, pues no crea nuevas.
#La intención es que sólo se emplee esa interfaz
#Poco a poco se deberá ir pasndo todos los comandos alguna forma de ejecución en yad y mostrar la terminal solo cuando corresponda
#Añade los respectivos pins al ir seleccionando los reopositorios.

#HACER: Probar y copiar esquema de prueba de claves presentes de Opera. Paras los tipo paquetes, puede hacerse revisando la versión instalada o como en goo docs sobre pychemp-qt . Proceder solo si es distinta a la requerida.
#HACER: Definir procedimiento que se repite con llamada desde cada uno de los if.
#HACER: Si no está presente, instalar yad desde http://sparkylinux.org/repo/pool/main/y/yad/ según la arquitectura.
#HACER: Añadir, apagado, repositorio unestable de Debian

#Guión de descarga movido a https://github.com/DellDor/aliasbash/.bash_aliases_debian.sh

instalallave() {
#Busca, descarga e la clave del repositorio, según sea el origen
#Primer parámetro: dirección completa de paquete .deb, nombre largo de la clave o dirección completa de archivo de clave
#Segundo parámetro: segunda parte o id completo de clave entre comillas (por el /) resultado de apt-key list (preferiblemente la primera de los pares).

#HACER: cambiar la lógica para que si no hay parámetro 2, se ejecute. Puede ser contando parámetros
directorio=$(dirname $1)
archivo=$(basename $1)
if [[ $(apt-key list|grep "$2")"x" = "x" ]]; then
#Si es un archivo .deb
if [[ ! $(echo $archivo|grep .deb$)"x" = "x" ]]; then
echo "
$1 es un paquete Debian"
archivoremoto=$(curl -L $directorio| tr "\"" "\n"| grep _all.deb$ |tail -n1)
sudo wget -Nc -P /var/cache/apt/archives/ $directorio/$archivoremoto
sudo dpkg -i /var/cache/apt/archives/$archivoremoto
#Si es una clave directa
elif [[ $(echo $directorio)"x" = ".x" ]]; then
echo "
$1 es una clave directa"
key=$1
echo -e "Procesando clave: $key \n"; gpg --keyserver subkeys.pgp.net --keyserver-options timeout=10 --recv $key || gpg --keyserver pgpkeys.mit.edu --keyserver-options timeout=10 --recv $key || gpg --keyserver keyserver.ubuntu.com --keyserver-options timeout=10 --recv $key && gpg --export --armor $key | sudo apt-key add -
else
#Si es un archivo de clave
echo "
$1i es un archivo de clave"
wget -c "$1" -O- | sudo apt-key add -
fi
else
echo "
$1 ya está instalada"
fi
}

desactivarepos(){
#Desactiva todos los repositorios
sudo sed -i 's/deb /#deb /g' /etc/apt/sources.list.d/*.list
for i in $(find /etc/apt/ -iname "*.list" -type f); do
awk '{print "#"$0}' ${i}|sudo tee ${i}
done
}

borralistas(){
sudo rm -v /var/lib/apt/lists/*
}

elegidos=`yad --center --height 600 --width 300 --list --checklist --column=Activar --column "Repositorio" \
FALSE "00- Borrar listados viejos" \
FA
if [[ $elegidos == 0-* ]]; then
desactivarepos
fi

#if [[ $elegidos == *Estable* ]]; then
if echo $elegidos|grep -w "Estable" > /dev/null; then
echo "httpredir.debian.org wiki.debian.org/StableUpdates"
echo "deb http://httpredir.debian.org/debian jessie-proposed-updates main contrib non-free

deb http://httpredir.debian.org/debian stable main contrib non-free
#deb-src http://httpredir.debian.org/debian stable main contrib non-free

deb http://httpredir.debian.org/debian stable-updates main contrib non-free
#deb-src http://httpredir.debian.org/debian stable-updates main contrib non-free

deb http://httpredir.debian.org/debian jessie-backports main contrib non-free

deb http://security.debian.org/ stable/updates main contrib non-free
#deb-src http://security.debian.org/ stable/updates main contrib non-free"|sudo tee /etc/apt/sources.list.d/stable.list

instalallave http://debian.uniminuto.edu/pool/main/d/debian-archive-keyring/?C=M;O=A/paquete.deb 2B90D010

echo "Package: *  
Pin: release a=jessie-backports
Pin-Priority: 700

Package: *  
Pin: release l=Debian-Security
Pin-Priority: 750

Package: *  
Pin: release l=Debian Backports
Pin-Priority: 740

Package: *  
Pin: release a=stable-updates
Pin-Priority: 730

Package: *  
Pin: release a=proposed-updates
Pin-Priority: 650
" | sudo tee /etc/apt/preferences.d/stable-pin
fi

if echo $elegidos|grep -w "Testing" > /dev/null; then
echo "httpredir.debian.org"mu
echo "deb http://httpredir.debian.org/debian testing main contrib non-free
#deb-src http://httpredir.debian.org/debian testing main contrib non-free

deb http://httpredir.debian.org/debian testing-updates main contrib non-free
#deb-src http://httpredir.debian.org/debian testing-updates main contrib non-free

deb http://security.debian.org/ testing/updates main contrib non-free
#deb-src http://security.debian.org/ testing/updates main contrib non-free"|sudo tee /etc/apt/sources.list.d/testing.list

echo "Package: *  
Pin: release a=testing-updates
Pin-Priority: 750

Package: *  
Pin: release a=testing
Pin-Priority: 740
"| sudo tee /etc/apt/preferences.d/testing-pin
fi

if echo $elegidos|grep -w "Sid" > /dev/null; then
echo "httpredir.debian.org https://wiki.debian.org/DebianExperimental"
echo "deb http://httpredir.debian.org/debian sid main contrib non-free
#deb-src http://httpredir.debian.org/debian sid main contrib non-free

#No disponible al momento:
#deb http://httpredir.debian.org/debian sid-updates main contrib non-free
#deb-src http://httpredir.debian.org/debian sid-updates main contrib non-free
#deb http://security.debian.org/ sid/updates main contrib non-free
#deb-src http://security.debian.org/ sid/updates main contrib non-free

deb http://httpredir.debian.org/debian experimental main
"|sudo tee /etc/apt/sources.list.d/sid.list

echo "Package: *
Pin: release o=Debian,a=experimental
Pin-Priority: 1
" | sudo tee /etc/apt/preferences.d/experimental-pin

echo "Package: *
Pin: release a=unstable
Pin-Priority: 150
" | sudo tee /etc/apt/preferences.d/sid-pin
fi

if echo $elegidos|grep -w "Cantv" > /dev/null; then
echo "debian.cantv.net"
echo "####Stable
deb http://debian.cantv.net/debian stable main contrib non-free
deb http://debian.cantv.net/debian stable-updates main contrib non-free
#deb http://debian.cantv.net/debian stable-proposed-updates main contrib non-free
#deb http://debian.cantv.net/debian stable-backports main contrib non-free

####Testing
deb http://debian.cantv.net/debian testing main contrib non-free
deb http://debian.cantv.net/debian testing-updates main contrib non-free
deb http://debian.cantv.net/debian testing-proposed-updates main contrib non-free

####Debian-security
#deb http://debian.cantv.net/debian/debian-security/ stable/updates main contrib non-free
#deb http://debian.cantv.net/debian/debian-security/ testing/updates main contrib non-free"|sudo tee /etc/apt/sources.list.d/cantv.list
fi

if echo $elegidos|grep -w "Cantv2" > /dev/null; then
echo "mirror-01.cantv.net"
echo "####Stable
deb http://mirror-01.cantv.net/debian stable main contrib non-free
deb http://mirror-01.cantv.net/debian stable-updates main contrib non-free
#deb http://mirror-01.cantv.net/debian stable-proposed-updates main contrib non-free
#deb http://mirror-01.cantv.net/debian stable-backports main contrib non-free

####Testing
deb http://mirror-01.cantv.net/debian testing main contrib non-free
deb http://mirror-01.cantv.net/debian testing-updates main contrib non-free
deb http://mirror-01.cantv.net/debian testing-proposed-updates main contrib non-free

####Debian-security
#deb http://mirror-01.cantv.net/debian/debian-security/ stable/updates main contrib non-free
#deb http://mirror-01.cantv.net/debian/debian-security/ testing/updates main contrib non-free
"|sudo tee /etc/apt/sources.list.d/cantv2.list
fi
 
if echo $elegidos|grep -w "Velug" > /dev/null; then
echo "debian.velug.org.ve"
echo "####Stable
deb http://debian.velug.org.ve/debian stable main contrib non-free
deb http://debian.velug.org.ve/debian stable-updates main contrib non-free
#deb http://debian.velug.org.ve/debian stable-proposed-updates main contrib non-free
#deb http://debian.velug.org.ve/debian stable-backports main contrib non-free

####Testing
deb http://debian.velug.org.ve/debian testing main contrib non-free
deb http://debian.velug.org.ve/debian testing-updates main contrib non-free
deb http://debian.velug.org.ve/debian testing-proposed-updates main contrib non-free

####Debian-security
#deb http://debian.velug.org.ve/debian/debian-security/ stable/updates main contrib non-free
#deb http://debian.velug.org.ve/debian/debian-security/ testing/updates main contrib non-free
"|sudo tee /etc/apt/sources.list.d/velug.list
fi

if echo $elegidos|grep -w "Cairo" > /dev/null; then
echo "tuxfamily.org/glxdock"
echo "deb http://download.tuxfamily.org/glxdock/repository/debian testing cairo-dock
"|sudo tee /etc/apt/sources.list.d/cairo-dock.list
fi

if echo $elegidos|grep -w "Lxqt" > /dev/null; then
echo "Siduction"
echo "deb http://packages.siduction.org/lxqt jessie-backports main
#deb-src http://packages.siduction.org/lxqt jessie-backports main

#unstable repository
deb http://packages.siduction.org/lxqt unstable main
#deb-src http://packages.siduction.org/lxqt unstable main

#experimental repository - developers playground, can and will kill kittens and eat pets

deb http://packages.siduction.org/lxqt experimental main
#deb-src http://packages.siduction.org/lxqt experimental main"|sudo tee /etc/apt/sources.list.d/lxqt.list
instalallave 15CBD88045C45076 45C45076
#if ! sudo gpg --list-public-keys | grep 4096R/45C45076 > /dev/null; then
#sudo apt-key adv --keyserver pgpkeys.mit.edu --recv-key 15CBD88045C45076
#fi
echo "Package: *  
Pin: release o=lxqt
Pin-Priority: 1001
" | sudo tee /etc/apt/preferences.d/lxqt-pin
fi

if [[ $elegidos == *Liquorix* ]]; then
echo "deb http://liquorix.net/debian sid main past future"|sudo tee /etc/apt/sources.list.d/liquorix.list

echo "Package: linux-*  
Pin: release o=liquorix
Pin-Priority: 1001
" | sudo tee /etc/apt/preferences.d/liquorix-pin
fi

if [[ $elegidos == *JOSM* ]]; then
echo "deb https://josm.openstreetmap.de/apt alldist universe"|sudo tee /etc/apt/sources.list.d/josm.list
instalallave https://josm.openstreetmap.de/josm-apt.key 78FC0F87
#wget -c https://josm.openstreetmap.de/josm-apt.key -O- | sudo apt-key add -
fi

if [[ $elegidos == *Multimedia* ]]; then
echo "www.deb-multimedia.org"
echo "####Multimedia
deb http://www.deb-multimedia.org stable main non-free
deb http://www.deb-multimedia.org stable-backports main #non-free
deb http://www.deb-multimedia.org testing main non-free
deb http://www.deb-multimedia.org oldstable main non-free
deb http://www.deb-multimedia.org sid main non-free" |sudo tee /etc/apt/sources.list.d/multimedia.list
instalallave http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_246246016.3.7_all.deb 65558117
fi

if [[ $elegidos == *Iceweasel* ]]; then
echo "mozilla.debian.net (Se deja de usar al Debian haber absorbido FF)"
echo "deb http://mozilla.debian.net/ jessie-backports iceweasel-release
#deb http://http.debian.net/debian experimental main"|sudo tee /etc/apt/sources.list.d/mozilla.list
instalallave http://mozilla.debian.net/pkg-mozilla-archive-keyring_1.1_all.deb 
fi

if [[ $elegidos == *LMDE* ]]; then
echo "LMDE Betsy http://community.linuxmint.com/tutorial/view/201"
echo "deb http://packages.linuxmint.com betsy main upstream import #backport
deb http://extra.linuxmint.com betsy main #upstream import backport"|sudo tee /etc/apt/sources.list.d/betsy.list
instalallave http://packages.linuxmint.com/pool/main/l/linuxmint-keyring/linuxmint-keyring_2009.04.29_all.deb
#HACER: buscar llave de LMDE
fi

if [[ $elegidos == *Sparky* ]]; then
echo "sparkylinux.org/repo/
http://forum.siduction.org/index.php?page=download-mirrors-en"
echo "deb http://sparkylinux.org/repo testing main
#deb http://sparkylinux.org/repo unstable main

deb http://www.las.ic.unicamp.br/pub/siduction/extra unstable main contrib non-free
#deb http://mirror.lug.udel.edu/pub/siduction/extra unstable main contrib non-free
#deb-src http://mirror.lug.udel.edu/pub/siduction/extra unstable main
#deb http://mirror.lug.udel.edu/pub/siduction/fixes unstable main contrib non-free
deb http://www.las.ic.unicamp.br/pub/siduction/fixes unstable main contrib non-free
#deb-src http://mirror.lug.udel.edu/pub/siduction/fixes unstable main contrib non-free"|sudo tee /etc/apt/sources.list.d/sparky.list
instalallave http://sparkylinux.org/repo/sparkylinux.gpg.key D117204E
instalallave 15CBD88045C45076 45C45076
#wget -O - http://sparkylinux.org/repo/sparkylinux.gpg.key | sudo apt-key add -
#if ! sudo gpg --list-public-keys | grep 4096R/45C45076 > /dev/null; then
#sudo apt-key adv --keyserver pgpkeys.mit.edu --recv-key 15CBD88045C45076
#fi
echo "Package: *  
Pin: release o=SparkyLinux
Pin-Priority: 1001
" | sudo tee /etc/apt/preferences.d/sparky-pin
fi

if [[ $elegidos == *Virtualbox* ]]; then
echo "Virtualbox"
echo "deb http://download.virtualbox.org/virtualbox/debian jessie contrib non-free"|sudo tee /etc/apt/sources.list.d/virtualbox.list
fi

if [[ $elegidos == *PlayOnLinux* ]]; then
echo "https://www.playonlinux.com/en/download.html"
sudo wget http://deb.playonlinux.com/playonlinux_wheezy.list -O /etc/apt/sources.list.d/playonlinux.list
instalallave http://deb.playonlinux.com/public.gpg C4676186 
fi

if [[ $elegidos == *Google* ]]; then
echo "https://www.google.com/linuxrepositories/"
echo "## Google-chrome web browser
deb http://dl.google.com/linux/chrome/deb/ stable main

## Google Earth
#deb http://dl.google.com/linux/earth/deb/ stable main

## Google talk plugin
#deb http://dl.google.com/linux/talkplugin/deb/ stable main

## Google music manager
#deb http://dl.google.com/linux/musicmanager/deb/ stable main

##Google remote Desktop
deb http://dl.google.com/linux/chrome-remote-desktop/deb/ stable main
"|sudo tee /etc/apt/sources.list.d/google.list
instalallave A040830F7FAC5991 7FAC5991
fi

if [[ $elegidos == *Opera* ]]; then
echo "## Opera web browser
deb http://deb.opera.com/opera/ stable non-free
deb http://deb.opera.com/opera/ testing non-free
deb http://deb.opera.com/opera/ unstable non-free"|sudo tee /etc/apt/sources.list.d/opera.list
instalallave https://deb.opera.com/archive.key A8492E35
#if ! sudo gpg --list-public-keys | grep 4096R/A8492E35 > /dev/null; then
#wget -O- https://deb.opera.com/archive.key | sudo apt-key add -
#fi
fi
################
################
echo 'Acquire::Check-Valid-Until "false";' | sudo tee /etc/apt/apt.conf.d/80update-caduco

if $(yad --center --image "dialog-question" --title "Listado de repositorios" --button=gtk-yes:0 --button=gtk-no:1 --text "¿Desea actualizar listado de repositorios?"); then
sudo apt-get update
fi
if $(yad --center --image "dialog-question" --title "Continuar con actualizaciones" --button=gtk-yes:0 --button=gtk-no:1 --text "¿Desea continuar actualizando paquetes?"); then
echo "Continuamos"
else
exit 0
fi
if $(yad --center --image "dialog-question" --title "Actualizaciones de seguridad" --button=gtk-yes:0 --button=gtk-no:1 --text "¿Desea hacer las actualizaciones de seguridad?"); then
#~ x-terminal-emulator -e  
LANG=C sudo aptitude install --visual-preview $(apt-get upgrade -s | grep -i security| awk '/^Inst/ { print $2 }')
fi
if $(yad --center --image "dialog-question" --title "Actualizaciones seguras" --button=gtk-yes:0 --button=gtk-no:1 --text "¿Desea hacer las actualizaciones seguras, sin borrar nada?"); then
sudo aptitude safe-upgrade --visual-preview
fi
if $(yad --center --image "dialog-question" --title "Actualizaciones sin descargas" --button=gtk-yes:0 --button=gtk-no:1 --text "¿Desea actualizar lo que ya esté en la caché?"); then
sudo bash -c "apt-get upgrade -s |grep 'Inst '| cut -d' ' -f2| grep -v -e ^lib[a-q] -e ^lib[s-z] -e ^libr[a-d] -e ^libr[f-z] -e ^libre[a-n] -e ^libre[p-z]|xargs -l1 apt-get install --no-download --no-remove"
fi
if $(yad --center --image "dialog-question" --title "Actualizaciones una a una" --button=gtk-yes:0 --button=gtk-no:1 --text "¿Desea actualizar uno a uno los paquetes faltantes?"); then
#~ xterm -maximized -e
aptitude search ~U -F %p|xargs -i sudo apt-get install -q "{}"
fi

if $(yad --center --image "dialog-question" --title "Eliminar repetidos" --button=gtk-yes:0 --button=gtk-no:1 --text "¿Desea eliminar paquetes repetidos?"); then
#HACER: Revisar si está instalado fdupes y fslint-gui
sudo fdupes -n -R /var/cache/apt{-cacher-ng,-cacher-ng/_import,}/ |grep -e .deb$|grep archives/|xargs sudo rm -v
sudo fdupes -n -R /var/cache/apt{-cacher-ng,-cacher-ng/_import,}/ |grep -e .deb$|grep _import/|xargs sudo rm -v
sudo fslint-gui /var/cache/{apt,apt-cacher-ng}
fi
