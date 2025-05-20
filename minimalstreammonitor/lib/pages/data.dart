//import 'dart:collection';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../utils/ble_controller.dart';
import '../ui/style.dart';
import '../ui/components.dart';
import '../utils/redis_controller.dart';
import '../utils/helpers.dart';

class DataPage extends StatefulWidget{
  const DataPage({super.key,required this.bleObject, required this.redsObject});
  final BleController bleObject;
  final RedisController redsObject;
  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  int steps = 0;
  int distance = 0;
  var mesuring = false;
  int battery = 0;
  late Timer t1;
  late Timer t2;
  late Timer t3;
  int lastSentActivityTs = 0;
  int lastSentHeartrateTs = 0;
  int lastSentBatteryTs = 0;
  bool btlistloading = false;
  List<List> heartRateBuffer = [];
  int heartRate = 0;
  
  var scannedDevices = [];

  bool scanDevicesFlag = false;
  
  @override
  void initState() {
    super.initState();
    widget.bleObject.initializeCallbacks(bleNotify);
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
    setState((){
      btlistloading = true;
    });
    var scan = await widget.bleObject.scanDevices();
    setState((){
      scannedDevices = scan;
      btlistloading = false;
    });
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
    return LoadingAnimationWidget.threeRotatingDots(
        color: Colors.orangeAccent,
        size: 50,
      );
}

}

String getLastConnectedDeviceStatus(){
if (widget.bleObject.deviceInMemory){
  return widget.bleObject.getlastConectedDeviceStatus();
}else{
  return "";
}
}

String getDeviceStatus(){
if (widget.bleObject.deviceInMemory){
  return widget.bleObject.getlastConectedDeviceStatus();
}else{
  return "";
}
}

String getDeviceName(){
if (widget.bleObject.deviceInMemory){
  return widget.bleObject.lastConectedDevice.advName;
  }else{
  return "";
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
            wideButton('Scan Devices', (){onScanPressed();}),
            Text("Last Connected Device: ${getDeviceName()}"), 
            Text("Status: ${getDeviceStatus()}")
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


void processActivity(stepslist,distancelist) async{
  var tS = getCurrentTimestamp();
  var stepsValue = fromBytesToInt32(0x00, stepslist[0], stepslist[1], stepslist[2]);
  var distanceValue = fromBytesToInt32(0x00, distancelist[0], distancelist[1], distancelist[2]);
  if((mounted) && (tS-lastSentActivityTs>3)){
  lastSentActivityTs = tS;
  await widget.redsObject.pushWerableData("steps",'${tS.toString()},${steps.toString()}' );
  await widget.redsObject.pushWerableData("distance",'${tS.toString()},${distance.toString()}');
  setState((){
    steps = stepsValue;
    distance = distanceValue;
  });
  }

}


void processHeartRate(value)async{
  var tstamp = getCurrentTimestamp();
  //print(heartRateBuffer);
  if (heartRateBuffer.length < 8){
    if (value > 0){
      heartRateBuffer.add([value,tstamp]);
    }
    if (value == 0){
      heartRateBuffer = [];
    }
  }else{
    if (value > 0){
      heartRateBuffer.add([value,tstamp]);
    }
    if ((mounted)){
    List<int> values = getValuesFromTimeBuffer(heartRateBuffer);
    List<int>  tstamps = getTimesFromTimeBuffer(heartRateBuffer);
    int tS = getMedianOfList(tstamps);
    if (tS-lastSentHeartrateTs > 30){
    setState(() {
    heartRate = getMedianOfList(values);
    });
    print("Sending: ${heartRate.toString()}, time: ${tS.toString()}, dif: ${(tS-lastSentHeartrateTs).toString()}");
    await widget.redsObject.pushWerableData("heartrates",'${tS.toString()},${heartRate.toString()}');
    heartRateBuffer = [];
    lastSentHeartrateTs = tS;
    }
    }
  }
}

List<int> getValuesFromTimeBuffer(List<List> buffer){
  List<int> values = [];
  for (var item in buffer){
    values.add(item[0]);
  }
  return values;
}

List<int> getTimesFromTimeBuffer(List<List> buffer){
  List<int> times = [];
  for (var item in buffer){
    times.add(item[1]);
  }
  return times;
}

void processBatteryCharge(value)async{
  if (value > 100){
    value = 100;
  }
  var tS = getCurrentTimestamp();
  if (tS-lastSentBatteryTs>10){
  setState(() {battery = value;});
  lastSentBatteryTs = tS;
  await widget.redsObject.pushWerableData("batteryCharge",'${tS.toString()},${battery.toString()}');
  }
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
   return Card(
            child: ListTile(
            title: Text(devicename),
            subtitle: Text(devicemac),
            trailing: Icon(Icons.speaker_phone_outlined),
            onTap: (){conectToSelectedDevice(devicemac);}
            ));
}

void conectToSelectedDevice(devicemac) async {
var device =  widget.bleObject.getDevice(devicemac);
await widget.bleObject.conectToDevice(device);
setState(() {});
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
    t1 = makePeriodicTimer(const Duration(seconds: 300),  (Timer timer) {
      if (!mesuring) {
        // cancel the timer
        timer.cancel();
      }
      widget.bleObject.ringGetBattery();
    },fireNow: true);

    t2 = makePeriodicTimer(const Duration(seconds: 120),  (Timer timer) {
      if (!mesuring) {
        // cancel the timer
        timer.cancel();
      }
      widget.bleObject.ringGetHeartRate();
    },fireNow: true);

    t3 = makePeriodicTimer(const Duration(seconds: 5),  (Timer timer) {
      if (!mesuring) {
        // cancel the timer
        timer.cancel();
      }
      widget.bleObject.ringGetActivity();
    },fireNow: true);

}

Scaffold werableScaffold(){
return Scaffold(
      body:Column(
        children: 
        [
          SizedBox(height:20),
          Center(child: Text('Werable Data',style: ThemeText.titlestyle)),
          SizedBox(height:20),
          SizedBox(
          height:300,
          child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: 1.5, 
          children: <Widget>[
            datacell("Steps taken",steps,Icons.directions_walk),
            datacell("Distance",distance.toDouble()/1000,Icons.east),
            datacell("HeartRate",heartRate,Icons.monitor_heart_outlined),
            datacell("Battery",battery,Icons.battery_charging_full),
          ],
          )),
          wideButton(mesurementButtonText(),(){toggleMesurement();} )
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

  void toggleMesurement(){
  
  if (widget.bleObject.deviceInMemory){
    if (mesuring){
      stopMesuring();
    }else{
      startMesuring();
    }
  }else{
    toastmessage("device hasn't been conected yet");
  }

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


