#### Download the data file example

using curl:

1. If you download data file outside Physon cluster

```
curl -XGET "http://suada.phys.uni-sofia.bg/meteo/wrfout_d02_2017-08-29_18:00:00" -O wrfout_d02_2017-08-29_18:00:00
```

2. If you download data file on Physon cluster


```
curl -XGET "http://10.1.1.220/meteo/wrfout_d02_2017-08-29_18:00:00" -O wrfout_d02_2017-08-29_18:00:00
```
