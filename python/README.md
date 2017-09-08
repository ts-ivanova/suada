==Example usage==

1. First download the necessery data on ```../data``` folder. Just use command:


```
curl -XGET "http://suada.phys.uni-sofia.bg/meteo/wrfout_d02_2017-08-29_18:00:00" -o wrfout_d02_2017-08-29_18:00:00
```

2. Then run ```ncdf2db.py``` script on data folder for T2 meteo field


```
python ncdf2db.py -b ../data/ -f T2

```
