import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'dart:convert';
import '../ui/style.dart';

class CameraPage extends StatefulWidget{
  const CameraPage({super.key, required this.getkeyfunc, required this.setMetaDatafunc});
  final  Future<String> Function()  getkeyfunc ;
  final  Future<String> Function(Map imData)  setMetaDatafunc ;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final imagePicker = ImagePicker();
  var imgbbKey = "";
  var lastUploadResp = {"timestamp":"","delete_url":"","url":""};
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
      imgbbKey = await widget.getkeyfunc();
    }
    if (imgfile != null){
      var uploadURL = "https://api.imgbb.com/1/upload";
      var uri = Uri.parse(uploadURL);
      String imgb64 = base64Encode(imgfile.readAsBytesSync());
      var payload = { 'key': imgbbKey,'image': imgb64};
      var response = await http.post(uri,body:payload);
      
      //print(response.body);

      if(response.statusCode == 200){
        toastmessage("image uploaded!");
        var responseJson = jsonDecode(response.body);

        setState(() {
        lastUploadResp["url"] = responseJson["data"]["url"];
        lastUploadResp["delete_url"] = responseJson["data"]["delete_url"];
        lastUploadResp["timestamp"] = responseJson["data"]["time"].toString();
        
        widget.setMetaDatafunc(lastUploadResp);
        });
        print(lastUploadResp);
        
      }else{
        toastmessage("error uploading image: ${response.statusCode}");
      }
    }else{
      toastmessage("no image to upload");
    }
  }

  String timestampToDate(int? secsSinceEpoch){
    if (secsSinceEpoch == null){
      return "";
    }
    var mSecsSinceEpoch = 1000* secsSinceEpoch;
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(mSecsSinceEpoch);
    return dateTime.toString();
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
        child: Text("Upload",style: ThemeText.buttontextstyle))),
        Text("Last upload: ${timestampToDate( int.tryParse(lastUploadResp["timestamp"] ?? "" ) )}")
        ]),
        
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: takePicture,
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.camera_alt_outlined) 
      )
    );
  }
}