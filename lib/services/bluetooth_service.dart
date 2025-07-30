import 'dart:convert';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import '../models/device_data.dart';
import 'database_service.dart';

class BluetoothService {
  static const String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  static const String TARGET_DEVICE_NAME = "SensorESP32-Team Daniel";

  fbp.BluetoothDevice? _connectedDevice;
  fbp.BluetoothCharacteristic? _targetCharacteristic;
  StreamSubscription? _characteristicSubscription;
  StreamSubscription? _scanSubscription;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<fbp.BluetoothDevice?> findTargetDevice() async {
    Completer<fbp.BluetoothDevice?> completer = Completer();
    bool found = false;

    // Listen to scan results
    _scanSubscription = fbp.FlutterBluePlus.scanResults.listen((results) {
      for (fbp.ScanResult result in results) {
        if (result.device.platformName == TARGET_DEVICE_NAME && !found) {
          found = true;
          fbp.FlutterBluePlus.stopScan();
          completer.complete(result.device);
          return;
        }
      }
    });

    // Start scanning
    await fbp.FlutterBluePlus.startScan(timeout: Duration(seconds:10));
    
    // Wait for timeout if device not found
    Timer(Duration(seconds: 10), () {
      if (!found) {
        fbp.FlutterBluePlus.stopScan();
        completer.complete(null);
      }
    });

    return completer.future;
  }

  Future<bool> connect() async {
    try {
      fbp.BluetoothDevice? device = await findTargetDevice();
      
      if (device == null) {
        print('Device $TARGET_DEVICE_NAME not found');
        return false;
      }

      print('Found device: ${device.platformName}');

      // Connect to the device
      await device.connect();
      _connectedDevice = device;
      _isConnected = true;

      print('Connected to device');

      // Discover services
      List<fbp.BluetoothService> services = await device.discoverServices();
      
      for (fbp.BluetoothService service in services) {
        String serviceUuid = service.serviceUuid.toString().toLowerCase();
        if (serviceUuid == SERVICE_UUID.toLowerCase()) {
          print('Found target service');
          
          for (fbp.BluetoothCharacteristic characteristic in service.characteristics) {
            String charUuid = characteristic.characteristicUuid.toString().toLowerCase();
            if (charUuid == CHARACTERISTIC_UUID.toLowerCase()) {
              _targetCharacteristic = characteristic;
              
              print('Found target characteristic');
              
              // Enable notifications
              await characteristic.setNotifyValue(true);
              
              // Listen to characteristic notifications
              _characteristicSubscription = characteristic.lastValueStream.listen((value) {
                _onDataReceived(value);
              });
              
              print('Connected to ESP32 and listening for data');
              return true;
            }
          }
        }
      }
      
      print('Target service or characteristic not found');
      await device.disconnect();
      _isConnected = false;
      return false;
      
    } catch (e) {
      print('Error connecting to device: $e');
      _isConnected = false;
      return false;
    }
  }

  void _onDataReceived(List<int> data) {
    try {
      final jsonStr = utf8.decode(data).trim();
      print('Received data: $jsonStr');
      
      final Map<String, dynamic> map = json.decode(jsonStr);
      final reading = DeviceData.fromJson(map);
      
      // Save to Firebase
      DatabaseService().addReading(reading);
      
    } catch (e) {
      print('Error parsing JSON: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      await _characteristicSubscription?.cancel();
      _characteristicSubscription = null;
      
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
      
      _connectedDevice = null;
      _targetCharacteristic = null;
      _isConnected = false;
      
      print('Disconnected from ESP32');
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  void dispose() {
    disconnect();
  }
}
