* Script in testing to write data values at lat/lon (not using gr2stn - just
* nearest grid point) to a file.
*
*
* Set the list of Variables, and some name-mapping that I'll remember.
* Should be in a read-config file, but we shall throw it in here for now.

*var.1.1 = 'T2'
*var.1.2 = 'Surface Temperature [K]'

var.1.1 = 'tk'
var.1.2 = 'Temperature (K)'

*var.3.1 = 'PSFC'
*var.3.2 = 'Pressure [Pa]'
*var.3.1 = 'PSFC/100'

var.2.1 = 'pressure'
var.2.2 = 'Model pressure [hPa]'

var.3.1 = 'height'
var.3.2 = 'Model height [km]'
var.3.1 = 'height*1000'

*var.6.1 = 'HGT'
*var.6.2 = 'Terrain Height [m]'
*var.6.1 = 'HGT/1000'

var.4.1 = 'QVAPOR'
var.4.2 = 'Water vapor mixing ratio [kg kg-1]'
var.4.1 = 'QVAPOR*1000'

*var.10.1 = 'ZHD'
*var.10.2 = 'Zenith Hydrostatic Delay [m]'

NumVars = 4


* For now - pretend the grib file is open
*

'open extract.ctl'

* Read in the list of stations and the lat/lon and put into a some
* global variables

site = 1
while (1)
  result = read("Model_Stations.cfg")
  EOF = sublin(result,1)
  if (EOF = 2)
    break
  endif
  line2 = sublin(result,2)
  _name.site = subwrd(line2,1)
  _lat.site  = subwrd(line2,2) 
  _lon.site  = subwrd(line2,3)
  _id.site   = subwrd(line2,4)
** say "name is " _name.site ' ' _lat.site ' ' _lon.site
   site = site + 1
   
endwhile

_NumSites = site - 1

* Set the time to 1 and do an inquiry on the
* time.  We can use this to get the date/time
* of our data. Will be used in the name of
* the output file

'set t 1'
MyDTStamp = DateTimeStamp()
say "Date Time Stamp is " MyDTStamp

* Now get the time range of our data, as
* we want to loop through all time periods
* For now, user will just have to know what
* the time increment is

'q file'
MyLine    = sublin(result, 5)
ZNumber = subwrd(MyLine, 9)
TimeSteps = subwrd(MyLine, 12)


'set t 'TimeSteps
MyDTStampEnd = DateTimeStamp()
'set z 1 '1



* Loop through the sites and print out some values to
* a file.  For now, just one big file but it could
* just as easily be a seperate file for each station.
*
* For now, just hardcode the name of the variable that is
* desired.  I might make some more obvious names later as
* I'll want to use them in the GribViewer program

*MyFile = MyDTStamp".txt"
MyFile = "zLevels4stat_3Dv4.txt"
rc = write (MyFile, 'Model Run Start time: ' MyDTStamp '00 end time: ' MyDTStampEnd '00 number of steps: ' TimeSteps ' ZNumber: ' ZNumber)

'set gxout print'
'set prnopts %6.1f ' TimeSteps

MySite = 1
while (MySite <= _NumSites)
  say 'working on  '_name.MySite
  'set lat ' _lat.MySite
  'set lon ' _lon.MySite 
  rc = write(MyFile,'')
  rc = write (MyFile, 'Station: '_name.MySite' ' _lat.MySite ' ' _lon.MySite ' ' _id.MySite)

  MyVar = 1
  while (MyVar <= NumVars) 
         rc = write(MyFile, var.MyVar.2)
      
      zz=1
      while (zz <= ZNumber)
      'set z 'zz
      'set t 1 'TimeSteps

    
      'd ' var.MyVar.1 

    MyResult = sublin(result, 3)
    
    say MyResult
    rc = write (MyFile, MyResult)
    zz = zz+1
    endwhile

    MyVar = MyVar + 1
  endwhile
  rc = write(MyFile, "End")
  MySite = MySite + 1
endwhile







*-------------------------------------------------------------- 

function DateTimeStamp()

month.JAN = "01"
month.FEB = "02"
month.MAR = "03"
month.APR = "04"
month.MAY = "05"
month.JUN = "06"
month.JUL = "07"
month.AUG = "08"
month.SEP = "09"
month.OCT = "10"
month.NOV = "11"
month.DEC = "12"

  
'q dim'
rec = sublin(result,5)
time = subwrd(rec,6)

MyHour     = substr(time,1,2)
MyDay      = substr(time,4,2)
MyMonth    = substr(time,6,3)
MyYear     = substr(time,9,4)

NumMonth = month.MyMonth

return MyYear''NumMonth''MyDay''MyHour

*------------------------------------------------------------------

