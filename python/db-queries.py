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

cur.execute("select st.ID, st.Name, crd.Longitude, crd.Latitude from COORDINATE as crd left join STATION as st ON crd.StationID = st.ID where crd.InstrumentID = 1;")

stations = []
rows =  cur.fetchall()
if len(rows):
  for row in rows:
	stations.append({'id':row[0], 'name':row[1], 'latt':row[2], 'long':row[3]})

for station in stations:
  print('{0}: {1}, {2}'.format(station['name'], station['latt'], station['long']))
