#!/bin/bash

pwd=`pwd`
blacklistPath="/etc/modprobe.d/raspi-blacklist.conf"

# install packages
echo "Installing system packages..."
sudo apt-get update
sudo apt-get install php5 sqlite3 php5-sqlite build-essential python-dev python-smbus i2c-tools

# get composer
echo "Setting up Composer..."
if command -v "curl" > /dev/null ; then
    curl -sS https://getcomposer.org/installer | php
else
    php -r "readfile('https://getcomposer.org/installer');" | php
fi

php composer.phar install

echo "Setting up sensor libraries"
cd ./vendor/adafruit/bmp/ && sudo python setup.py install
cd $pwd/vendor/adafruit/dht/ && sudo python setup.py install
cd $pwd/ && sqlite3 ./db/pi-weatherstation.db < ./db/schema.sql

if [ -f $blacklistPath ]; then
    read -r -p "Are you sure? [y/N] " response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        do_something
    else
        do_something_else
    fi
    read -r -p "To make the sensors working, you have to comment out the two following lines: '#blacklist spi-bcm2708' and '#blacklist spi-bcm2708' [Press ENTER]"
    sudo nano $blacklistPath
fi