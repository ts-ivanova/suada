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
  inputfile = '20130101.txt'
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
	db = MySQLdb.connect(host="10.1.1.220", user="meteo", passwd="xxxxxxxx", db="suada_4")
	cur = db.cursor()

	stationSourceId = -1
        for index, line in enumerate(content):
#        for line in content:
#	  stationSourceId = -1
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
          if (line.find("Surface Temperature [K]") > -1) & (stationSourceId > -1) :
                data = content[index+1]
                templst = values2db(data,timeStart)
#	  if (line.find("Temperature [K]") > -1) & (stationSourceId > -1) :
#		data = content[index+1]
#		tempmlst = values2db(data,timeStart)
	  if (line.find("Pressure [Pa]") > -1) & (stationSourceId > -1) :
                data = content[index+1]
                pressurelst = values2db(data,timeStart)
	  if (line.find("PBL HEIGHT (m)") > -1) & (stationSourceId > -1) :
		data = content[index+1]
		pblhlst = values2db(data,timeStart)
#	  if (line.find("Model pressure [hPa]") > -1) & (stationSourceId > -1) :
#               data = content[index+1]
#               pressure2lst = values2db(data,timeStart)
#	  if (line.find("Model height [km]") > -1) & (stationSourceId > -1) :
#               data = content[index+1]
#               hgtlst = values2db(data,timeStart)
	  if (line.find("Terrain Height [m]") > -1) & (stationSourceId > -1) :
                data = content[index+1]
                hgtterrlst = values2db(data,timeStart)
#	  if (line.find("Water vapor mixing ratio [kg kg-1]") > -1) & (stationSourceId > -1) :
#		data = content[index+1]
#		wvmrlst  = values2db(data,timeStart)
	  if (line.find("Rain convective [mm]") > -1) & (stationSourceId > -1) :
                data = content[index+1]
                rainconv = values2db(data,timeStart)
	  if (line.find("Rain non-convective [mm]") > -1) & (stationSourceId > -1) :
                data = content[index+1]
                rainnonconv = values2db(data,timeStart)
#	  if (line.find("Zenith Hydrostatic Delay [m]") > -1) & (stationSourceId > -1) :
#		data = content[index+1]
#		zhdlst  = values2db(data,timeStart)
	  if (line.find("End") > -1) & (stationSourceId > -1) :
		for i, tup in enumerate(templst):
		  T2 = float(templst[i][1])
#		  tk = float(tempmlst[i][1])
		  PSFC  = float(pressurelst[i][1])
		  PBLH  = float(pblhlst[i][1])
#		  Press3D  = (pressure2lst[i][1])
#		  height = float(hgtlst[i][1])
  		  HGT = float(hgtterrlst[i][1])
#		  QVAPOR = float(wvmrlst[i][1])
#		  TerrHeight[km], lat[RAD], Surface_pressure [hPa]
#		  func=1-0.00266*math.cos(2*(float(latlst[i][1]))*3.1416/180))-0.00028*(float(hgtterrlst[i][1]))/1000  
		  ZHD=(0.0022768*(float(pressurelst[i][1])))/(1-0.00266*math.cos(2*(float(stationLatt))*(3.1416/180))-(0.00028*(float(hgtterrlst[i][1]))/1000))
		  DateTime = templst[i][0].strftime('%Y-%m-%d %H:%M:%S')
                  Rain = float(rainnonconv[i][1]) + float(rainconv[i][1])
#		  print DateTime,  Temperature, Pressure, HGT
		  #Prepare SQL statement
		  cur.execute ( "insert into NWP_IN_1D (Datetime, Temperature, Pressure, Altitude, SensorID, Latitude, Longitude, ZHD, PBL, Precipitation)\
	                   	values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s) on duplicate key update\
				Temperature = %s,\
				Pressure = %s,\
				Altitude = %s,\
			   	Latitude = %s,\
			   	Longitude = %s,\
			   	ZHD = %s,\
			   	PBL = %s,\
			   	Precipitation = %s", [DateTime, T2, PSFC, HGT, stationSourceId, stationLatt, stationLong, ZHD, PBLH, Rain, T2, PSFC, HGT, stationLatt, stationLong, ZHD, PBLH, Rain])
		  db.commit()	  
      else:
        print 'Input file seems empty'
        sys.exit(2)

     

  except IOError:
    print 'File ',inputname,' not found !!!'


if __name__ == "__main__":
   main(sys.argv[1:])











