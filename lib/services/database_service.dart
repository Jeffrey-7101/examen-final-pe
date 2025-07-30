import 'package:firebase_database/firebase_database.dart';
import '../models/device_data.dart';

class DatabaseService {
  final _db = FirebaseDatabase.instance.ref();

  /// Referencia a la rama de dispositivos actuales
  DatabaseReference get _currentRef => _db.child('current_devices');

  /// Referencia a la rama de historial (opcional)
  DatabaseReference get _historyRef => _db.child('history');

  /// Actualiza el nodo de estado actual del dispositivo + guarda en historial
  Future<void> addReading(DeviceData r) async {
    final key = r.nombre; // ej. "SensorESP32-Team Daniel"
    final data = {
      'nombre_device': r.nombre,
      'valor': r.valor,
      'timestamp': r.timestamp.toIso8601String(),
      'last_updated': ServerValue.timestamp, 
    };

    // 1) Actualiza el estado actual
    await _currentRef.child(key).set(data);

    // 2) (Opcional) Guarda también en history/{deviceKey}/pushId
    await _historyRef.child(key).push().set({
      'valor': r.valor,
      'timestamp': r.timestamp.toIso8601String(),
    });
  }

  /// Escucha cambios en todos los dispositivos actuales
  Stream<List<DeviceData>> readingsStream() {
    return _currentRef.onValue.map((event) {
      final map = event.snapshot.value as Map<dynamic, dynamic>?;
      if (map == null) return [];

      // Cada entry.key es el nombre del dispositivo
      return map.entries.map((e) {
        final m = e.value as Map<dynamic, dynamic>;
        return DeviceData(
          nombre: m['nombre_device'] as String,
          valor: (m['valor'] as num).toDouble(),
          timestamp: DateTime.parse(m['timestamp'] as String),
        );
      }).toList()
        // Opcional: ordena del más reciente al más antiguo
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }
}
