#### Example usage

1. First download the necessery data in ```../data``` folder. Just use command:


```
curl -XGET "http://suada.phys.uni-sofia.bg/meteo/wrfout_d02_2017-08-29_18:00:00" -O wrfout_d02_2017-08-29_18:00:00
```

if you run this command on Physon cluster please instead use:

```
curl -XGET "http://10.1.1.220/meteo/wrfout_d02_2017-08-29_18:00:00" -O wrfout_d02_2017-08-29_18:00:00
```

2. You need foollowing additional modules installed on python environment:

* netCDF4
* tzlocal
* python-dateutil

You cna install them using ```pip``` with following commands:

```
pip install netCDF4
pip install tzlocal
pip install python-dateutil
```

In case you run the scripts on Physon cluster simply load the module ```python/2.7.13```

```
module load python/2.7.13
```

3. Then run ```ncdf2db.py``` script on data folder for T2 meteo field


```
python ncdf2db.py -b ../data/ -f T2

```
