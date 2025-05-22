import 'package:flutter/material.dart';
import '../ui/components.dart';
import '../ui/style.dart';
import '../utils/redis_controller.dart';

class StreamPage extends StatelessWidget{
  const StreamPage({super.key,required this.redsObject});
  final RedisController redsObject;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column(
        children: [
          SizedBox(height:20),
          Center(child: Text('Controls',style: ThemeText.titlestyle)),
          wideButton("Logout",(){redsObject.disconnect();}),
          wideButton("Send Checkpoint",(){}),
          Container(
          width: double.infinity,
          margin:EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
          decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'Enter message')
          )),
          wideButton("Send Message",(){}),
          Center(child: Text('Messages',style: ThemeText.titlestyle)),
          ]
        ),
    );
  }



} 
