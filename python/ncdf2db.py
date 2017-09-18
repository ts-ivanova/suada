import sys, getopt
import glob
from tzlocal import get_localzone
from dateutil import parser
import datetime
from netCDF4 import Dataset as netcdf
import MySQLdb
import databaseconfig as cfg
import math

def listfiles(basedir, prefix):
  files = []
  try:
    for file in sorted(glob.glob(basedir+'/'+prefix+"*")):
      files.append(file)
  except Exception as e:
    print('Exception reading basefolder {} {}'.format(basedir,e))
  return files


def main(argv):
  basedir='./'
  prefix='wrfout_d02'
  field = None

  try:
    opts, args = getopt.getopt(argv,"h:b:p:f:",["basedir=","prefix=","field="])
  except getopt.GetoptError:
    print 'ncdf2db.py -b <basedir> ['+basedir+'] -p <prefix> ['+prefix+'] -f <field> [None] '
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
      print 'ncdf2db.py -b <basedir> ['+basedir+'] -p <prefix> ['+prefix+'] -f <field> [None]'
      sys.exit()
    elif opt in ("-b", "--basedir"):
      basedir = arg
    elif opt in ("-f", "--field"):
      field = arg
    elif opt in ("-p", "--prefix"):
      prefix = arg

  #Check wheter [field] is supplied
  if (field == None):
    print "2D field is not supplied."
    sys.exit(1)

  #Retrieve the list of all data files
  #starting with [prefix] inside [basedir] folder
  flist = listfiles(basedir, prefix)

  #Create DB connection
  print('DB -> {}'.format(cfg.dev['db']))
  #create DB connection
  db = None
  cur = None
  try:
#    db = MySQLdb.connect(host=cfg.dev['host'], user=cfg.dev['user'], passwd=cfg.dev['passwd'], db=cfg.dev['db'])
#    cur = db.cursor()
    pass
  except Exception as e:
    print('Failed to establish connection: {0}'.format(e))
    sys.exit(1)

  #Iterate over list of all data files
  for file in flist:
    field2D = []
    print 'Processing: ', file

    ncfile = netcdf(file)
    strDateTime = ncfile.variables['Times'][0].tostring().replace('_', ' ')
    local_tz = get_localzone()
    date = parser.parse(strDateTime)
    strDateTimeLocal = local_tz.localize(date)
    #Print the timestamp
    print('Dataset timestamp: {}'.format(strDateTimeLocal))
    xlong = ncfile.variables['XLONG'][0]
    xlat = ncfile.variables['XLAT'][0]
    T2 = ncfile.variables['T2'][0]

    south_north = len(xlong)
    west_east = len(xlong[0])

    #print('dump: {0} x {1}'.format(len(xlong), len(xlong[0])))
    #print('xlat:  ({0})'.format(xlat[0][0]))
    #print('T2:    ({0})'.format(T2[0][0]))
    #print('xlong: ({0})'.format(xlong[0][0]))

    #print('xlat:  ({0})'.format(xlat[0][1]))
    #print('T2:    ({0})'.format(T2[0][1]))
    #print('xlong: ({0})'.format(xlong[0][1]))
    #x0 =
    #y0 =
    rmin = math.sqrt(x0-(xlong[0][0])**2+(y0-xlat[0][0])**2)
    i0=0
    j0=0
    for i in range(0, south_north - 1):
      for j in range(0, west_east - 1):
        x = xlong[i][j]
        y = xlat[i][j]
        r = math.sqrt((x0-x)*(x0-x)+(y0-y)**2)
        if (r < rmin):
          rmin = r
          i0 = i
          j0 = j
  if not(len(flist)):
    print 'No candidates for impot files found ...'
    sys.exit(1)

if __name__ == "__main__":
   main(sys.argv[1:])
