#!/bin/bash

source pi-weatherstation.cfg
pwd=`pwd`

function pause {
    sleep 3
}

# testing dht
echo "Testing DHT: sudo ./vendor/adafruit/dht/examples/AdafruitDHT.py ${sensor_dht} ${dht_pin}"
pause

cd ${pwd}/vendor/adafruit/dht/examples/
dht_output=$(sudo ./AdafruitDHT.py ${sensor_dht} ${dht_pin})
#dht_output="Temp=21.1*C  Humidity=50.5%"

if echo ${dht_output} | grep -q ".*Temp.*Hum.*"; then
  echo "DHT sensor is working!";
  pause
else
  echo "DHT sensor isn't working!";
  pause
fi

# testing bmp
echo "Testing BMP: sudo python ./vendor/adafruit/bmp/examples/simpletest.py"
pause

cd ${pwd}/vendor/adafruit/bmp/examples/
bmp_output=$(sudo python simpletest.py)
if echo ${bmp_output} | grep -q ".*Temp.*Pre.*Alt.*Sea.*"; then
  echo "BMP sensor is working!";
  pause
else
  echo "BMP sensor isn't working!";
  pause
fi