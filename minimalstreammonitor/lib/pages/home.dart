import 'package:flutter/material.dart';
import 'camera.dart';
import 'stream.dart';
import 'data.dart';
import 'login.dart';
import 'package:redis/redis.dart';
import 'package:fluttertoast/fluttertoast.dart';

var titlestyle = TextStyle(color: Colors.black,fontSize: 18,fontWeight:FontWeight.bold);

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});
  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;
  bool loggedIn = false;
  var redisConn = RedisConnection();
  var redisUsername = "";
  var redisServer = "";
  var redisPassword = "";

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

  void login(String password,String user,String rServ){
    try {
    redisConn.connect(rServ.split(':')[0], int.parse(rServ.split(':')[1])).then((Command command){
    command.send_object(["AUTH", user, password]).then((var response) {
        toastmessage("login succesful");
        setState(() {loggedIn = true;}); 
        redisUsername = user;
        redisServer = rServ;
        redisPassword = password;
      });
    });
    } catch (e) {
      toastmessage("login failed");
    }
  }

  Future<List> sendComands(rComandList) async { 
    var responseList = [];
    try {
      Command cmd = await redisConn.connect(redisServer.split(':')[0], int.parse(redisServer.split(':')[1]));
      var resp = await cmd.send_object(["AUTH", redisUsername, redisPassword]);
      print("authresp");
      print(resp);

      for (var rcmd in rComandList) {
        print(rcmd);
        var res = await cmd.send_object(rcmd);
          responseList.add(res);
          print(res);
      }
      return responseList;
    } catch(e) {
      toastmessage("connection failed");
      return responseList;
    }
  }

  Future<String> getbbimgKey() async{
    var returnlist = await sendComands([["GET","imgbbKey"]]);
    return returnlist[0];
  }

  Future<String> sendimgMetaData(Map imMetaDataJson) async{
    var imMD = imMetaDataJson;
    var returnlist = await sendComands([["HSET","imMetaDataJson","timestamp",imMD["timestamp"],"delete_url",imMD["delete_url"],"url",imMD["url"] ]]);
    return returnlist[0];
  }

  late List<Widget> widgetOptions = [
    DataPage(),
    StreamPage(),
    CameraPage(getkeyfunc: getbbimgKey,setMetaDatafunc:sendimgMetaData)
  ];

  @override
  Widget build(BuildContext context) {
    return loggedIn ? appPagesScaffold() : LoginPage(loginmethod: login); 
  }

  Scaffold appPagesScaffold() {
    return Scaffold(
  appBar:appbar_(),
  body:widgetOptions.elementAt(_selectedIndex),
  bottomNavigationBar: BottomNavigationBar(
    elevation: 10,
    currentIndex: _selectedIndex,
    onTap: onTabTapped,
    items: [
    BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined),label: "Data"),
    BottomNavigationBarItem(icon: Icon(Icons.cast_outlined),label: "Stream"),
    BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined),label: "Camera"),
  ]),
  );
  }

void onTabTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
}
  AppBar appbar_() {
    return AppBar(
      title: Text('Minimal Stream Monitor',style: titlestyle),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 10,
      leading: Container(
        margin:EdgeInsets.all(10),
        alignment: Alignment.center,
        child: Icon(Icons.menu),
      ),
    );
  }
}