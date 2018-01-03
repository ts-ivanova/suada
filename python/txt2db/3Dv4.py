#!/usr/bin/python

import sys, datetime, getopt, MySQLdb, math
#from datetime import datetime


def values2db(vLine,tStart):
  datalist = []
  vData = vLine.split()
  for i, val in enumerate(vData):
    vTime = tStart + datetime.timedelta(hours=0,seconds=i*1800)
    datalist.append((vTime, val))
  return datalist
    #print vTime, val



def main(argv):
  inputfile = 'zLevels4stat.txt'
  try:
    opts, args = getopt.getopt(argv,"hi:",["ifile="])
  except getopt.GetoptError:
    print 'Usage: test.py -i <inputfile>'
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
      print 'test.py -i <inputfile>'
      sys.exit()
    elif opt in ("-i", "--ifile"):
      inputfile = arg
    else:
      print 'Wrong parameters, usage: test.py -i <inputfile>'
      sys.exit(2)

  try:
    f = open(inputfile)
    content = f.readlines()
    if len(content) > 0:
      firstLine = content[0]
      words = firstLine.split()
      startTime = words[4]
      print 'startTime: ',startTime
      timeStart = datetime.datetime.strptime(startTime, '%Y%m%d%H%M')
      startTime = words[7]
      recordCnt = words[11]

	#create DB connection
      db = MySQLdb.connect(host="10.1.1.220", user="meteo", passwd="xxxxxx", db="suada_4")
      cur = db.cursor()

      stationSourceId = -1
      count1 = 0
      while (count1 < 44):
        count1 = count1 + 1
        for index, line in enumerate(content):
          if line.find("Station:") > -1:
            values = line.split()
            stationName = values[1]
            stationLatt = values[2]
            stationLong = values[3]
            stationId   = values[4]
	    cur.execute("select ss.ID from SENSOR ss left join SOURCE src " +\
                "on src.ID = ss.SourceID left join STATION stn " +\
                "on stn.ID = ss.StationID where stn.ID = %s and src.ID = %s", [stationId,71])
	    rows =  cur.fetchall()
	    if len(rows):
              for row in rows:
		stationSourceId = row[0]
              print 'Station: ', stationName, ' ID: ', stationId, ' stationSourceId: ', stationSourceId
	    else:
	      stationSourceId = -1
              print 'Error occured. I can\'t find stationSourceId for station ', stationName, ' ID: ', stationId
	  if (line.find("Temperature (K)") > -1) & (stationSourceId > -1) :
                 data = content[index+count1]
                 tempmlst = values2db(data,timeStart)
	  if (line.find("Water vapor mixing ratio [kg kg-1]") > -1) & (stationSourceId > -1) :
		 data = content[index+count1]
		 wvmrlst  = values2db(data,timeStart)
                # count1 = count1 + 1
	  if (line.find("Model height [km]") > -1) & (stationSourceId > -1) :
                 data = content[index+count1]
                 hgtlst = values2db(data,timeStart)
	  if (line.find("Model pressure [hPa]") > -1) & (stationSourceId > -1) :
                 data = content[index+count1]
                 pressure2lst = values2db(data,timeStart)
 	  if (line.find("End") > -1) & (stationSourceId > -1) :
		for i, tup in enumerate(pressure2lst):
		  tk = float(tempmlst[i][1])
		  Press3D  = float(pressure2lst[i][1])
		  height = float(hgtlst[i][1])
		  QVAPOR = float(wvmrlst[i][1])
		  DateTime = pressure2lst[i][0].strftime('%Y-%m-%d %H:%M:%S')
		  Level = float(count1)
		  cur.execute ( "insert into NWP_IN_3D (Datetime, Temperature, Pressure, SensorID, Latitude, Longitude, Height, WV_Mixing_ratio, Level)\
	                   	values (%s, %s, %s, %s, %s, %s, %s, %s, %s) on duplicate key update\
				Temperature = %s,\
				Pressure = %s,\
			   	Latitude = %s,\
			   	Longitude = %s,\
				Height = %s,\
				WV_Mixing_ratio = %s,\
				Level = %s", [DateTime, tk, Press3D, stationSourceId, stationLatt, stationLong, height, QVAPOR, Level, tk, Press3D, stationLatt, stationLong, height, QVAPOR, Level]) #insert or update
		  db.commit()		  
    else:
        print 'Input file seems empty'
        sys.exit(2)



  except IOError:
    print 'File ',inputname,' not found !!!'


if __name__ == "__main__":
   main(sys.argv[1:])
