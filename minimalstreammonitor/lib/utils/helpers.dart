

int getCurrentTimestamp(){
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  String strTimestamp = timestamp.toString();
  return int.parse(strTimestamp.substring(0, strTimestamp.length - 3));
}