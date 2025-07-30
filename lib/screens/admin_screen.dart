import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  //final bt = BluetoothService();

  @override
  void initState() {
    super.initState();
    //bt.connect();
  }

  @override
  void dispose() {
    //bt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin - Lecturas en vivo')),
      body: Center(child: Text('Recibiendo datos y guardando en Firebase...')),
    );
  }
}
