README for the ncdf2db.py script 


Outline:
Section 1: Introduction to SUADA
Section 2: Description of the ncdf2db.py script
Section 3: MANUAL - Instructions for working on Physon
Section 4: Examples of testing the script



Section 1: Introduction to SUADA
http://suada.phys.uni-sofia.bg/
The Sofia University Atmospheric Data Archive (SUADA) serves as a regional database for atmospheric parameters, specifically for Integrated Water Vapour (IWV), derived using the Global Navigation Satellite Systems (GNSS) Meteorology method.




Section 2: Description of the ncdf2db.py script
This Python script is developed by Stoyan Pisov and Tsvetelina Ivanova from the Faculty of Physics, Sofia University “St. Kliment Ohridski”, 2017-2018.

The aim of this script in the project is to export the data from the WRF model that is stored in netCDF format to a SUADA database.

Basic information:

The user runs the script by typing in the terminal:
ncdf2db.py -b <basedir> [./] -p <prefix> [wrfout_d0] -s <source_name> [] -c <country> [All] -d <env> []

Mandatory for specification by the user are: source_name, env. 
Possible options for -d <env> are dev and prod.
Important! The dev database is a backup copy and is used for current tests and work. You should only use dev, and not prod !!!
Optional for specification by the user are: basedir, prefix, country, output. 

Default value for <basedir> is [./], for <prefix> is [wrfout_d02], 
for <source_name> is ‘ ’ (empty string), for <country> is [All], for <env> is ‘ ’ (empty string), and for <output> is ‘db’.
Important! The dev database is a backup copy and is used for current tests and work. You should only use dev, and not prod !!!

ncdf2db.py -b <basedir> [./] -p <prefix> [wrfout_d02] -s <source_name> [] -c <country> [bg] -d <env> []

See Section 3: MANUAL for more details on how to run the script.

The script consists of total 7 procedures.
A description of the components of the code is as follows:

In the first few lines a short description is provided (comments) and then the needed libraries are imported.
Global variables are defined for easier usage all across the code. (t_kelvin)
The first procedure is called getstations. Its purpose is to selects the stations' ID, Name, Longitude, Latitude, Altitude from the SUADA information tables.
The second procedure is called listfiles. Its purpose is to list files containing data in the selected (by the user) base directory and prefix.
The third procedure is called get_source_id. Its purpose is to take source_name as an argument and then return source_id as a result, which is later used when inserting into 1D and 3D databases.
The fourth procedure is called get_station_name. Its purpose is to take the country (that the user specified when running the script) as an argument and to return the station names in this country as a result.
The fifth procedure is called process_station. Its purpose is to insert the model data for particular station in the SUADA database.
The sixth procedure is called process_station_tro. Its purpose is to make a dictionary containing the data, so that it can be later on inserted into txt format. It is followed by another procedure tropo_out that exports the data in this dictionary into TROPOSINEX txt format.
The seventh procedure is called tropo_out. Its purpose is to export the data in the dictionary (generated in the process_station_tro procedure) into TROPOSINEX txt format.. For each run of the script, a new .txt file is going to be generated (with a timestamp).
The eighth procedure is the main procedure. Its purpose is to check whether the command that the user typed is correct (i.e. if they have specified -s <source_name> and -d <env>), then to retrieve the list of all data files starting with [prefix] inside [basedir] folder. Then to create a database connection; to fetch source_id by calling the procedure get_source_id; then call the procedure getstations that selects the stations' information from the SUADA information tables. (The SUADA information tables are: INSTRUMENT, STATION, COORDINATE, SENSOR and SOURCE.) Then to iterate through all stations that satisfy the conditions that the user specified and to obtain model data - values for the parameters (such as temperature [K], pressure [Pa], ZHD [m] and so on). Lastly, depending on the user’s choice on -o <output> (either -o db or -o tro), the process_station or process_station_tro procedure is called. The process_station procedure inserts the model data into a SUADA database. The process_station_tro generates a dictionary that will be exported to txt format.




Section 3: MANUAL - Instructions for working on Physon
http://physon.phys.uni-sofia.bg/

1. Open the terminal and type in the console:
	ssh -Y username@physon.phys.uni-sofia.bg
You will be requested to enter your password.


2. After a successful login, type 
	qlogin -l h_rt=4:0:0 
This means you will have a 4-hour long Interactive session.


3. The first time you perform the steps from these Instructions, you should choose a directory of your own in which you'd like to have the project cloned, and then type
	mkdir work/dev
This creates the directory for the project.
After that you can clone the project by typing this in the console:
           cd work/dev
	git clone https://github.com/tsveti-7/suada.git
This procedure is done only the first time.
After that, on every next session, it is enough to just go to the directory that you chose and type
	cd work/dev/suada
	git pull
This is performed in order to synchronize all changes on the project.

Here is a list of the SUADA project directories and files downloaded via git pull:
Files: .gitignore; README.md, modelf.m
Directory data/:
		Contains files: README.md - information on how to download data file.
Directory db/:
		Contains files: meteodb.pdf; meteodb.sql; suada_4.pdf; suada_4.sql
Directory python/:
		Contains directories and files:
			Files: databaseconfig.py; db-queries.py; ncdf2db.py; troposinex.txt; wrf.py 
			Directory txt2db/:
				Contains files: 1Dv4.py; 3Dv4.py; parse_1Dv4.gs; parse_3Dv4.gs; txt2db.py




4. Testing the ncdf2db.py script:
Type
	cd python
	module load python
Before you start the ncfd2db.py script, you must enter the DEV_SUADA password in the databaseconfig.py file, which is in the downloaded SUADA project via git pull.
More specifically, the databaseconfig.py contains:
prod  = {'host' : 'fs002',      'user': 'meteo', 'passwd': 'xxxx', 'db': 'meteodb'}
dev = {'host' : 'fs002', 'user': 'meteo', 'passwd': 'xxxx', 'db': 'suada_5'}


You should type the password instead of ‘xxxx’ for the databases and save the edited script.

Then, to run ncdf2db.py you could type in the console for example
python python/ncdf2db.py -b data/ -s WRF_Martin_Experiment -d dev -o db	 

-b means <basedir>, 
-p means <prefix>, 
-s means <source_name>, 
-c means <country>,
-d means <env> (database or working environment), 
-o means <output>.

Default value for:
 <basedir>		 is 	[./], 
<prefix>		 is 	[wrfout_d02], 
<source_name>	 is 	‘ ’ (empty string),
<country> 		 is 	[All], 
<env> 		 is 	‘ ’ (empty string), 
 <output> 		 is 	‘db’.


The user can specify in which country to iterate and write/update the fields in the database. If no country is specified, the script runs through all countries in the database and writes or updates the entries if changes have occurred.

Мandatory to specify both the source_name and env!
Possible options for -d <env> are dev and prod.
Important! The dev database is a backup copy and is used for current tests and work. You should only use dev, and not prod !!!
If you don’t know your source_name, see step 7.

Optional to specify are basedir, prefix, country, output.
Possible options for -o <output> are ‘db’ and ‘tro’. When -o db is specified, the model data is being inserted into the SUADA database. When -o tro is specified, the model data is being exported into TROPOSINEX txt format.

If you want to iterate through files in a different directory than ./ and/or if your files don't start with wrfout_d02 (they could start for example with wrfout_d01), you should type
	python ncdf2db.py -b ../optionaldirectory/sampledata/ -p wrfout_d01 -s <source_name> -d <env> -o <output>
The directory ../optionaldirectory/sampledata/ is the path where output data netcdf files from WRF model are stored.

Help:
           python ncdf2db.py --help

As an example in the project that you cloned from github, the 'data' folder should contain wrfout_d02_2017-08-29_18:00:00. It can be downloaded from following url: 
http://suada.phys.uni-sofia.bg/meteo/wrfout_d02_2017-08-29_18:00:00 
and can be downloaded using following command:
	curl -XGET "http://fe002/meteo/wrfout_d02_2017-08-29_18:00:00" -O wrfout_d02_2017-08-29_18:00:00
After performing this step, you will see the iterations through all stations in the database. This is to test and see that the script works. After it's finished, proceed to step 5 (optional).


5. (Optional) In order to browse through fields or explore the database, you can use MySQL. Type 
	mysql -u meteo -p -h fs002 suada_5
A password will be required, and you should know it. :)
After you've successfully logged in, you can search for what you want using MySQL commands such as 
SELECT something FROM table WHERE condition;

You can see what columns a particular table has by typing (for example)
SHOW COLUMNS FROM NWP_IN_3D;


6. MySQL is used for inserting and updating fields. Type again
	mysql -u meteo -p -h fs002 suada_5
A DEV_SUADA password is required.
After that, you can use the commands INSERT and UPDATE if you have a new entry to put into the database (and if you know where you should put it).


7. If you don’t know your source_name and source_id, you may want to type
	mysql -u meteo -p -h fs002 suada_5
A password will be required. Then type
SELECT * FROM SOURCE;
This way you will see all Names and Source IDs in this table and find yours.




Section 4: Examples of testing the script

If you want to insert data into the SUADA database, you should type -o db.
python python/ncdf2db.py -b data/ -s WRF_Martin_Experiment -d dev -o db

If you want to insert data into TROPOSINEX txt format, you should type -o tro.
(SINEX_TRO - Solution INdependent EXchange format for TROpospheric and meteorological parameters.)

python python/ncdf2db.py -b data/ -s WRF_Martin_Experiment -d dev -o tro
