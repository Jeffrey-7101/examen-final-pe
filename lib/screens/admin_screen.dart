import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../services/bluetooth_service.dart';
import '../services/auth_service.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  bool _isConnecting = false;
  bool _isConnected = false;
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
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    final allGranted = statuses.values.every((s) => s.isGranted);
    if (!allGranted) {
      setState(() => _connectionStatus = 'Permisos denegados');
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Permisos requeridos'),
        content: Text(
          'Esta aplicación necesita permisos de Bluetooth y ubicación\n'
          'para conectarse al sensor ESP32.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
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
      _connectionStatus = 'Conectando…';
    });

    try {
      final connected = await _bluetoothService.connect();
      setState(() {
        _isConnecting = false;
        _isConnected = connected;
        _connectionStatus = connected
            ? 'Conectado – Recibiendo datos'
            : 'Error al conectar';
      });
      if (!connected) _showConnectionError();
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
      builder: (_) => AlertDialog(
        title: Text('Error de conexión'),
        content: Text(
          'No se encontró "SensorESP32".\n\n'
          '• Asegúrate de que el ESP32 esté encendido\n'
          '• Bluetooth activado\n'
          '• Estén cerca el uno del otro',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
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
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Admin – Monitoreo en Vivo'),
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => context.read<AuthService>().signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Estado de Conexión
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isConnected
                              ? Colors.green
                              : _isConnecting
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _connectionStatus,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (_isConnecting)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
              ),

              // Información del dispositivo
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sensor ESP32',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.memory, size: 20, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Service UUID: 4fafc201‑1fb5‑459e‑8fcc‑c5c9c331914b')),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.extension, size: 20, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Char UUID: beb5483e‑36e1‑4688‑b7f5‑ea07361b26a8')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Botón Reconectar
              if (!_isConnected && !_isConnecting) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.refresh),
                    label: Text('Reconectar'),
                    onPressed: _connectToDevice,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],

              // Estado Visual
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                        size: 72,
                        color: _isConnected ? primary : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isConnected
                            ? 'Recibiendo datos del ESP32…\nGuardando automáticamente en RTDB'
                            : 'Esperando conexión con ESP32',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
