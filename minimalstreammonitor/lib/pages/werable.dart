import 'package:flutter/material.dart';
import '../utils/ble_controller.dart';

var titlestyle = TextStyle(color: Colors.black,fontSize: 18,fontWeight:FontWeight.bold);
var datastyle = TextStyle(color: Colors.black,fontSize: 25,fontWeight:FontWeight.bold);
var datatitlesstyle = TextStyle(color: Colors.black,fontSize: 10,fontWeight:FontWeight.normal);


class WerableDataPage extends StatefulWidget{
  const WerableDataPage({super.key, required this.bleObject,required this.changeDataPageState});
  final Function(bool state) changeDataPageState;
  final BleController bleObject;

  @override
  State<WerableDataPage> createState() => _WerableDataPageState();
}

class _WerableDataPageState extends State<WerableDataPage> {
  var ringsteps = 0;
  var Distance = 0;
  var HeartRate = 0;

  @override
  Widget build(BuildContext context) {
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
          )),
          Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: Colors.blueAccent,
              width: 1.0,
            ),
          ),
          ),
          SizedBox(
          height:300,
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: widget.changeDataPageState(true),
      backgroundColor: Colors.amberAccent,
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