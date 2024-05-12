import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BlueToothProvider extends ChangeNotifier{
  List<BluetoothService> _bluetoothService = [];

  List<BluetoothService> get connectedService => _bluetoothService;

  add(List<BluetoothService> bluetoothService){
    _bluetoothService = bluetoothService;
    notifyListeners();
  }
}