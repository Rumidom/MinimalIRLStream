import 'package:flutter/material.dart';
import '../utils/ble_controller.dart';
import '../utils/redis_controller.dart';
import 'camera.dart';
import 'stream.dart';
import 'data.dart';
import 'login.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

var titlestyle = TextStyle(color: Colors.black,fontSize: 18,fontWeight:FontWeight.bold);

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});
  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;
  bool loggedIn = false;
  bool screenLock = false;
  Color opacitycolor = Colors.black;
  IconData screenStateIcon = Icons.add_to_home_screen;
  var bluetoothObject = BleController();
  var redisObject = RedisController();

  late List<Widget> widgetOptions = [
    DataPage(bleObject:bluetoothObject,redsObject:redisObject),
    StreamPage(redsObject:redisObject),
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
    body:AbsorbPointer( absorbing: screenLock,child:ColorFiltered(  
    colorFilter: ColorFilter.mode(
    opacitycolor, // Apply a black tint with 50% opacity
    BlendMode.srcATop, // Use 'srcATop' blend mode
    ), 
    child:IndexedStack( index: _selectedIndex,children: widgetOptions ))),
    bottomNavigationBar: AbsorbPointer( absorbing: screenLock, child: ColorFiltered(
    colorFilter: ColorFilter.mode(
    opacitycolor, // Apply a black tint with 50% opacity
    BlendMode.srcATop, // Use 'srcATop' blend mode
    ), 
    child: BottomNavigationBar(
    elevation: 10,
    currentIndex: _selectedIndex,
    onTap: onTabTapped,
    items: [
    BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined),label: "Data"),
    BottomNavigationBarItem(icon: Icon(Icons.cast_outlined),label: "Stream"),
    BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined),label: "Camera"),
  ]),

  )));
  }

void onTabTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
}
void toggleScreenLock(){
  if (screenLock){
    setState((){
    screenLock = false;
    screenStateIcon = Icons.app_blocking;
    });
    WakelockPlus.disable();
    opacitycolor = Colors.transparent;
    print("wakelock disabled");
  }else{
    setState((){
    screenLock = true;
    screenStateIcon = Icons.add_to_home_screen;
    });
    
    WakelockPlus.enable();
    opacitycolor = Colors.black54;
    print("wakelock enabled");
  }
}

  AppBar appbar_() {
    return AppBar(
      title: Text('Minimal Stream Monitor',style: titlestyle),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 10,
      leading: IconButton(
        alignment: Alignment.center,
        onPressed: () {},
        icon: Icon(Icons.exit_to_app)
      ),  actions: [
      IconButton(
        alignment: Alignment.center,
        onPressed: (){toggleScreenLock();},
        icon: Icon(screenStateIcon )),
      ],
    );
  }
}