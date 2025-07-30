import 'package:firebase_database/firebase_database.dart';
import '../models/device_data.dart';

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Rama con el estado actual de cada dispositivo
  DatabaseReference get _currentRef => _db.child('current_devices');

  /// Rama para guardar el historial de lecturas
  DatabaseReference get _historyRef => _db.child('history');

  /// Normaliza el nombre para usarlo como clave en RTDB
  String _sanitizeDeviceName(String name) =>
      name.replaceAll(RegExp(r'[.#$\[\]/]'), '').replaceAll(' ', '');

  /// Actualiza el estado actual del dispositivo y guarda en historial
  Future<void> updateCurrentDevice(DeviceData r) async {
    final key = _sanitizeDeviceName(r.nombre);
    final data = {
      'nombre_device': r.nombre,
      'valor': r.valor,
      'timestamp': r.timestamp.toIso8601String(),
      'last_updated': ServerValue.timestamp,
    };

    // 1) Estado actual
    await _currentRef.child(key).set(data);

    // 2) Historial (opcional)
    await _historyRef.child(key).push().set({
      'valor': r.valor,
      'timestamp': r.timestamp.toIso8601String(),
      'last_updated': ServerValue.timestamp,
    });
  }

  /// Alias legacy
  Future<void> addReading(DeviceData r) => updateCurrentDevice(r);

  /// Stream con todos los dispositivos actuales, ordenados por timestamp descendente
  Stream<List<DeviceData>> readingsStream() {
    return _currentRef.onValue.map((event) {
      final map = event.snapshot.value as Map<dynamic, dynamic>?;
      if (map == null) return [];

      final list = map.entries.map((e) {
        final m = e.value as Map<dynamic, dynamic>;
        return DeviceData(
          nombre: m['nombre_device'] as String,
          valor: (m['valor'] as num).toDouble(),
          timestamp: DateTime.parse(m['timestamp'] as String),
        );
      }).toList();

      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  /// Stream con las últimas 20 lecturas de historial, ordenadas descendente
  Stream<List<DeviceData>> historyStream() {
    return _historyRef
        .orderByChild('timestamp')
        .limitToLast(20)
        .onValue
        .map((event) {
      final map = event.snapshot.value as Map<dynamic, dynamic>?;
      if (map == null) return [];

      final list = map.entries.map((e) {
        final m = e.value as Map<dynamic, dynamic>;
        return DeviceData(
          nombre: m['nombre_device'] as String,
          valor: (m['valor'] as num).toDouble(),
          timestamp: DateTime.parse(m['timestamp'] as String),
        );
      }).toList();

      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  /// Stream con el estado actual de un dispositivo específico
  Stream<DeviceData?> getCurrentDeviceStream(String deviceName) {
    final key = _sanitizeDeviceName(deviceName);
    return _currentRef.child(key).onValue.map((event) {
      final m = event.snapshot.value as Map<dynamic, dynamic>?;
      if (m == null) return null;

      return DeviceData(
        nombre: m['nombre_device'] as String,
        valor: (m['valor'] as num).toDouble(),
        timestamp: DateTime.parse(m['timestamp'] as String),
      );
    });
  }
}
