import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/bluetooth_service.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

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
          'Esta app necesita Bluetooth y ubicación para conectarse al sensor.',
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
          'No se encontró "SensorESP32-Team Daniel".\n\n'
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
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => context.read<AuthService>().signOut(),
          ),
        ],
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Estado de la conexión
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Indicador luminoso
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

              const SizedBox(height: 20),

              // Información del dispositivo
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 2,
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
                      Row(children: [
                        Icon(Icons.memory, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Service UUID: 4fafc201‑1fb5‑459e‑8fcc‑c5c9c331914b')),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.extension, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Char UUID: beb5483e‑36e1‑4688‑b7f5‑ea07361b26a8')),
                      ]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón de reconexión
              if (!_isConnected && !_isConnecting)
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

              const SizedBox(height: 32),

              // Ilustración de estado
              Expanded(
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
            ],
          ),
        ),
      ),
    );
  }
}
