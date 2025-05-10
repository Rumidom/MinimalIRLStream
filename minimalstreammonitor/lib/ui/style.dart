import 'package:flutter/material.dart';

abstract class ThemeText{
static const titlestyle = TextStyle(color: Colors.black,fontSize: 18,fontWeight:FontWeight.bold);
static const datastyle = TextStyle(color: Colors.black,fontSize: 25,fontWeight:FontWeight.bold);
static const datatitlesstyle = TextStyle(color: Colors.black,fontSize: 10,fontWeight:FontWeight.normal);
static const buttontextstyle = TextStyle(color: Colors.white,fontSize: 15,fontWeight:FontWeight.normal);
}

abstract class ThemeButton{
static final raisedButtonStyle = ElevatedButton.styleFrom(
  foregroundColor: Colors.black87,
  backgroundColor: Colors.grey[300],
  minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(2)),
  )
);

}