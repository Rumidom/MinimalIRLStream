import 'package:redis/redis.dart';
import '../ui/components.dart';

class RedisController {
  var redisConn = RedisConnection();
  bool hasValidCredencials = false;
  var redisUsername = "";
  var redisServer = "";
  var redisPassword = "";

  RedisController();
  
  Future<void> login(String password,String user,String rServ,Function lgCallback) async{
    try {
    await redisConn.connect(rServ.split(':')[0], int.parse(rServ.split(':')[1])).then((Command command){
    command.send_object(["AUTH", user, password]).then((var response) {
        toastmessage("login succesful");
        redisUsername = user;
        redisServer = rServ;
        redisPassword = password;
        hasValidCredencials = true;
        lgCallback(true);
      });
    });
    } catch (e) {
      toastmessage("login failed");
      lgCallback(false);
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

  Future<String> sendImgMetaData(Map imMetaDataJson) async{
    var imMD = imMetaDataJson;
    var returnlist = await sendComands([["HSET","imMetaDataJson","timestamp",imMD["timestamp"],"delete_url",imMD["delete_url"],"url",imMD["url"] ]]);
    return returnlist[0];
  }
}