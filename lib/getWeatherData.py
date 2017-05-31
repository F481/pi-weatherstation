#!/usr/bin/python

import sqlite3, json

print "Content-type:application/json\r\n\r\n"

# todo make path variable
conn = sqlite3.connect('/home/pi/pi-weatherstation/db/pi-weatherstation.db')
c = conn.cursor()

c.execute('SELECT * FROM {tn}'.\
        format(tn='weather_data'))

weather_data = []

for row in c.fetchall():
        data_point = {}

        data_point["id"] = row[0]
        data_point["temperature"] = row[1]
        data_point["humidity"] = row[2]
        data_point["pressure"] = row[3]
        data_point["timestamp"] = row[4]

        weather_data.append(data_point)

print json.dumps(weather_data)

