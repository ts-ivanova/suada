import MySQLdb
import databaseconfig as cfg


#Create DB connection
print('DB -> {}'.format(cfg.prod['db']))

#create DB connection
db = None
cur = None
try:
   db = MySQLdb.connect(host=cfg.prod['host'], user=cfg.prod['user'], passwd=cfg.prod['passwd'], db=cfg.prod['db'])
   cur = db.cursor()
except Exception as e:
  print('Failed to establish connection: {0}'.format(e))
  sys.exit(1)

cur.execute("select st.ID, st.Name, crd.Longitude, crd.Latitude, crd.Altitude from COORDINATE as crd left join STATION as st ON crd.StationID = st.ID where crd.InstrumentID = 1 and st.Country = 'BG';")

stations = []
rows =  cur.fetchall()
if len(rows):
  for row in rows:
	stations.append({'id':row[0], 'name':row[1], 'long':row[2], 'latt':row[3], 'alt':row[4]})

for station in stations:
  print('Station name: {0}: Long: {1}, Latt: {2}, Alti: {3}'.format(station['name'], station['long'], station['latt'], station['alt']))
