import 'package:redis/redis.dart';
import '../ui/components.dart';

class RedisController {
  var redisConn = RedisConnection();
  bool hasValidCredencials = false;
  var redisUsername = "";
  var redisServer = "";
  var redisPassword = "";
  late Function loginCallback;
  var dataQueueMaxlen = 100;
  late Command rediscmd;

  RedisController();
  
  Future<void> login(String password,String user,String rServ,Function lgCallback) async{
    try {
    loginCallback = lgCallback;
    rediscmd = await redisConn.connect(rServ.split(':')[0], int.parse(rServ.split(':')[1]));
    var resp = await rediscmd.send_object(["AUTH", user, password]);
    print('AUTH response $resp');
    if (resp == "OK"){
    toastmessage("login succesful");
    redisUsername = user;
    redisServer = rServ;
    redisPassword = password;
    hasValidCredencials = true;
    lgCallback(true);
    //rediscmd.get_connection().close();
    }else{
    toastmessage("login failed");
    lgCallback(false);
    }
    } catch (e) {
    print(e);
    toastmessage("login failed: $e");
    lgCallback(false);
    }

  }

  Future<List> sendComands(rComandList) async { 
    var responseList = [];
    try {

      for (var rcmd in rComandList) {
        print(rcmd);
        var res = await rediscmd.send_object(rcmd);
          responseList.add(res);
          print(res);
      }
      //cmd.get_connection().close();
      return responseList;
    } catch(e) {
      toastmessage("connection failed: $e");
      print("Redis Connection Failed");
      rediscmd.get_connection().close();
      print("Atempting Reconnect");
      await login(redisPassword,redisUsername,redisServer,loginCallback);
      return responseList;
    }
  }

  void disconnect(){
    rediscmd.get_connection().close();
  }
  // this could be more efficient <=
  Future<void> pushWerableData(key,data) async{
    print("pushing werable data: ${key} :${data}");
    var returnlist = await sendComands([["LPUSH",key,data],["LTRIM",key,0,dataQueueMaxlen-1]]);
    print(returnlist[0]);
    //return returnval;
  }

  Future<String> getbbimgKey() async{
    var returnlist = await sendComands([["GET","imgbbKey"]]);
    print(returnlist);
    return returnlist[0];
  }

  Future<String> sendImgMetaData(Map imMetaDataJson) async{
    var imMD = imMetaDataJson;
    var returnlist = await sendComands([["HSET","imMetaDataJson","timestamp",imMD["timestamp"],"delete_url",imMD["delete_url"],"url",imMD["url"] ]]);
    print(returnlist[0]);
    return returnlist[0];
  }
}