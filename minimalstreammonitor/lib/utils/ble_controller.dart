import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleController {
  bool deviceInMemory = false;
  late BluetoothDevice lastConectedDevice;
  late BluetoothService lastConectedDeviceService;
  late BluetoothCharacteristic lastConectedDeviceWriteCharacteristic;
  late BluetoothCharacteristic lastConectedDeviceNotifyCharacteristic;
  late Function ntCallback;
  late Function conStCallback;

  BleController(){
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  }

  void initializeCallbacks(Function ntCback,Function cstCback){
    ntCallback = ntCback;
    conStCallback = cstCback;
  }

  Future<List> scanDevices() async {
    List scanResults = [];
    // listen to scan results
    // Note: `onScanResults` clears the results between scans. You should use
    //  `scanResults` if you want the current scan results *or* the results from the previous scan.
    var subscription = FlutterBluePlus.onScanResults.listen((results) {
          if (results.isNotEmpty) {
            ScanResult r = results.last; // the most recently found device
            print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
            scanResults.add(r);
          }
        },
        onError: (e) => print(e),
    );

    // cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(subscription);
    // Wait for Bluetooth enabled & permission granted
    // In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
    await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on).first;
    // Start scanning w/ timeout
    // Optional: use `stopScan()` as an alternative to timeout
    await FlutterBluePlus.startScan(timeout: Duration(seconds:15));
    // wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first;

    return scanResults;
  }

  BluetoothDevice getDevice(remoteId){
    var device = BluetoothDevice.fromId(remoteId);
    
    return device;
  }

  String getlastConectedDeviceStatus(){
    if (lastConectedDevice.isConnected){
      return "Connected";
    }else{
      return "Desconnected";
    }
  }

 Future<void> conectToDevice(BluetoothDevice device) async {

    // listen for disconnection
  var subscription = device.connectionState.listen((BluetoothConnectionState state) async {
      
      if (state == BluetoothConnectionState.disconnected) {
          // 1. typically, start a periodic timer that tries to 
          //    reconnect, or just call connect() again right now
          // 2. you must always re-discover services after disconnection!
          print("${device.disconnectReason?.code} ${device.disconnectReason?.description}");
          conStCallback(false);
      }
  });

  // cleanup: cancel subscription when disconnected
  //   - [delayed] This option is only meant for `connectionState` subscriptions.  
  //     When `true`, we cancel after a small delay. This ensures the `connectionState` 
  //     listener receives the `disconnected` event.
  //   - [next] if true, the the stream will be canceled only on the *next* disconnection,
  //     not the current disconnection. This is useful if you setup your subscriptions
  //     before you connect.
  device.cancelWhenDisconnected(subscription, delayed:true, next:true);

  // Connect to the device
  await device.connect();

  // Disconnect from device
  // await device.disconnect();

  // cancel to prevent duplicate listeners
  // subscription.cancel();
  lastConectedDevice = device;
  deviceInMemory = true;
  conStCallback(true);

  // Note: You must call discoverServices after every re-connection! rly tho?
  List<BluetoothService> services = await device.discoverServices();
  for (BluetoothService service in services){
    if (service.uuid == Guid('6e40fff0-b5a3-f393-e0a9-e50e24dcca9e')){
      lastConectedDeviceService = service;
      break;
    }
  }

  for(BluetoothCharacteristic c in lastConectedDeviceService.characteristics) {
    if (c.properties.write) {
      lastConectedDeviceWriteCharacteristic = c;
      print(c);
      print("Setting Ring Date & Time");
      await ringSetDateTime();
      print("Setting Auto Ring mesurements to Off");
      await ringSetAutoMesurementsOff();
    }else if (c.properties.notify){
      lastConectedDeviceNotifyCharacteristic = c;
      await characteristicSubscribe(device,lastConectedDeviceNotifyCharacteristic,ntCallback);
      print(c);
    }
  }
}

Future<void> characteristicSubscribe(BluetoothDevice device,BluetoothCharacteristic characteristic,Function callback) async{
  final subscription = characteristic.onValueReceived.listen((value) {
      // onValueReceived is updated:
      //   - anytime read() is called
      //   - anytime a notification arrives (if subscribed)
      callback(value);
  });

  // cleanup: cancel subscription when disconnected
  device.cancelWhenDisconnected(subscription);

  // subscribe
  // Note: If a characteristic supports both **notifications** and **indications**,
  // it will default to **notifications**. This matches how CoreBluetooth works on iOS.
  await characteristic.setNotifyValue(true);
}

  Future<void> connectLastDevice() async{
    if (!lastConectedDevice.isConnected){
      await conectToDevice(lastConectedDevice);
    }
  }

 Future<void> ringGetBattery() async {
  await connectLastDevice();
  BluetoothCharacteristic c = lastConectedDeviceWriteCharacteristic;
  await c.write([0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03]);
  }
  
 Future<void> ringGetActivity() async {
  await connectLastDevice();
  BluetoothCharacteristic c = lastConectedDeviceWriteCharacteristic;
  await c.write([0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x48]);
 }

 Future<void> ringGetHeartRate() async {
  await connectLastDevice();
  BluetoothCharacteristic c = lastConectedDeviceWriteCharacteristic;
  await c.write([0x69, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6A]);
 }

 Future<void> ringBlink() async {
  await connectLastDevice();
  BluetoothCharacteristic c = lastConectedDeviceWriteCharacteristic;
  await c.write([0x50, 0x55, 0xAA, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4F]);
 }

Future<void> ringSetAutoMesurementsOff() async {
  await connectLastDevice();
  BluetoothCharacteristic c = lastConectedDeviceWriteCharacteristic;
  print("disabling all automatic mesurements");
  await c.write([0x16, 0x02, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1A]);
  await c.write([0x2c, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2E]);
  await c.write([0x38, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3A]);
 }


Future<void> ringSetDateTime() async {
await connectLastDevice();
BluetoothCharacteristic c = lastConectedDeviceWriteCharacteristic;
List<int> payload = List.filled(16, 0);

DateTime now = DateTime.now();
print(payload);
payload[0] = 1;
payload[1] = byteToBcd(now.year % 2000); //year % 2000
payload[2] = byteToBcd(now.month);
payload[3] = byteToBcd(now.day);
payload[4] = byteToBcd(now.hour);
payload[5] = byteToBcd(now.minute);
payload[6] = byteToBcd(now.second);
payload[7] = 1;
payload[payload.length-1] = checksum(payload);
print('payload');
print(payload);
await c.write(payload);
}

int checksum(List byteslist){
  int sum = 0;
  for (int e in byteslist) {sum += e;}
  return sum % 255;
}

int byteToBcd(int b){
    int tens = b ~/ 10;
    int ones = b % 10;
    return (tens << 4) | ones;
}



}