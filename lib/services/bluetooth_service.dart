// import 'dart:convert';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import '../models/device_data.dart';
// import 'database_service.dart';

// class BluetoothService {
//   BluetoothConnection? _connection;

//   Future<void> connect() async {
//     final device = (await FlutterBluetoothSerial.instance
//           .getBondedDevices())
//         .firstWhere((d) => d.name == 'SensorESP32');
//     _connection = await BluetoothConnection.toAddress(device.address);
//     _connection!.input!.listen((data) {
//       final jsonStr = utf8.decode(data).trim();
//       try {
//         final map = json.decode(jsonStr);
//         final reading = DeviceData.fromJson(map);
//         DatabaseService().addReading(reading);
//       } catch (e) {
//         print('Error parseando JSON: $e');
//       }
//     });
//   }

//   void dispose() {
//     _connection?.dispose();
//   }
// }
