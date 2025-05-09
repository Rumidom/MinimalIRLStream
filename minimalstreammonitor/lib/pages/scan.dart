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

class ScanDevicesPage extends StatefulWidget{
  const ScanDevicesPage({super.key, required this.bleObject,required this.changeDataPageState});
  final Function(bool state) changeDataPageState;
  final BleController bleObject;

  @override
  State<ScanDevicesPage> createState() => _ScanDevicesPageState();
}

class _ScanDevicesPageState extends State<ScanDevicesPage> {
  var scannedDevices = [];

  void onScanPressed() async {
    print("scanpressed");
    var scan = await widget.bleObject.scanDevices();

    print(scan);
    setState((){scannedDevices = scan;});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
      children: [
            ElevatedButton(
            style: raisedButtonStyle,
            onPressed: () { onScanPressed();},
            child: Text('Scan BlueTooth'),
            )]
        ),
      floatingActionButton: FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: widget.changeDataPageState(false),
      backgroundColor: Colors.amberAccent,
      child: const Icon(Icons.analytics_outlined) 
      )
    );
  }
}




