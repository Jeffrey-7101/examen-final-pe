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
      nombre: json['nombre_device'],
      valor: (json['valor'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
