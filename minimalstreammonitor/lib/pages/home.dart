import 'package:flutter/material.dart';
import '../utils/ble_controller.dart';
import '../utils/redis_controller.dart';
import 'camera.dart';
import 'stream.dart';
import 'data.dart';
import 'login.dart';

var titlestyle = TextStyle(color: Colors.black,fontSize: 18,fontWeight:FontWeight.bold);

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});
  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;
  bool loggedIn = false;
  var bluetoothObject = BleController();
  var redisObject = RedisController();

  late List<Widget> widgetOptions = [
    DataPage(bleObject:bluetoothObject,redsObject:redisObject),
    StreamPage(),
    CameraPage(redsObject:redisObject)
  ];

  void loginFunc(loginResp){
    setState(() {
    loggedIn = loginResp;
    });
  }
  @override
  Widget build(BuildContext context) {
    return loggedIn ? appPagesScaffold() : LoginPage(redsObject: redisObject,loginCallback:loginFunc); 
  }


  Scaffold appPagesScaffold() {
    return Scaffold(
    appBar:appbar_(),
    body:IndexedStack( index: _selectedIndex,children: widgetOptions ),
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