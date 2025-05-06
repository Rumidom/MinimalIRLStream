import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'dart:convert';

var titlestyle = TextStyle(color: Colors.black,fontSize: 18,fontWeight:FontWeight.bold);
var datastyle = TextStyle(color: Colors.black,fontSize: 25,fontWeight:FontWeight.bold);
var datatitlesstyle = TextStyle(color: Colors.black,fontSize: 10,fontWeight:FontWeight.normal);
var buttontextstyle = TextStyle(color: Colors.white,fontSize: 15,fontWeight:FontWeight.normal);

class CameraPage extends StatefulWidget{
  const CameraPage({super.key,  this.getkeyfunc});
  final  Future<String> Function()?  getkeyfunc ;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final imagePicker = ImagePicker();
  var imgbbKey = "";
  File? imageFile;


  void toastmessage(String msg){
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.black,
      fontSize: 16.0
    );
  }

  void uploadImage(File? imgfile) async {
    if (imgbbKey == ""){
      imgbbKey = await widget.getkeyfunc!();
    }
    if (imgfile != null){
      var uploadURL = "https://api.imgbb.com/1/upload";
      var uri = Uri.parse(uploadURL);
      String imgb64 = base64Encode(imgfile.readAsBytesSync());
      var payload = { 'key': imgbbKey,'image': imgb64};
      var response = await http.post(uri,body:payload);
      print(response.body);
      if(response.statusCode == 200){
        toastmessage("image uploaded!");
      }else{
        toastmessage("error uploading image: ${response.statusCode}");
      }
    }else{
      toastmessage("no image to upload");
    }
  }

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
          SizedBox(
                  height:400,
                  child: imageFile != null
                  ? Image.file(imageFile!)
                  : Image.asset('assets/images/CameraPlaceholder.png')
          ),
          Container(
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
        onPressed: () {uploadImage(imageFile);},
        child: Text("Upload",style: buttontextstyle)))
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