#!/bin/bash

#Estos archivos van a: /etc/aptitude-robot/pkglist.d

echo "--visual-preview" |sudo tee /etc/aptitude-robot/options.d/15-visible


#Añadido a alias:
apr(){
#Lo siguiente marca para dejar como está todo lo que se vaya a actualizar a versión inestable
temporal=$(mktemp)
for i in $(aptitude search ~U -F %p"$"%V| grep -e +b -e beta -e ~rc -e ~pre|cut -d"$" -f1); do
echo "= $i" | tee -a $temporal
done
sudo cp -v $temporal /etc/aptitude-robot/pkglist.d/zzz_betas_automatico

#Continúa con la pregunta sobre si instalar/actualizar
sudo aptitude-robot
}

#Se puede crear un archivo que empiece por 999_ en /etc/aptitude-robot/pkglist.d/que contenga las instalaciones de pruebas en máquinas particulares como instalaciones y lo que no se quiere que se cambie durante un tiempo, por ejemplo porque se actualiza muy frecuentemente o son paquetes muy grandes y se quieren controlar bien. Para ello se puede generar lista según lo siguiente
#Para buscar por grupos (ejemplo cups):
#centro=cups
#dpkg -l| grep $centro| awk '{print "= "$2}'

#Si se tiene needrestart, se puede activar o desactivar con:
#Desactivar needrestart: sudo needrestart -b 
#Reactivar needrestart: sudo needrestart -ri
