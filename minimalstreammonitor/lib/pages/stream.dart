import 'package:flutter/material.dart';

var titlestyle = TextStyle(color: Colors.black,fontSize: 18,fontWeight:FontWeight.bold);
var buttontextstyle = TextStyle(color: Colors.white,fontSize: 15,fontWeight:FontWeight.normal);
var datatitlesstyle = TextStyle(color: Colors.black,fontSize: 15,fontWeight:FontWeight.normal);

class StreamPage extends StatelessWidget{
  const StreamPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column(
        children: [
          SizedBox(height:20),
          Center(child: Text('Controls',style: titlestyle)),
          wideButton("Stop Stream"),
          wideButton("Log Checkpoint"),
          Container(
          width: double.infinity,
          margin:EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
          decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'Enter message')
          )),
          wideButton("Send Message"),
          Center(child: Text('Messages',style: titlestyle)),
          ]
        ),
    );
  }

  Container wideButton(text) {
    return Container(
        width: double.infinity,
        margin:EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          elevation: 5,
          shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // Set the desired radius
                 ),
        ),
        onPressed: () {},
        child: Text(text,style: buttontextstyle)));
  }

} 
