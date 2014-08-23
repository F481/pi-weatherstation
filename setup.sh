#!/bin/bash

pwd=`pwd`
blacklistConfPath="/etc/modprobe.d/raspi-blacklist.conf"
etcModulesPath="/etc/modules"

function pause {
    echo -n "."
    sleep 1
    echo -n "."
    sleep 1
    echo "."
    sleep 1
}

# install packages
echo -n "Install system packages"
pause

sudo apt-get update
sudo apt-get -y install php5 sqlite3 php5-sqlite build-essential python-dev python-smbus i2c-tools

echo -n "Setting up environment"
pause

# enable i2c modules
if [ -f ${etcModulesPath} ]; then
    sudo echo "i2c-bcm2708\ni2c-dev" >> ${etcModulesPath}
fi

# comment out blacklist
if [ -f ${blacklistConfPath} ]; then
    sudo perl -pi -e 's/blacklist spi-bcm2708/#blacklist spi-bcm2708/g' ${blacklistConfPath}
    sudo perl -pi -e 's/blacklist i2c-bcm2708/#blacklist i2c-bcm2708/g' ${blacklistConfPath}
fi

echo -n "Setting up Composer"
pause

# get composer
if command -v "curl" > /dev/null ; then
    curl -sS https://getcomposer.org/installer | php
else
    php -r "readfile('https://getcomposer.org/installer');" | php
fi
php composer.phar install

echo -n "Setting up sensor libraries"
pause

# sensor libraries
cd ./vendor/adafruit/bmp/ && sudo python setup.py install
cd ${pwd}/vendor/adafruit/dht/ && sudo python setup.py install
cd ${pwd}/ && sqlite3 ./db/pi-weatherstation.db < ./db/schema.sql

#reboot
read -p "System needs to be rebooted, reboot now? [y/n]" -n 1 -r REPLY
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo reboot
else
    echo "You have to reboot the system before use pi-weatherstation"
fi