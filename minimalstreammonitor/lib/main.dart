import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      theme: ThemeData(fontFamily:'Poppins'),
      debugShowCheckedModeBanner: false,
      home: MainHomeScreen()
    );
  }
}