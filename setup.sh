#!/bin/bash

pwd=`pwd`
source ./pi-weatherstation.cfg
blacklistConfPath="/etc/modprobe.d/raspi-blacklist.conf"
etcModulesPath="/etc/modules"
bootConfigPath="/boot/config.txt"
cgibinPath="/usr/lib/cgi-bin"
wwwPath="/var/www/html"

function pause {
    echo -n "."
    sleep 1
    echo -n "."
    sleep 1
    echo "."
    sleep 1
    echo
}

# install packages
echo
echo -n "Install system packages"
pause

sudo apt-get update
sudo apt-get -y install sqlite3 build-essential python-dev python-smbus i2c-tools apache2

echo
echo -n "Setting up environment"
pause

# enable cgi module
sudo a2enmod cgi

# set installation path as apache env var
sudo echo "SetEnv PIWS_HOME ${pwd}" > .htaccess
sudo mv .htaccess ${cgibinPath}

# move python script to cgi-bin and set correct permissions
sudo mv lib/getWeatherData.py ${cgibinPath}
sudo chmod 755 ${cgibinPath}/getWeatherData.py

# move website to www folder
sudo mkdir -p ${wwwPath}/pi-weatherstation
sudo mv index.html ${wwwPath}/pi-weatherstation
sudo mv vendor/highsoft/highcharts.js ${wwwPath}/pi-weatherstation

sudo service apache2 restart

# enable i2c modules
if [ -f ${etcModulesPath} ]; then
    sudo echo "i2c-bcm2708" >> ${etcModulesPath}
    sudo echo "i2c-dev" >> ${etcModulesPath}
fi

# edit boot options
if [ -f ${bootConfigPath} ]; then
    sudo echo "dtparam=i2c1=on" >> ${bootConfigPath}
    sudo echo "dtparam=i2c_arm=on" >> ${bootConfigPath}
fi

# comment out blacklist
if [ -f ${blacklistConfPath} ]; then
    sudo perl -pi -e 's/blacklist spi-bcm2708/#blacklist spi-bcm2708/g' ${blacklistConfPath}
    sudo perl -pi -e 's/blacklist i2c-bcm2708/#blacklist i2c-bcm2708/g' ${blacklistConfPath}
fi

# create cron job
echo
if [ ${schedule:2:1} = 'm' ]; then
    echo -n "Set up cron job to run every" ${schedule:0:2} "minutes"
    pause
    crontab -l | { cat; echo "*/${schedule:0:2} * * * * cd ${pwd}/lib/ && python sensors.py > /dev/null"; } | crontab -
elif [ ${schedule:2:1} = 'h' ]; then
    echo -n "Set up cron job ro run every" ${schedule:0:2} "hours"
    pause
    crontab -l | { cat; echo "0 */${schedule:0:2} * * * cd ${pwd}/lib/ && python sensors.py > /dev/null"; } | crontab -
else
    echo "Wrong unit type in the config file: 'schedule' entry can only be Xh (for hours) or Xm (for minutes)"
    exit
fi

echo
echo -n "Setting up sensor libraries"
pause

# sensor libraries
cd ./vendor/adafruit/bmp/ && sudo python setup.py install
cd ${pwd}/vendor/adafruit/dht/ && sudo python setup.py install
cd ${pwd}/ && sqlite3 ./db/pi-weatherstation.db < ./db/schema.sql

# delete setup file and reboot
rm -- "$0"
read -p "System needs to be rebooted, reboot now? [y/n]" -n 1 -r REPLY
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo reboot
else
    echo "You have to reboot the system before using pi-weatherstation"
fi
