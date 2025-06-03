import 'package:flutter/material.dart';
import '../utils/redis_controller.dart';

var titlestyle = TextStyle(color: Colors.black,fontSize: 18,fontWeight:FontWeight.bold);
var datastyle = TextStyle(color: Colors.black,fontSize: 25,fontWeight:FontWeight.bold);
var datatitlesstyle = TextStyle(color: Colors.black,fontSize: 10,fontWeight:FontWeight.normal);

class LoginPage extends StatefulWidget{
  const LoginPage({super.key, required this.redsObject, required this.loginCallback});
  final RedisController redsObject;
  final Function loginCallback;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController redisServerController = TextEditingController();

    return Scaffold(
      body:PopScope(canPop: false,child:Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Minimal IRL Stream',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 30),
                )),
            SizedBox(height:20),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 20),
                )),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: redisServerController,
                  onChanged: (newText) {
                if (newText.contains("https://")){
                  redisServerController.text = newText.replaceRange(newText.indexOf("https://"), newText.indexOf("https://") + "https://".length, "");
                } 
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Redis Server',
                ),
              ),
            ),           
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User Name',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            SizedBox(height:20),
            Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton(
                  onPressed: () {widget.redsObject.login(passwordController.text,usernameController.text,redisServerController.text,widget.loginCallback);},
                  child: const Text('Login')
                )
            )]
    )
    )
    ));
  }
}




