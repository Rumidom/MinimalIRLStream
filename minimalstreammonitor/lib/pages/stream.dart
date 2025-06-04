import 'package:flutter/material.dart';
import '../ui/components.dart';
import '../ui/style.dart';
import '../utils/redis_controller.dart';

class StreamPage extends StatefulWidget{
  const StreamPage({super.key,required this.redsObject});
  final RedisController redsObject;

  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  bool streamingServerStatus = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column(
        children: [
          SizedBox(height:20),
          
          
          RichText(
          text: TextSpan(
          children: [
              TextSpan(
                text: "Streaming Server ",
                style: ThemeText.titlestyle,
              ),
              WidgetSpan(
                child:  streamingServerStatus ? Icon(Icons.brightness_1_rounded, size: 20,color: Colors.green,): Icon(Icons.brightness_1_rounded , size: 20,color: Colors.grey,)
              )
            ],
          ),
          ),
          Center(child: Text('Controls',style: ThemeText.titlestyle)),
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
