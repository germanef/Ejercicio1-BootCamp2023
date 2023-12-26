#!/bin/bash

REPO="app-295devops-travel"
USERID=$(id -u)

echo "//=========================================//"
echo "//============Inicio del Script============//"
echo "//=========================================//"

if [ "${USERID}" -ne 0 ] ;
then
	echo "ESTE SCRIPT SE DEBE EJECUTAR CON USUARIO ROOT"
	exit
fi

sudo apt-get update

echo "====Servidor Actualizado===="

#Verificando  GIT
if dpkg -l |grep -q git ;
then
        echo "Ya está instalado GIT"
else
        echo "Instalando GIT ..."
        sudo apt install git -y
fi

#Verificando MariaDB Server
if dpkg -l |grep -q mariadb-server ;
then
        echo "Ya está instalado MariaDB Server"
else
        echo "Instalando MariaDB Server ..."
        sudo apt install mariadb-server -y
        sudo systemctl start mariadb-server
        sudo systemctl enable mariadb-server
	sudo systemctl status mariadb-server

	#Configurando Base de datos
	mysql -e "MariaDB > CREATE DATABASE devopstravel;
	CREATE USER 'codeuser'@'localhost' IDENTIFIED BY 'codepass';
	GRANT ALL PRIVILEGES ON *.* TO 'codeuser'@'localhost';
	FLUSH PRIVILEGES;"

	#Agregar datos a la database devopstravel 
	mysql < database/devopstravel.sql

fi

#Verificando Apache2
if dpkg -l |grep -q apache2 ;
then
	echo "Ya está instalado"
else
	echo "Instalando APACHE2 ..."
	sudo apt install apache2 -y
	sudo apt install -y php libapache2-mod-php php-mysql php-mbstring php-zip php-gd php-json php-curl 
	
	#iniciando el servidor web
	sudo systemctl start apache2
	sudo systemctl enable apache2

	#version php
	php -v
	
	#

fi

if [ -d "$REPO" ] ;
then
	echo "La carpeta $REPO existe"
else
	git clone -b app-295devops-travel https://github.com/roxsross/bootcamp-devops-2023/tree/clase2-linux-bash/$REPO
#https://github.com/roxsross/bootcamp-devops-2023.git
fi

echo "Instalando web"

sleep 1

sudo cp -r $REPO/* /var/www/html
