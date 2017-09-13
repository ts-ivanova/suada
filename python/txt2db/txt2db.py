#!/usr/bin/python

import sys, datetime, getopt, MySQLdb, math
#from datetime import datetime


def values2db(vLine,tStart):
  datalist = []
  vData = vLine.split()
  for i, val in enumerate(vData):
    vTime = tStart + datetime.timedelta(hours=2,seconds=i*1800)
    datalist.append((vTime, val))
  return datalist
    #print vTime, val



def main(argv):
  inputfile = ''
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
	db = MySQLdb.connect(host="cn001", user="meteo", passwd="xxxxxx", db="meteodb")
	cur = db.cursor()

	stationSourceId = -1
        for index, line in enumerate(content):
#        for line in content:
#	  stationSourceId = -1
          if line.find("Station:") > -1:
            values = line.split()
            stationName = values[1]
            stationLong = values[2]
            stationLatt = values[3]
            stationId   = values[4]
	    cur.execute("select ss.ID from STATION_SOURCE ss left join SOURCE src " +\
                "on src.ID = ss.SourceID left join STATION stn " +\
                "on stn.ID = ss.StationID where stn.ID = %s and src.ID = %s", [stationId,7])
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
	  if (line.find("Pressure [Pa]") > -1) & (stationSourceId > -1) :
                data = content[index+1]
                pressurelst = values2db(data,timeStart)
	  if (line.find("Rain total [mm]") > -1) & (stationSourceId > -1) :
                data = content[index+1]
                rainlst = values2db(data,timeStart)
	  if (line.find("Vapor at 2 m [kg kg-1]") > -1) & (stationSourceId > -1) :
                data = content[index+1]
                vaporlst = values2db(data,timeStart)
	  if (line.find("Cloud fraction [-]") > -1) & (stationSourceId > -1) :
                data = content[index+1]
                cloudlst = values2db(data,timeStart)
	  if (line.find("Wind X [m / s]") > -1) & (stationSourceId > -1) :
                data = content[index+1]
                windUlst = values2db(data,timeStart)
	  if (line.find("Wind Y [m / s]") > -1) & (stationSourceId > -1) :
                data = content[index+1]
                windVlst = values2db(data,timeStart)
	  if (line.find("Relative Humidity at 2m (%)") > -1) & (stationSourceId > -1) :
		data = content[index+1]
		humidlst = values2db(data,timeStart)
	  if (line.find("Total cloud fraction [-]") > -1) & (stationSourceId > -1) :
		data = content[index+1]
		tcldlst  = values2db(data,timeStart)
	  if (line.find("End") > -1) & (stationSourceId > -1) :
		for i, tup in enumerate(templst):
		  T2 = float(templst[i][1])
		  Temp  = T2 - 273.15
		  PSCF  = float(pressurelst[i][1])
		  Press = PSCF / 100
		  if ( i > 1) :
		    Rain1h = float(rainlst[i][1]) - float(rainlst[i-2][1])
	          else :
                    Rain1h = 0.0
		  if ( i > 5) :
                    Rain3h = float(rainlst[i][1]) - float(rainlst[i-6][1])
                  else :
                    Rain3h = 0.0
		  Q2    = float(vaporlst[i][1])
		  PQ0   = 379.90516
		  A2    = 17.2693882
		  A3    = 273.16
		  A4    = 35.86
#		  Humid = Q2 / ( (PQ0 / PSCF) * math.exp(A2 * (T2 - A3) / (T2 - A4))  )
		  Humid = float(humidlst[i][1])/100
		  Vapor = Q2
		  Cloud = float(tcldlst[i][1])
		  WindS = math.sqrt(float(windUlst[i][1])**2+float(windVlst[i][1])**2)**1.89
		  WindD = 57.2957795*math.atan2(float(windUlst[i][1]),float(windVlst[i][1]))+180
	  	  DateTime = templst[i][0].strftime('%Y-%m-%d %H:%M:%S')
#		  print DateTime, Temp, Press, Rain1h, Rain3h, Vapor, Humid, Cloud, WindS, WindD 
		  #Prepare SQL statement
		  cur.execute ( "insert into SYNOP (Datetime, Pressure, Temperature, Humidity, Station_SourceID, Cloud, Wind_Dir, Wind_Speed, Precipitation_1h,Precipitation_3h)\
	                   	values (%s, %s, %s, %s, %s,  %s,  %s,  %s,  %s, %s) on duplicate key update\
			   	Pressure    = %s,\
			   	Temperature = %s,\
			   	Humidity    = %s,\
			   	Cloud       = %s,\
			   	Wind_Dir    = %s,\
			   	Wind_Speed =  %s,\
			   	Precipitation_1h = %s,\
				Precipitation_3h = %s", [DateTime, Press, Temp, Humid, stationSourceId, Cloud, WindD, WindS, Rain1h, Rain3h, Press, Temp, Humid, Cloud, WindD, WindS, Rain1h, Rain3h])
		  db.commit()	  
      else:
        print 'Input file seems empty'
        sys.exit(2)

     

  except IOError:
    print 'File ',inputname,' not found !!!'


if __name__ == "__main__":
   main(sys.argv[1:])











