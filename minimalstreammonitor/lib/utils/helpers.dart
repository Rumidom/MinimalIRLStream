
int getCurrentTimestamp(){
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  return timestamp ~/ 1000;
}

String getCurrentTimestampStr(){
  String strTimestamp = getCurrentTimestamp().toString();
  return strTimestamp;
}



