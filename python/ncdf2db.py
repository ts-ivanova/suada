import sys, getopt
import glob
from tzlocal import get_localzone
from dateutil import parser
import datetime
from netCDF4 import Dataset as netcdf
import MySQLdb
import databaseconfig as cfg
import math

# Aim of python scripts in this project: to export the model data stored in netCDF format to a SUADA database.



# Define a function that selects the stations' ID, Name, Longitude, Latitude, Altitude form the COORDINATE table:
def getstations(cur):
  stations=[]
  try:
    cur.execute("select st.ID, st.Name, crd.Longitude, crd.Latitude, crd.Altitude from COORDINATE as crd left join STATION as st ON crd.StationID = st.ID where crd.InstrumentID = 1 and st.Country = 'BG';")

    rows =  cur.fetchall()

    if len(rows):
	  for row in rows:
	    stations.append({'id':row[0], 'name':row[1], 'long':row[2], 'latt':row[3], 'alt':row[4]})
  except Exception as e:
    print('Error at getstations: {}'.format(e))

  return stations



# Define a function called listfiles:
def listfiles(basedir, prefix):
  files = []
  try:
    for file in sorted(glob.glob(basedir+'/'+prefix+"*")):
      files.append(file)
  except Exception as e:
    print('Exception reading basefolder {} {}'.format(basedir,e))
  return files



# Define the following procedure that takes source_name as an argument and returns
# source_id as a result, which is later used when inserting into 1D and 3D databases.
def get_source_id(cur, source_name):
  source_id = -1
  try:
    cur.execute("SELECT ID FROM SOURCE WHERE Name = %(source_name)s", {'source_name' : source_name}) # source_id or source_name at the end ???

    rows = cur.fetchall()

    if len(rows):
      for row in rows:
        source_id = row[0]

  except Exception as e:
    print('Error at get_source_id: {}'.format(e))

  finally:
    return source_id

# Define the main procedure:
def main(argv):
  basedir='./'
  prefix='wrfout_d02'
  env = 'dev' # possible options are 'dev' and 'prod'
  source_name = ''

  try:
    opts, args = getopt.getopt(argv,"h:b:p:s:",["basedir=","prefix=","source_name="])
  except getopt.GetoptError:
    print 'ncdf2db.py -b <basedir> ['+basedir+'] -p <prefix> ['+prefix+'] -s <source_name> ['+str(source_name)+']'
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
      print 'ncdf2db.py -b <basedir> ['+basedir+'] -p <prefix> ['+prefix+'] -s <source_name> ['+str(source_name)+']'
      sys.exit()
    elif opt in ("-b", "--basedir"):
      basedir = arg
    elif opt in ("-p", "--prefix"):
      prefix = arg
    elif opt in ("-s", "--source_name"):
      source_name = str(arg)

  # Check whether the user has specified source name. If not -> Error.
  if source_name == None:
    print 'Error: You must specify the source name! (-s <source_name>)'
    sys.exit()

  # Retrieve the list of all data files
  # starting with [prefix] inside [basedir] folder
  flist = listfiles(basedir, prefix)

  # Create DB connection
  print('DB -> {}'.format(cfg.dev['db']))
  # create DB connection
  db = None
  cur = None
  try:
    db = MySQLdb.connect(host=cfg.dev['host'], user=cfg.dev['user'], passwd=cfg.dev['passwd'], db=cfg.dev['db'])
    cur = db.cursor()
  except Exception as e:
    print('Failed to establish connection: {0}'.format(e))
    cur.close()
    sys.exit(1)


  print('Try to fetch the source_id ...')
  source_id = get_source_id(cur, source_name)
  if source_id < 0:
    print 'Error: Can not find source_id for source name: {}'.format(source_name)
    sys.exit(1)
 
  print('Source id: {} found for source name: {}'.format(source_id, source_name))

  print('Get stations')
  stations = getstations(cur)

  print('Iterate files')
  # Iterate over list of all data files
  for file in flist:
    field2D = []
    print 'Processing: ', file

    ncfile = netcdf(file)
    strDateTime = ncfile.variables['Times'][0].tostring().replace('_', ' ')
    local_tz = get_localzone()
    date = parser.parse(strDateTime)
    strDateTimeLocal = local_tz.localize(date)
    # Print the timestamp
    print('Dataset timestamp: {}'.format(strDateTimeLocal))
    xlong = ncfile.variables['XLONG'][0]
    xlat = ncfile.variables['XLAT'][0]
    alt = ncfile.variables['HGT'][0]
    T2 = ncfile.variables['T2'][0]
    Pressure = ncfile.variables['PSFC'][0]
    PBLH = ncfile.variables['PBLH'][0]
    HGT = ncfile.variables['HGT'][0]
    RAINNC = ncfile.variables['RAINNC'][0]
    SNOWNC = ncfile.variables['SNOWNC'][0]
    GRAUPELNC = ncfile.variables['GRAUPELNC'][0]
    HAILNC = ncfile.variables['HAILNC'][0]
    Precipitation = RAINNC + SNOWNC + GRAUPELNC + HAILNC
    south_north = len(xlong)
    west_east = len(xlong[0])
    # Above are most of the used parameters
    # 3D fields
    T = ncfile.variables['T'][0]
    P = ncfile.variables['P'][0]
    PB = ncfile.variables['PB'][0]
    PHB = ncfile.variables['PHB'][0]
    PH = ncfile.variables['PH'][0]
    QVAPOR = ncfile.variables['QVAPOR'][0]
    bottom_top = len(T)
    print('bottom_top = {}'.format(bottom_top))

    Rd          = 287.0
    Cp          = 7.0*Rd / 2.0
    Rd_Cp       = Rd / Cp
    # used for 3D calculation of tk

    for station in stations:
      cur.execute("select ss.ID from SENSOR ss left join SOURCE src " +\
              "on src.ID = ss.SourceID left join STATION stn " +\
              "on stn.ID = ss.StationID where stn.ID = %s and src.ID = %s", [station['id'], source_id])
      rows =  cur.fetchall()
      stationName = station['name']
      stationId = station['id']
      if len(rows):
        for row in rows:
          stationSourceId = row[0]
          print 'Station: ', station['name'], ' ID: ', station['id'], ' stationSourceId: ', stationSourceId
      else:
        stationSourceId = -1
        print 'Error occured. I can\'t find stationSourceId for station ', stationName, ' ID: ', stationId
        break
      x0 = station['long']
      y0 = station['latt']
      z0 = station['alt']
      rmin = math.sqrt((x0-(xlong[0][0]))**2+(y0-xlat[0][0])**2+(z0-alt[0][0])**2)
      i0=0
      j0=0
      for i in range(0, south_north - 1):
        for j in range(0, west_east - 1):
          x = xlong[i][j]
          y = xlat[i][j]
          z = alt[i][j]
          # calculate the distance to the closest meteostation
          r = math.sqrt((x0-x)*(x0-x)+(y0-y)**2+(z0-z)**2)

          if (r < rmin):
            rmin = r
            i0 = i
            j0 = j

      press = Pressure[i][j]
      heigth = HGT[i][j]
      zhd = (0.0022768*(float(press)))/(1-0.00266*math.cos(2*(float(z0))*(3.1416/180))-(0.00028*(float(heigth))/1000))
      # zhd = zenith hydrostatic delay
      pblh = PBLH[i][j]
      temp = T2[i][j]
      rain = Precipitation[i][j]
      print('Name: {0} [{1}, {2}, {3}] -> [Temperarture [K]: {4}, Pressure [Pa]: {5}, Rain [mm]: {6}, PBL HEIGHT [m]: {7}, Zenit Heigth Delay [x]: {8}] '.format(station['name'], xlong[i0][j0], xlat[i0][j0], alt[i0][j0], temp, press, rain, pblh, zhd))

      # SQL commands that insert values of parameters in the 1D table.
      # If there is a dublicate, the existing fileds are updated.
      cur.execute ( "insert into NWP_IN_1D (Datetime, Temperature, Pressure, Altitude, SensorID, Latitude, Longitude, ZHD, PBL, Precipitation)\
                     values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s) on duplicate key update\
             Temperature = %s,\
             Pressure = %s,\
             Altitude = %s,\
             Latitude = %s,\
             Longitude = %s,\
             ZHD = %s,\
             PBL = %s,\
             Precipitation = %s", [date, temp, press, heigth, stationSourceId, y, x, zhd, pblh, rain, temp, press, heigth, y, x, zhd, pblh, rain])
      #db.commit()
      # 3D data insert
      for k in range(0, bottom_top):
          theta = T[k][i0][j0] + 300.
          Pair = P[k][i0][j0] + PB[k][i0][j0] # Press3D = Pair
          tk  = theta * (( Pair/100000. )**(Rd_Cp))
          QV = QVAPOR[k][i0][j0]
          hgth = (PH[k][i0][j0] + PHB[k][i0][j0])/9.8

          cur.execute ( "insert into NWP_IN_3D (Datetime, Temperature, Pressure, SensorID, Latitude, Longitude, Height, WV_Mixing_ratio, Level)\
	                   	values (%s, %s, %s, %s, %s, %s, %s, %s, %s) on duplicate key update\
				Temperature = %s,\
				Pressure = %s,\
			   	Latitude = %s,\
			   	Longitude = %s,\
				Height = %s,\
				WV_Mixing_ratio = %s,\
				Level = %s", [date, tk, Pair, stationSourceId, y, x, hgth, QV, k, tk, Pair, y, x, hgth, QV, k]) # insert or update

      db.commit()
      # break
      # QVAPOR is the mixing ratio

  if not(len(flist)):
    print 'No candidates for impot files found ...'
    sys.exit(1)


if __name__ == "__main__":
  main(sys.argv[1:])
