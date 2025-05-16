# MinimalIRLStream
MinimalIRLStream is a way to IRL Stream with less mobile data. lowbandwith data such as heartrate,oxygen level,stepcount and position is sent from your phone and wearables to a cloud database from which a server or desktop composes that data into a video stream, this saves bandwith and is ideal for Outdoors activities Streams where high speed internet is not available.

<p align="center">
  <img src="https://github.com/Rumidom/MinimalIRLStream/blob/main/docs/minimal_stream_diagram.png" alt="How it works diagram"/>
</p>

# Werable data
for this project I chose a colmi r10 smart ring, as it has been reversed engineered in other projects ( [GadgetBridge](https://codeberg.org/Freeyourgadget/Gadgetbridge/src/branch/master/app/src/main/java/nodomain/freeyourgadget/gadgetbridge/devices/colmi/) , [colmi r02 client](https://github.com/tahnok/colmi_r02_client/) ) and its data is easily acessible and not locked to manufacturer's APP, colmi has other smart rings that share the same API but are branded with diferent names that might also work with this project. I might add devices in the future. 

# Supported Werable devices:

### - Colmi R10 smart ring

# Tested werable acuraccy:  

| Colmi R10 Distance (km)| Actual distance (km)| Colmi R10 Steps | hauwei band 8 Steps  |   time   |   date   |
| ---------------------- | -------------------:| ---------------:| --------------------:|---------:|---------:|
|                   1.531|                 1.72|             1906|                 2085 |        20|  9/5/2025|
|                   1.218|                 1.59|             1873|                 1894 |        17| 10/5/2025|

# TODO

* [x] Retrive data from werable device (heartrate,steps,battery,distance)
* [x] Take pictures and send to cloud database
* [ ] Queue data with timestamps on cloud database, to be consumed by the video streaming server
* [ ] Retrive data/pictures from cloud database and assemble image on streaming server
* [ ] Generate and store video on streaming server
* [ ] Stream video directly from stream server to youtube
