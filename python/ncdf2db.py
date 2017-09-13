import sys, getopt
import glob
from tzlocal import get_localzone
from dateutil import parser
import datetime
from netCDF4 import Dataset as netcdf
import MySQLdb
import databaseconfig as cfg

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

  if not(len(flist)):
    print 'No candidates for impot files found ...'
    sys.exit(1)

if __name__ == "__main__":
   main(sys.argv[1:])

