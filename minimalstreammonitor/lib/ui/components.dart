import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'style.dart';
import 'dart:async';

Timer makePeriodicTimer(
  Duration duration,
  void Function(Timer timer) callback, {
  bool fireNow = false,
}) {
  var timer = Timer.periodic(duration, callback);
  if (fireNow) {
    callback(timer);
  }
  return timer;
}

Container wideButton(text,callback) {
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
      onPressed: callback,
      child: Text(text,style: ThemeText.buttontextstyle)));
}

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