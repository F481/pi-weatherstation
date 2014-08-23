#!/bin/bash

source pi-weatherstation.cfg
pwd=`pwd`

function pause {
    sleep 2
}

# testing dht
echo "Testing DHT: sudo ./vendor/adafruit/dht/examples/AdafruitDHT.py ${sensor_dht} ${dht_pin}"

cd ${pwd}/vendor/adafruit/dht/examples/
dht_output=$(sudo ./AdafruitDHT.py ${sensor_dht} ${dht_pin})

if echo ${dht_output} | grep -q ".*Temp.*Hum.*"; then
  echo "DHT sensor is working:";
  echo ${dht_output}
  pause
else
  echo "DHT sensor isn't working!";
  pause
fi

# testing bmp
echo
echo "Testing BMP: sudo python ./vendor/adafruit/bmp/examples/simpletest.py"

cd ${pwd}/vendor/adafruit/bmp/examples/
bmp_output=$(sudo python simpletest.py)
if echo ${bmp_output} | grep -q ".*Temp.*Pre.*Alt.*Sea.*"; then
  echo "BMP sensor is working:";
  echo ${bmp_output}
else
  echo "BMP sensor isn't working!";
fi