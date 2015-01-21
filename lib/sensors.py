#!/usr/bin/python
# coding=utf-8

# Copyright (c) 2014 Adafruit Industries
# Author: Tony DiCola
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Can enable debug output by uncommenting:
#import logging
#logging.basicConfig(level=logging.DEBUG)

import Adafruit_BMP.BMP085 as BMP085
import Adafruit_DHT

import ConfigParser
import sqlite3
import sys

config = ConfigParser.ConfigParser()
config.readfp(open(r'../pi-weatherstation.cfg'))

# Default constructor will pick a default I2C bus.
#
# For the Raspberry Pi this means you should hook up to the only exposed I2C bus
# from the main GPIO header and the library will figure out the bus number based
# on the Pi's revision.
#
# For the Beaglebone Black the library will assume bus 1 by default, which is
# exposed with SCL = P9_19 and SDA = P9_20.
# You can also optionally change the BMP085 mode to one of BMP085_ULTRALOWPOWER, 
# BMP085_STANDARD, BMP085_HIGHRES, or BMP085_ULTRAHIGHRES.  See the BMP085
# datasheet for more details on the meanings of each mode (accuracy and power
bmp_sensor = BMP085.BMP085()

# consumption are primarily the differences).  The default mode is STANDARD.
#bmp_sensor = BMP085.BMP085(mode=BMP085.BMP085_ULTRAHIGHRES)

# Sensor should be set to Adafruit_DHT.DHT11,
# Adafruit_DHT.DHT22, or Adafruit_DHT.AM2302.
config_sensor_dht = int(config.get('config', 'sensor_dht'))

if config_sensor_dht == 11:
    dht_sensor = Adafruit_DHT.DHT11
elif config_sensor_dht == 22:
    dht_sensor = Adafruit_DHT.DHT22
elif config_sensor_dht == 2302:
    dht_sensor = Adafruit_DHT.AM2302
else:
    print "Wrong type for 'sensor_dht' in config file: 'sensor_dht' only supports one of 11, 22 or 2302"
    sys.exit(-1)

# Optionally you can override the bus number:
#bmp_sensor = BMP085.BMP085(busnum=2)

# Example using a Beaglebone Black with DHT sensor
# connected to pin P8_11.
#dht_pin = 'P8_11'

# Example using a Raspberry Pi with DHT sensor
# connected to pin 23.
dht_pin = int(config.get('config', 'dht_pin'))

# Try to grab a sensor reading.  Use the read_retry method which will retry up
# to 15 times to get a sensor reading (waiting 2 seconds between each retry).
humidity, temp1 = Adafruit_DHT.read_retry(dht_sensor, dht_pin)
temp2 = bmp_sensor.read_temperature()
pressure = bmp_sensor.read_sealevel_pressure(altitude_m=int(config.get('config', 'altitude')))

if temp1 is None:
    temp = temp2
elif temp2 is None:
    temp = temp1
else: temp = (temp1 + temp2) / 2

# persist measurement
conn = sqlite3.connect('../db/pi-weatherstation.db')
c = conn.cursor()

wd = (None, temp, humidity, pressure, None)
c.execute('INSERT INTO weather_data VALUES (?,?,?,?,?)', wd)

c.commit()
c.close()

print 'Temperature = {0:0.1f} °C'.format(temp)
print 'Pressure = {0:0.1f} hPa'.format(pressure / 100)
print 'Humidity = {} %'.format(int(round(humidity))) 
