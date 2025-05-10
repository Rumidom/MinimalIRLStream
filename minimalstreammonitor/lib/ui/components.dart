import 'package:flutter/material.dart';
import 'style.dart';


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
      child: Text(text,style: ThemeText.buttontextstyle)));
}