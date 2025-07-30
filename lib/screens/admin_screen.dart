import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/bluetooth_service.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  bool _isConnecting = false;
  String _connectionStatus = 'Desconectado';

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  Future<void> _initializeBluetooth() async {
    await _requestPermissions();
    _connectToDevice();
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    if (!allGranted) {
      setState(() {
        _connectionStatus = 'Permisos denegados';
      });
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permisos requeridos'),
        content: Text(
          'Esta aplicación necesita permisos de Bluetooth y ubicación para conectarse al sensor ESP32.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Configuración'),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToDevice() async {
    setState(() {
      _isConnecting = true;
      _connectionStatus = 'Conectando...';
    });

    try {
      bool connected = await _bluetoothService.connect();
      setState(() {
        _isConnecting = false;
        _connectionStatus = connected ? 'Conectado - Recibiendo datos' : 'Error al conectar';
      });

      if (!connected) {
        _showConnectionError();
      }
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _connectionStatus = 'Error: $e';
      });
    }
  }

  void _showConnectionError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error de conexión'),
        content: Text(
          'No se pudo encontrar el dispositivo "SensorESP32-Team Daniel".\n\n'
          'Asegúrate de que:\n'
          '• El ESP32 esté encendido\n'
          '• El Bluetooth esté activado\n'
          '• El dispositivo esté cerca',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _connectToDevice();
            },
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bluetoothService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Lecturas en vivo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado de Conexión',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _bluetoothService.isConnected
                                ? Colors.green
                                : _isConnecting
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(child: Text(_connectionStatus)),
                        if (_isConnecting)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Dispositivo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Nombre: SensorESP32-Team Daniel'),
                    Text('Servicio UUID: 4fafc201-1fb5-459e-8fcc-c5c9c331914b'),
                    Text('Característica UUID: beb5483e-36e1-4688-b7f5-ea07361b26a8'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            if (!_bluetoothService.isConnected && !_isConnecting)
              ElevatedButton(
                onPressed: _connectToDevice,
                child: Text('Reconectar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _bluetoothService.isConnected
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth_disabled,
                      size: 64,
                      color: _bluetoothService.isConnected
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _bluetoothService.isConnected
                          ? 'Recibiendo datos del ESP32...\nLos datos se guardan automáticamente en Firebase'
                          : 'Esperando conexión con ESP32',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
