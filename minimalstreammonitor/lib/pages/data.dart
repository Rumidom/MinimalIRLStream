import 'package:flutter/material.dart';
import '../utils/ble_controller.dart';

var titlestyle = TextStyle(color: Colors.black,fontSize: 18,fontWeight:FontWeight.bold);
var datastyle = TextStyle(color: Colors.black,fontSize: 25,fontWeight:FontWeight.bold);
var datatitlesstyle = TextStyle(color: Colors.black,fontSize: 10,fontWeight:FontWeight.normal);
var raisedButtonStyle = ElevatedButton.styleFrom(
  foregroundColor: Colors.black87,
  backgroundColor: Colors.grey[300],
  minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2)),
  )
);

class DataPage extends StatefulWidget{
  const DataPage({super.key });
  
  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  var ringsteps = 0;
  var Distance = 0;
  var HeartRate = 0;
  var bleObject = BleController();
  var scannedDevices = [];

  bool scanDevicesFlag = false;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void changeDataPageState(s){
    setState(() {
      scanDevicesFlag = s;
    });
  }

  void onScanPressed() async {
    print("scanpressed");
    var scan = await bleObject.scanDevices();
    print(scan);
    setState((){scannedDevices = scan;});
  }

  @override
  Widget build(BuildContext context) {
    return scanDevicesFlag?  scanScaffold():werableScaffold();
  }

Scaffold scanScaffold(){
  return Scaffold(
      body: Center(
      child: Column (
      children: [
            SizedBox(
            height:500,
            child:
            ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: scannedDevices.length,
            itemBuilder: (BuildContext context,int index){return bluetoothitem("${scannedDevices[index].advertisementData.advName}","${scannedDevices[index].device.remoteId}");}
            ),
            ),
            ElevatedButton(
            style: raisedButtonStyle,
            onPressed: () { onScanPressed();},
            child: Text('Scan Devices'),
            )]
        )),
      floatingActionButton: FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: (){changeDataPageState(false);},
      backgroundColor: Colors.orangeAccent,
      child: const Icon(Icons.analytics_outlined) 
      )
    );
}

Card bluetoothitem (devicename,devicemac){  
   return Card(
            child: ListTile(
            title: Text(devicename),
            subtitle: Text(devicemac),
            trailing: Icon(Icons.broadcast_on_home)
            ));
}

Scaffold werableScaffold(){
return Scaffold(
      body:Column(
        children: 
        [
          SizedBox(height:20),
          Center(child: Text('Data',style: titlestyle)),
          SizedBox(height:20),
          Expanded(
          child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: 1.5, 
          children: <Widget>[
            datacell("Steps taken",ringsteps,Icons.directions_walk),
            datacell("Distance",Distance,Icons.east),
            datacell("HeartRate",HeartRate,Icons.monitor_heart_outlined),
            //datacell("accelerometer",200,Icons.multiple_stop_sharp),
          ],
          ))
        ]
      ),
      floatingActionButton: FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: (){changeDataPageState(true);},
      backgroundColor: Colors.orangeAccent
      ,
      child: const Icon(Icons.bluetooth_searching_outlined) 
      )
    );
}

  Container datacell(datatitle,data,icon) {
  return Container(
  margin: const EdgeInsets.symmetric(vertical:5,horizontal: 10),
  height: 20,
  decoration: BoxDecoration(
  border: Border.all(width: 2, color: Colors.blueGrey),
  borderRadius: BorderRadius.circular(15),
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    Text(datatitle,style: datatitlesstyle),
    Icon(icon),
    Text(data.toString(),style: datastyle)
    ]
  ),
  );

  }

}


