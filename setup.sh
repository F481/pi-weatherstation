#!/bin/bash

pwd=`pwd`

# install packages
echo "Installing system packages..."
sudo apt-get update
sudo apt-get install php5 sqlite3 php5-sqlite build-essential python-dev python-smbus i2c-tools

# get composer
echo "Installing Composer..."
if command -v "curl" > /dev/null ; then
    curl -sS https://getcomposer.org/installer | php
else
    php -r "readfile('https://getcomposer.org/installer');" | php
fi

echo "run command: php composer.phar install"
php composer.phar install

cd ./vendor/adafruit/bmp/ && sudo python setup.py install
cd $pwd/vendor/adafruit/dht/ && sudo python setup.py install
cd $pwd/ && sqlite3 ./db/pi-weatherstation.db < ./db/schema.sql