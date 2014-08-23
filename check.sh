#!/bin/bash

source pi-weatherstation.cfg
pwd=`pwd`

function pause {
    sleep 1
}

# testing dht
echo "Testing DHT: sudo ./vendor/adafruit/dht/examples/AdafruitDHT.py ${sensor_dht} ${dht_pin}"
pause

cd ${pwd}/vendor/adafruit/dht/examples/
dht_output=$(sudo ./AdafruitDHT.py ${sensor_dht} ${dht_pin})

if echo ${dht_output} | grep -q ".*Temp.*Hum.*"; then
  echo "DHT sensor is working: ${dht_output}";
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
  echo "BMP sensor is working: ${bmp_output}";
  pause
else
  echo "BMP sensor isn't working!";
  pause
fi