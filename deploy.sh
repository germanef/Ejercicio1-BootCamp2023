#!/bin/bash

REPO="Ejercicio1-BootCamp2023"
USERID=$(id -u) #variable para validar el usuario 
config_file="/var/www/html/config.php" # Ruta al archivo config.php conexion a DB


echo "//=========================================//"
echo "//============Inicio del Script============//"
echo "//=========================================//"

if [ "${USERID}" -ne 0 ] ;
then
	echo "ESTE SCRIPT SE DEBE EJECUTAR CON USUARIO ROOT"
	exit
fi

#Actualizando servidor
sudo apt-get update

echo "====Servidor Actualizado===="



###STAGE 1: [Init]###




########Verificando  GIT
if dpkg -l |grep -q git ;
then
        echo "Ya está instalado GIT"
else
        echo "Instalando GIT ..."
        sudo apt install git -y
fi

########Verificando MariaDB Server
if dpkg -l |grep -q mariadb-server ;
then
        echo "Ya está instalado MariaDB Server"
else
        echo "Instalando MariaDB Server ..."
        sudo apt install mariadb-server -y
        sudo systemctl start mariadb-server
        sudo systemctl enable mariadb-server
	sudo systemctl status mariadb-server
fi

#Configurando Base de datos
mysql -e "CREATE DATABASE devopstravel;
CREATE USER 'codeuser'@'localhost' IDENTIFIED BY 'codepass';
GRANT ALL PRIVILEGES ON *.* TO 'codeuser'@'localhost';
FLUSH PRIVILEGES;"

########Verificando Apache2
if dpkg -l |grep -q apache2 ;
then
	echo "Ya está instalado APACHE 2"
else
	echo "Instalando APACHE2 ..."
	sudo apt install apache2 -y
	sudo apt install -y php libapache2-mod-php php-mysql php-mbstring php-zip php-gd php-json php-curl

	#iniciando el servidor web
	sudo systemctl start apache2
	sudo systemctl enable apache2

	#version php
	echo php -v

	#cambiamos el nombre del index para evitar inconvenientes
	mv /var/www/html/index.html /var/www/html/index.html.bkp

fi

#configuracion de apache para soportar archivos .PHP
sed -i 's/index.html/index.php index.html/g' /etc/apache2/mods-enabled/dir.conf
systemctl reload apache2




###STAGE 2: [Build]###




if [ -d "$REPO" ] ;
then
	echo "La carpeta $REPO existe"
	cd $REPO
	git pull origin ejercicio1
else
	sudo git clone https://github.com/germanef/$REPO.git
	cd ${repo}
    	sudo git pull origin ejercicio1 #tengo que hacer el pull desde el branch
	cd ..
fi

########Agregar datos a la database devopstravel 
	mysql < ~/$REPO/database/devopstravel.sql



###STAGE 3: [Deploy]###



echo "Instalando web"
sleep 1
sudo cp -r $REPO/* /var/www/html
sudo systemctl reload apache2


###VALIDAMOS LA EXISTENCIA DEL ARCHIVO DE CONFIG.PHP Y LUEGO CONFIGURAMOS LA CONTRASEÑA
if [ -f "$config_file" ] ;
then
        echo "Existe el archivo config.php"
else
        echo "Error: El archivo 'config.php' no existe en /var/www/html."
        exit 1
fi

# Reemplazar el espacio vacío con "codepass" en config.php
echo "Reemplazando password en config.php..."
sudo sed -i 's/""/"codepass"/g' "$config_file"
sudo systemctl reload apache2
echo "Servicio apache reiniciado..."
sudo cat /var/www/html/config.php


#Validamos la web y la instalación de PHP
curl localhost/info.php
curl localhost
