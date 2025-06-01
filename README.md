# MinimalIRLStream
MinimalIRLStream is a way to IRL Stream with less mobile data. lowbandwith data such as heartrate, oxygen level, stepcount and position is sent from your phone and wearables to a cloud database from which a server or desktop composes that data into a video stream, this saves bandwith and is ideal for Outdoors activities Streams where high speed internet is not available.

<p align="center">
  <img src="https://github.com/Rumidom/MinimalIRLStream/blob/main/docs/minimal_stream_diagram.png" alt="How it works diagram"/>
</p>

# Walk on the beach (proof of concept)

https://github.com/user-attachments/assets/23ed73f2-22d6-491b-b28c-e596c1ad429c

video is sped up (frames are displayed at 1 FPS but were recived at longer variable intervals)
# Werable data
for this project I chose a colmi r10 smart ring, as it has been reversed engineered in other projects ( [GadgetBridge](https://codeberg.org/Freeyourgadget/Gadgetbridge/src/branch/master/app/src/main/java/nodomain/freeyourgadget/gadgetbridge/devices/colmi/) , [colmi r02 client](https://github.com/tahnok/colmi_r02_client/) ) and its data is easily acessible (not locked to manufacturer's APP), colmi has other smart rings that share the same or similar API and might also work with this project. I might add devices in the future. 

# Supported Werable devices:

### - Colmi R10 smart ring
Colmi R10 ring, seems accurate enough when compared with a hauwai band 8 (which acording to online reviews is fairly accurate)

# Tested werable acuraccy:  

| Colmi R10 Distance (km)| Actual distance (km)| Colmi R10 Steps | hauwei band 8 Steps  |   time   |   date   |
| ---------------------- | -------------------:| ---------------:| --------------------:|---------:|---------:|
|                   1.531|                 1.72|             1906|                 2085 |        20|  9/5/2025|
|                   1.218|                 1.59|             1873|                 1894 |        17| 10/5/2025|


<p align="center">
  <img src="https://github.com/Rumidom/MinimalIRLStream/blob/main/docs/Screenshot%20from%202025-05-22%2020-01-07.png" alt="Heartrate comparison"/>
</p>

# TODO

* [x] Retrive data from werable device (heartrate,steps,battery,distance)
* [x] Take pictures and send to cloud database
* [x] Queue data with timestamps on cloud database, to be consumed by the video streaming server
* [x] Retrive data/pictures from cloud database and assemble image on streaming server
* [ ] Generate and store video on streaming server
* [ ] Stream video directly from stream server to youtube
* [ ] Add map and live location

1FAA4 be my guest
