#!/bin/bash

pwd=`pwd`
source ./pi-weatherstation.cfg
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
sudo apt-get -y install sqlite3 build-essential python-dev python-smbus i2c-tools

echo -n "Setting up environment"
pause

# enable i2c modules
if [ -f ${etcModulesPath} ]; then
    sudo echo "i2c-bcm2708" >> ${etcModulesPath}
    sudo echo "i2c-dev" >> ${etcModulesPath}
fi

# comment out blacklist
if [ -f ${blacklistConfPath} ]; then
    sudo perl -pi -e 's/blacklist spi-bcm2708/#blacklist spi-bcm2708/g' ${blacklistConfPath}
    sudo perl -pi -e 's/blacklist i2c-bcm2708/#blacklist i2c-bcm2708/g' ${blacklistConfPath}
fi

# create cron job
if [ ${schedule:2:1} = 'm' ]; then
    echo "Set up cron job to run every" ${schedule:0:2} "minutes"
    pause
    crontab -l | { cat; echo "*/${schedule:0:2} * * * * cd ${pwd}/lib/ && python sensors.py > /dev/null"; } | crontab -
elif [ ${schedule:2:1} = 'h' ]; then
    echo "Set up cron job ro run every" ${schedule:0:2} "hours"
    pause
    crontab -l | { cat; echo "0 */${schedule:0:2} * * * cd ${pwd}/lib/ && python sensors.py > /dev/null"; } | crontab -
else
    echo "Wrong unit type in the config file: 'schedule' entry can only be Xh (for hours) or Xm (for minutes)"
    exit
fi

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