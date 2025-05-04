import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


var titlestyle = TextStyle(color: Colors.black,fontSize: 18,fontWeight:FontWeight.bold);
var datastyle = TextStyle(color: Colors.black,fontSize: 25,fontWeight:FontWeight.bold);
var datatitlesstyle = TextStyle(color: Colors.black,fontSize: 10,fontWeight:FontWeight.normal);

class CameraPage extends StatefulWidget{
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final imagePicker = ImagePicker();
  File? imageFile;

  takePicture() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column(
        children: [
          SizedBox(height:40),
          Center(
                  child: imageFile != null
                  ? Image.file(imageFile!)
                  : Image.asset('assets/images/CameraPlaceholder.png')
          ),
        ]),
        
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: takePicture,
        backgroundColor: Colors.amberAccent,
        child: const Icon(Icons.camera_alt_outlined) 
      )
    );
  }
}