import 'package:firebase_database/firebase_database.dart';
import '../models/device_data.dart';

class DatabaseService {
  final _devicesRef = FirebaseDatabase.instance.ref().child('devices');

  Future<void> addReading(DeviceData r) {
    return _devicesRef.push().set({
      'nombre_device': r.nombre,
      'valor': r.valor,
      'timestamp': r.timestamp.toIso8601String(),
    });
  }

  Stream<List<DeviceData>> readingsStream() {
    // Ordena por timestamp y toma los últimos 20
    return _devicesRef
      .orderByChild('timestamp')
      .limitToLast(20)
      .onValue
      .map((event) {
        final map = event.snapshot.value as Map<dynamic, dynamic>?; 
        if (map == null) return [];
        // Convertir cada hijo a DeviceData
        final list = map.entries.map((e) {
          final m = e.value as Map<dynamic, dynamic>;
          return DeviceData(
            nombre: m['nombre_device'] as String,
            valor: (m['valor'] as num).toDouble(),
            timestamp: DateTime.parse(m['timestamp'] as String),
          );
        }).toList();
        // Como limitToLast ordena ascendentemente, invertimos para mostrar del más nuevo al más viejo
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return list;
      });
  }
}
