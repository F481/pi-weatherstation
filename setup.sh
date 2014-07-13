#!/bin/bash

pwd=`pwd`

# install packages
sudo apt-get update
sudo apt-get install php5 sqlite3 php5-sqlite build-essential python-dev python-smbus i2c-tools

# get composer
if command -v "curl" > /dev/null; then
    curl -sS https://getcomposer.org/installer | php
else
    php -r "readfile('https://getcomposer.org/installer');" | php
fi

php composer.phar install
cd ./vendor/adafruit/bmp/ && sudo python setup.py install
cd $pwd/vendor/adafruit/dht/ && sudo setup.py install
cd $pwd/ && sqlite3 /db/pi-weatherstation.db < schema.sql