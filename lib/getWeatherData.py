#!/usr/bin/python

import sqlite3, json, datetime, time

print "Content-type:application/json\r\n\r\n"

# todo make path variable
conn = sqlite3.connect('/home/pi/pi-weatherstation/db/pi-weatherstation.db')
c = conn.cursor()

c.execute('SELECT * FROM {tn}'.\
        format(tn='weather_data'))

weather_data = {}
data_point_temp = []
data_point_hum = []
data_point_pres = []

for row in c.fetchall():

        timestamp = time.mktime(datetime.datetime.strptime(row[4], "%Y-%m-%d %H:%M:%S").timetuple())*1000
        data_point_temp.append([timestamp, round(row[1], 1)])
        data_point_hum.append([timestamp, round(row[2], 1)])
        data_point_pres.append([timestamp, round(row[3]/100, 1)])

weather_data["temperature"] = data_point_temp
weather_data["humidity"] = data_point_hum
weather_data["pressure"] = data_point_pres

print json.dumps(weather_data)
