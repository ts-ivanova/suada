# Stoyan Pisov
# Tsvetelina Ivanova

# Faculty of Physics, Sofia University "St. Kliment Ohridski"
# 2017, 2018

# Aim of the python scripts in this project: to export the data from
# the WRF model stored in netCDF format to a SUADA database (in NWP 1D and 3D tables).

import sys, getopt
import glob
from tzlocal import get_localzone
from dateutil import parser
import datetime
from netCDF4 import Dataset as netcdf
import MySQLdb
import databaseconfig as cfg
import numpy as np
import wrf
import re

# Define global variables
t_kelvin = 273.15


# Define a procedure that selects the stations' ID, Name, Longitude,
# Latitude, Altitude from the SUADA information tables:
def getstations(cur, source_name, country, instrument_name):
	stations=[]
	try:
		cur.execute("select st.ID, \
			st.Name, \
			crd.Longitude, \
			crd.Latitude, \
			crd.Altitude, \
			sen.ID, \
			st.Country \
			from SENSOR as sen left join SOURCE as so ON so.ID = sen.SourceID \
			left join STATION as st ON st.ID = sen.StationID \
			left join COORDINATE as crd ON crd.STationID = st.ID \
			left join INSTRUMENT as instr ON instr.ID = crd.InstrumentID \
			WHERE so.Name = %(source_name)s \
			AND instr.Name = %(instrument_name)s",
			{
				'source_name' : source_name,
				'instrument_name' : instrument_name
			})
		rows =  cur.fetchall()

		if len(rows):
			for row in rows:
				stations.append({'id':row[0],
					'name':row[1],
					'long':row[2],
					'latt':row[3],
					'alt':row[4],
					'senid':row[5],
					'country':row[6]})
	except Exception as e:
		print('Error at getstations: {}'.format(e))

	return stations

# Define a procedure that lists files containing data
# in the selected by the user base directory and prefix:
def listfiles(basedir, prefix):
	files = []
	try:
		for file in sorted(glob.glob(basedir+'/'+prefix+"*")):
			files.append(file)
	except Exception as e:
		print('Exception reading basefolder {} {}'.format(basedir,e))
	return files

# Define a procedure that takes source_name as
# an argument and returns source_id as a result, which is
# later used when inserting into 1D and 3D databases:
def get_source_id(cur, source_name):
	source_id = -1
	try:
		cur.execute("SELECT ID FROM SOURCE WHERE Name = %(source_name)s", {'source_name' : source_name})
		rows = cur.fetchall()
		if len(rows):
			for row in rows:
				source_id = row[0]
	except Exception as e:
		print('Error at get_source_id: {}'.format(e))
	finally:
		return source_id

# Define a procedure that takes the country (that the user specified when running the script)
# as an argument and returns the station names in this country as a result:
def get_station_name(cur, country):
	name = -1
	try:
		if not country:
			cur.execute("SELECT Name FROM STATION")
		else:
            		cur.execute("SELECT Name FROM STATION WHERE Country = %(country)s", {'country' : country})
			rows = cur.fetchall()
			if len(rows):
				for row in rows:
					name = row[0]
	except Exception as e:
		print('Error at get_station_name: {}'.format(e))
	finally:
		return name

# Define a procedure that inserts model data for each station into the SUADA database:
def process_station(db, cur, station, ncfile, date):
	result = True
	try:
                stationName = station['name']
		stationId = station['id']
		sensorId = station['senid']
		x0 = station['long']
		y0 = station['latt']
		z0 = station['alt']
		i0 = station['i0']
		j0 = station['j0']
		print 'Station: ', station['name'], ' ID: ', station['id'], ' sensorId: ', sensorId
        	# 1D fields:
	        T2 = ncfile.variables['T2'][0]
        	Pressure = ncfile.variables['PSFC'][0]
	        PBLH = ncfile.variables['PBLH'][0]
	        HGT = ncfile.variables['HGT'][0]
	        RAINNC = ncfile.variables['RAINNC'][0]
	        SNOWNC = ncfile.variables['SNOWNC'][0]
	        GRAUPELNC = ncfile.variables['GRAUPELNC'][0]
	        HAILNC = ncfile.variables['HAILNC'][0]
	        Precipitation = RAINNC + SNOWNC + GRAUPELNC + HAILNC
	        # 3D fields:
	        T = ncfile.variables['T'][0]
	        P = ncfile.variables['P'][0]
	        PB = ncfile.variables['PB'][0]
	        PHB = ncfile.variables['PHB'][0]
	        PH = ncfile.variables['PH'][0]
	        QVAPOR = ncfile.variables['QVAPOR'][0]

		# Import 1D fields
                press = Pressure[i0][j0]/100.
                heigth = HGT[i0][j0]
                zhd = (0.0022768*(float(press)))/(1.-0.00266*np.cos(2*(float(z0))*(3.1416/180.))-(0.00028*(float(heigth))/1000.))
                # zhd = zenith hydrostatic delay
                pblh = PBLH[i0][j0]
                temp = T2[i0][j0]-t_kelvin
                rain = Precipitation[i0][j0]
                print('Name: {0} [{1}, {2}, {3}] -> [Temperarture [C]: {4}, Pressure [hPa]: {5}, Rain [mm]: {6}, PBL HEIGHT [m]: {7}, Zenit Heigth Delay [x]: {8}] '
                      .format(station['name'],
                              x0,
                              y0,
                              z0,
                              temp,
                              press,
                              rain,
                              pblh,
                              zhd))

                # SQL commands that insert values of parameters in the tables.
                # If there is a dublicate, the existing fileds are updated.
                # 1D data insertion:
                cur.execute ( "insert into NWP_IN_1D (Datetime, \
			Temperature, \
			Pressure, \
			Altitude, \
			SensorID, \
			Latitude, \
			Longitude, \
			ZHD, \
			PBL, \
			Precipitation)\
        	        values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s) on duplicate key update\
	                Temperature = %s,\
	                Pressure = %s,\
	                Altitude = %s,\
	                Latitude = %s,\
	                Longitude = %s,\
	                ZHD = %s,\
	                PBL = %s,\
	                Precipitation = %s", [date,
			temp,
			press,
			heigth,
			sensorId,
			y0,
			x0,
			zhd,
			pblh,
			rain,
			temp,
			press,
			heigth,
			y0,
			x0,
			zhd,
			pblh,
			rain])
                # 3D data insertion:
		bottom_top = len(T)
                # First, calculation of tk:
		# Rd, Cp, Rd_Cp are used for 3D calculation of tk (absolute temperature [K], and then it's converted to [C]):
                Rd  = 287.0
		Cp  = 7.0 * Rd / 2.0
		Rd_Cp  = Rd / Cp # dimensionless
                for k in range(0, bottom_top):
			theta = T[k][i0][j0] + 300. # [K]
			Pair = (P[k][i0][j0] + PB[k][i0][j0])/100. # Press3D = Pair/100.0 [hPa]
                        # P is perturbation pressure; PB is base state pressure
			tk  = theta * (( 100.*Pair/100000. )**(Rd_Cp)) - t_kelvin # (... - t_kelvin) converts T to Celsius.
                        # (100.*Pair) is again in [Pa], because in the formula for tk it should be in [Pa].
			QV = QVAPOR[k][i0][j0] # water vapour mixing ratio
                    	hgth = (PH[k][i0][j0] + PHB[k][i0][j0])/9.8

                        #3D data insert:
			cur.execute ( "insert into NWP_IN_3D (Datetime, \
				Temperature, \
				Pressure, \
				SensorID, \
				Latitude, \
				Longitude, \
				Height, \
				WV_Mixing_ratio, \
				Level)\
				values (%s, %s, %s, %s, %s, %s, %s, %s, %s) on duplicate key update\
				Temperature = %s,\
				Pressure = %s,\
				Latitude = %s,\
				Longitude = %s,\
				Height = %s,\
				WV_Mixing_ratio = %s,\
				Level = %s", [date,
				tk,
				Pair,
				sensorId,
				y0,
				x0,
				hgth,
				QV,
				k,
				tk,
				Pair,
				y0,
				x0,
				hgth,
				QV,
				k]) # insert or update

		db.commit() # commit all data to the specified -d <env>

	except Exception as e:
		sys.stderr.write('Error occured in process_station: {error}'.format(error = repr(e)))
	finally:
		return result



# Define a procedure that accumulates data for each station:
def process_station_tro(station, ncfile, date):
	result = True
	try:
                stationName = station['name']
		stationId = station['id']
		sensorId = station['senid']
		x0 = station['long']
		y0 = station['latt']
		z0 = station['alt']
		i0 = station['i0']
		j0 = station['j0']
		print 'Station: ', station['name'], ' ID: ', station['id'], ' sensorId: ', sensorId
        	# 1D fields:
	        T2 = ncfile.variables['T2'][0]
        	Pressure = ncfile.variables['PSFC'][0]
	        PBLH = ncfile.variables['PBLH'][0]
	        HGT = ncfile.variables['HGT'][0]
	        RAINNC = ncfile.variables['RAINNC'][0]
	        SNOWNC = ncfile.variables['SNOWNC'][0]
	        GRAUPELNC = ncfile.variables['GRAUPELNC'][0]
	        HAILNC = ncfile.variables['HAILNC'][0]
	        Precipitation = RAINNC + SNOWNC + GRAUPELNC + HAILNC
	        # 3D fields:
	        T = ncfile.variables['T'][0]
	        P = ncfile.variables['P'][0]
	        PB = ncfile.variables['PB'][0]
	        PHB = ncfile.variables['PHB'][0]
	        PH = ncfile.variables['PH'][0]
	        QVAPOR = ncfile.variables['QVAPOR'][0]

		# Import 1D fields
                press = Pressure[i0][j0]/100.
                heigth = HGT[i0][j0]
                zhd = (0.0022768*(float(press)))/(1.-0.00266*np.cos(2*(float(z0))*(3.1416/180.))-(0.00028*(float(heigth))/1000.))
                # zhd = zenith hydrostatic delay
                pblh = PBLH[i0][j0]
                temp = T2[i0][j0]-t_kelvin
                rain = Precipitation[i0][j0]
                print('Name: {0} [{1}, {2}, {3}] -> [Temperarture [C]: {4}, Pressure [hPa]: {5}, Rain [mm]: {6}, PBL HEIGHT [m]: {7}, Zenit Heigth Delay [x]: {8}] '
                      .format(station['name'],
                              x0,
                              y0,
                              z0,
                              temp,
                              press,
                              rain,
                              pblh,
                              zhd))

		# A list of the parameters calculated from the one-dimensional SUADA tables:
		onedim = [date,temp,press,heigth,sensorId,y0,x0,zhd,pblh,rain]

		# 3D table calculations:
		bottom_top = len(T)
                # First, calculation of tk:
		# Rd, Cp, Rd_Cp are used for 3D calculation of tk (absolute temperature [K], and then it's converted to [C]):
                Rd  = 287.0
		Cp  = 7.0 * Rd / 2.0
		Rd_Cp  = Rd / Cp # dimensionless
                for k in range(0, bottom_top):
			theta = T[k][i0][j0] + 300. # [K]
			Pair = (P[k][i0][j0] + PB[k][i0][j0])/100. # Press3D = Pair/100.0 [hPa]
                        # P is perturbation pressure; PB is base state pressure
			tk  = theta * (( 100.*Pair/100000. )**(Rd_Cp)) - t_kelvin # (... - t_kelvin) converts T to Celsius.
                        # (100.*Pair) is again in [Pa], because in the formula for tk it should be in [Pa].
			QV = QVAPOR[k][i0][j0] # water vapour mixing ratio
                    	hgth = (PH[k][i0][j0] + PHB[k][i0][j0])/9.8

			# A list of the parameters calculated from the three-dimensional SUADA tables:
                        threedim = [date,tk,Pair,sensorId,y0,x0,hgth,QV,k]


		# Insert values of parameters in txt format:
		with open('troposinex.txt', 'w') as troposinex:
			troposinex.write(onedim)
#			for line in troposinex:
#				onedim.append(line)
#			troposinex.seek(0)
#			troposinex.truncate()
#			troposinex.write("".join(content))
			troposinex.close()


	except Exception as e:
		sys.stderr.write('Error occured in process_station_tro: {error}'.format(error = repr(e)))
	finally:
		return result



# Define a procedure that exports the accumulated data into txt format:
#def tropo_out(station, ncfile, date):
#	result = True
#	try:
#		# Insert values of parameters in txt format:
#		with open('troposinex.txt', 'r+') as troposinex:
#			for line in troposinex:
#				onedim.append(line)
#			troposinex.seek(0)
#			troposinex.truncate()
#			troposinex.write("".join(content))
#			troposinex.close
#
#	except Exception as e: 
#		sys.stderr.write('Error occured in tropo_out: {error}'.format(error = repr(e)))
#	finally:
#		return result



# Define the main procedure:
def main(argv):
	# Optional for the user to specify are the following parameters:
	# -b <basedir>
	# -p <prefix>
	# -c <country> - the country in which all stations will be iterated through.
	# (If not specified - the script iterates through all countries.)
	# Mandatory for the user to specify are the following:
	# -s <source_name> - each user has a specific source_name that he/she should know
	# (if not, see Instructions, point 7).
	# -d <env> - the environment in which the data from the WRF model is going to be stored.
	# -o <output> - either insert data into database or export it to txt fomrat.
	basedir='./'
	prefix='wrfout_d02'
	source_name = ''
	country = 'All' # By default: 'All'. Possible options are 'BG', 'GR', ...
	env = '' # possible options are 'dev' and 'prod'.
	output = 'db' # By default: 'db'. Possible options: 'db', 'tro'.  
	instrument_name = 'GNSS'
	
	try:
		opts, args = getopt.getopt(argv,"h:b:p:s:c:d:o",["basedir=","prefix=","source_name=","country=","env=","output="])
	except getopt.GetoptError:
		print 'ncdf2db.py -b <basedir> ['+basedir+'] -p <prefix> ['+prefix+'] -s <source_name> ['+str(source_name)+'] -c <country> ['+str(country)+'] -d <env> ['+str(env)+'] -o <output> ['+output+']'
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			print 'ncdf2db.py -b <basedir> ['+basedir+'] -p <prefix> ['+prefix+'] -s <source_name> ['+str(source_name)+'] -c <country> ['+str(country)+'] -d <env> ['+str(env)+'] -o <output> ['+str(output)+']'
			sys.exit()
		elif opt in ("-b", "--basedir"):
			basedir = arg
		elif opt in ("-p", "--prefix"):
			prefix = arg
		elif opt in ("-s", "--source_name"):
			source_name = str(arg)
		elif opt in ("-c", "--country"):
			if country:
				country = str(arg)
			else:
				country = 'All'
		elif opt in ("-d", "--env"):
			env = str(arg)
		elif opt in ("-o", "--output"):
			if output:
				output = str(output)
			else:
				output = 'db'

	# Check whether the user has specified source name. If not -> Error.
	if source_name == '':
		print 'Error: You must specify the source name! (-s <source_name>)'
		sys.exit()

	# Check whether the user has specified the database. If not -> Error.
	if env == '':
		print 'Error: You must specify the database! (-d <env>)'
		sys.exit()

	# Retrieve the list of all data files
	# starting with [prefix] inside [basedir] folder
	flist = listfiles(basedir, prefix)

	# Create the DB connection:
	db = None
	cur = None
	try:
		if env == 'dev':
			print('DB -> {}'.format(cfg.dev['db']))
			db = MySQLdb.connect(host=cfg.dev['host'], \
				user=cfg.dev['user'], \
				passwd=cfg.dev['passwd'], \
				db=cfg.dev['db'])
		elif env == 'prod':
			print('DB -> {}'.format(cfg.prod['db']))
			db = MySQLdb.connect(host=cfg.prod['host'], \
				user=cfg.prod['user'], \
				passwd=cfg.prod['passwd'], \
				db=cfg.prod['db'])
		elif env != {'dev','prod'}:
			print 'Error: No such database! (Possible options for -d <env> are "dev" and "prod".)'
			sys.exit()
		cur = db.cursor()
	except Exception as e:
		print('Failed to establish connection: {0}'.format(e))
		cur.close()
		sys.exit(1)

	# Fetching source_id...
	print('Trying to fetch the source_id ...')
	source_id = get_source_id(cur, source_name)
	if source_id < 0:
		print 'Error: Can not find source_id for source_name: {}'.format(source_name)
		sys.exit(1)

	print('Source id: {} found for source name: {}'.format(source_id, source_name))

	# Call the procedure that selects the stations' information from the SUADA information tables:
	# (The SUADA information tables are: INSTRUMENT, STATION, COORDINATE, SENSOR and SOURCE.)
	print('Get stations')
	stations = getstations(cur, source_name, country, instrument_name)

	# Now iterating over list of all data files:
	print('Iterate files')

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
		truelat1 = ncfile.TRUELAT1
		truelat2 = ncfile.TRUELAT2
		ref_lat  = ncfile.CEN_LAT
		ref_lon  = ncfile.CEN_LON
		stand_lon= ncfile.STAND_LON
		dx = ncfile.DX
		dy = ncfile.DY
		west_east = ncfile.getncattr('WEST-EAST_GRID_DIMENSION')
		south_north = ncfile.getncattr('SOUTH-NORTH_GRID_DIMENSION')

		# Empty list to contain data:
		data = []
		for station in stations:
			stationName = station['name']
			stationId = station['id']
			sensorId = station['senid']
			print 'Station: ', station['name'], ' ID: ', station['id'], ' sensorId: ', sensorId, 'Country Code: ', station['country']
			x0 = station['long']
			y0 = station['latt']
			z0 = station['alt']
			indx = wrf.ll_to_ij(1, truelat1, truelat2, stand_lon, dx, dy, ref_lat, ref_lon, y0, x0)
			j0 = west_east / 2 + indx[0] - 1
			i0 = south_north / 2 + indx[1] - 1
			station['i0'] = i0
			station['j0'] = j0

			if (i0 >= 0 and i0 <= south_north) and ( j0 >= 0 and j0 <= south_north) \
				and ( (country == 'All') \
				or (country == station['country']) ):
					try:
						if output == 'db':
							process_station(db, cur, station, ncfile, date)
						elif output == 'tro':
							process_station_tro(station, ncfile, date)
						elif output != {'db','tro'}:
							print 'Error: Not a possible output! (Possible options for -o <output> are "db" and "tro".)'
							sys.exit()
					except Exception as e:	
						print ('Error in output - Failed to process stations: {0}'.format(e))
						sys.exit(1)

	if not(len(flist)):
		print 'No candidates for import files found ...'
		sys.exit(1)

if __name__ == "__main__":
	main(sys.argv[1:])
