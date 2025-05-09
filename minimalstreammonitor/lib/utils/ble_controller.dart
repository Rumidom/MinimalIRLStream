import 'package:flutter_blue_plus/flutter_blue_plus.dart';


class BleController {

  BleController(){
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
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
}
