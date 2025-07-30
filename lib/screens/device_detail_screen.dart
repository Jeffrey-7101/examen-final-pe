import 'package:flutter/material.dart';
import '../models/device_data.dart';

class DeviceDetailScreen extends StatelessWidget {
  final DeviceData data;

  const DeviceDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final ts = data.timestamp.toLocal();
    final day   = ts.day.toString().padLeft(2, '0');
    final month = ts.month.toString().padLeft(2, '0');
    final year  = ts.year.toString();
    final hour  = ts.hour.toString().padLeft(2, '0');
    final min   = ts.minute.toString().padLeft(2, '0');
    final formattedTime = '$day/$month/$year  $hour:$min';

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de ${data.nombre}'),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Tarjeta Dispositivo
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.devices, color: primary),
                title: Text(
                  'Dispositivo',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(data.nombre),
              ),
            ),

            // Tarjeta Nivel de Oxígeno
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.monitor_heart, size: 48, color: primary),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nivel de Oxígeno',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${data.valor.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Tarjeta Timestamp
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.access_time, color: Colors.grey[700]),
                title: Text(
                  'Última actualización',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(formattedTime),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
