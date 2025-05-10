import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../utils/ble_controller.dart';
import 'dart:typed_data';
import 'dart:async';
import '../ui/style.dart';
import '../ui/components.dart';

class DataPage extends StatefulWidget{
  const DataPage({super.key,required this.bleObject });
  final BleController bleObject;
  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  var steps = 0;
  var distance = 0;
  var mesuring = false;
  var battery = 0;
  late Timer t1;
  late Timer t2;
  late Timer t3;

  bool btlistloading = false;
  List<int> heartRateBuffer = [];
  int heartRate = 0;
  
  var scannedDevices = [];
  var lastConectedDevice = {"name":"","mac":"","status":""};

  bool scanDevicesFlag = false;
  
  @override
  void initState() {
    super.initState();
    widget.bleObject.initializeCallbacks(setDeviceStatus,bleNotify);
  }

  @override
  void dispose() {
    t1.cancel();
    t2.cancel();
    t3.cancel();
    super.dispose();
  }

  void changeDataPageState(s){
    setState(() {
      scanDevicesFlag = s;
    });
  }

  void onScanPressed() async {
    print("scanpressed");

    var scan = await widget.bleObject.scanDevices();
    print(scan);
    setState((){scannedDevices = scan;});
  }

  @override
  Widget build(BuildContext context) {
    return scanDevicesFlag?  scanScaffold():werableScaffold();
  }


Widget bluetoothScanList(){
if (!btlistloading){
    return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: scannedDevices.length,
            itemBuilder: (BuildContext context,int index){return bluetoothitem("${scannedDevices[index].advertisementData.advName}","${scannedDevices[index].device.remoteId}");}
            );
}else{
    return Text("LOADING...");
}

}

Scaffold scanScaffold(){
  return Scaffold(
      body: Center(
      child: Column (
      children: [
            SizedBox(
            height:500,
            child: bluetoothScanList(),
            ),
            ElevatedButton(
            style: ThemeButton.raisedButtonStyle,
            onPressed: () { onScanPressed();},
            child: Text('Scan Devices'),
            ),
            Text("Last Connected Device: ${lastConectedDevice["name"]}"), 
            Text("Status: ${lastConectedDevice["status"]} ")
            ]
        )),
      floatingActionButton: FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: (){changeDataPageState(false);},
      backgroundColor: Colors.orangeAccent,
      child: const Icon(Icons.analytics_outlined) 
      )
    );
}

Card loadingCard(loadingmessage){
  return Card(child: ListTile(
            title: Text(loadingmessage)));
}

void setDeviceStatus(bool conectedFlag,BluetoothDevice device){
setState(() { 
              lastConectedDevice["name"] = device.advName;
              lastConectedDevice["mac"] = device.remoteId.toString();
              if (conectedFlag){
                lastConectedDevice["status"] = "Connected";
              }else{
                lastConectedDevice["status"] = "Disconnected";
              }
              });
}

int getMedianOfList(List<int> mList){
     //clone list
    List<int> clonedList = [];
    clonedList.addAll(mList);

    //sort list
    clonedList.sort((a, b) => a.compareTo(b));

    int median;

    int middle = clonedList.length ~/ 2;
    if (clonedList.length % 2 == 1) {
      median = clonedList[middle];
    } else {
      median = ((clonedList[middle - 1] + clonedList[middle]) / 2.0).round();
    }

    return median;
}

int fromBytesToInt32(int b3, int b2, int b1, int b0) {
  Uint8List bytes = Uint8List.fromList([b3,b2,b1,b0]);
  Int16List words = Int16List.sublistView(bytes);
  return words.buffer.asByteData().getInt32(0);
}


void processActivity(stepslist,distancelist){
  var stepsValue = fromBytesToInt32(0x00, stepslist[0], stepslist[1], stepslist[2]);
  var distanceValue = fromBytesToInt32(0x00, distancelist[0], distancelist[1], distancelist[2]);
  //print("Activity");
  //print(steps_value);
  //print(distance_value);
  setState(() {
    steps = stepsValue;
    distance = distanceValue;
  });
}


void processHeartRate(value){
  //print(value);
  //print(heartRateBuffer);
  if (heartRateBuffer.length < 5){
    if (value > 0){
      heartRateBuffer.add(value);
    }
    if (value == 0){
      heartRateBuffer = [];
    }
  }else{
    if (value > 0){
      heartRateBuffer.add(value);
    }
    setState((){
    heartRate = getMedianOfList(heartRateBuffer);
    });
  }
}

void processBatteryCharge(value){
  if (value > 100){
    value = 100;
  }
  battery = value;
}

void bleNotify(List<int> bytelist){
  List<int> intlist = bytelist.toList();

  if (intlist[0] == 105){
    processHeartRate(intlist[3]);
  }
  if (intlist[0] == 72){
    processActivity([intlist[1],intlist[2],intlist[3]],[intlist[10],intlist[11],intlist[12]]);
  }
  if (intlist[0] == 03){
    processBatteryCharge(intlist[1]);
  }
}

Card bluetoothitem (devicename,devicemac){  
  var device =  widget.bleObject.getDevice(devicemac);

   return Card(
            child: ListTile(
            title: Text(devicename),
            subtitle: Text(devicemac),
            trailing: Icon(Icons.speaker_phone_outlined),
            onTap: () {widget.bleObject.conectToDevice(device);},
            ));
}

void stopMesuring(){
  setState(() {
    mesuring = false;
  });
}

void startMesuring(){
    setState(() {
      mesuring = true;
    });
    t1 = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mesuring) {
        // cancel the timer
        timer.cancel();
      }
      widget.bleObject.ringGetActivity();
    });
    t2 = Timer.periodic(const Duration(seconds: 120), (Timer timer) {
      if (!mesuring) {
        // cancel the timer
        timer.cancel();
      }
      widget.bleObject.ringGetHeartRate();
    });
    t3 = Timer.periodic(const Duration(seconds: 300), (Timer timer) {
      if (!mesuring) {
        // cancel the timer
        timer.cancel();
      }
      widget.bleObject.ringGetBattery();
    });
}

Scaffold werableScaffold(){
return Scaffold(
      body:Column(
        children: 
        [
          SizedBox(height:20),
          Center(child: Text('Ring Data',style: ThemeText.titlestyle)),
          SizedBox(height:20),
          SizedBox(
          height:300,
          child: Expanded(
          child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: 1.5, 
          children: <Widget>[
            datacell("Steps taken",steps,Icons.directions_walk),
            datacell("Distance",distance,Icons.east),
            datacell("HeartRate",heartRate,Icons.monitor_heart_outlined),
            datacell("Battery",battery,Icons.battery_charging_full),
          ],
          ))),
          wideButton(mesurementButtonText(),(){ if (mesuring){stopMesuring();}else{startMesuring();}} )
        ]
      ),
      floatingActionButton: FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: (){changeDataPageState(true);},
      backgroundColor: Colors.orangeAccent,
      child: const Icon(Icons.bluetooth_searching_outlined) 
      )
    );
}

  String mesurementButtonText(){
    if (mesuring){
      return 'Stop Mesuring';
      }else{
      return 'Start Mesuring';
      }
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
    Text(datatitle,style: ThemeText.datatitlesstyle),
    Icon(icon),
    Text(data.toString(),style: ThemeText.datastyle)
    ]
  ),
  );

  }

}


