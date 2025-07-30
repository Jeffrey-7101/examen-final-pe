class DeviceData {
  final String nombre;
  final double valor;
  final DateTime timestamp;

  DeviceData({
    required this.nombre,
    required this.valor,
    required this.timestamp,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      nombre: json['nombre_device'] ?? 'SensorESP32',
      valor: (json['valor'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre_device': nombre,
      'valor': valor,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
