import 'package:flutter/material.dart';


var titlestyle = TextStyle(color: Colors.black,fontSize: 18,fontWeight:FontWeight.bold);
var datastyle = TextStyle(color: Colors.black,fontSize: 25,fontWeight:FontWeight.bold);
var datatitlesstyle = TextStyle(color: Colors.black,fontSize: 10,fontWeight:FontWeight.normal);

class DataPage extends StatefulWidget{
  const DataPage({super.key });
  
  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
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
            datacell("Steps taken",3000,Icons.directions_walk),
            datacell("Distance",400,Icons.east),
            datacell("HeartRate",100,Icons.monitor_heart_outlined),
            datacell("accelerometer",200,Icons.multiple_stop_sharp),
          ],
          )),
        ]
      ),
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