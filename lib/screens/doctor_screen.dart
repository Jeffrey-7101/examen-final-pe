import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/device_data.dart';
import 'device_detail_screen.dart';

class DoctorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Monitoreo de Oxígeno', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => context.read<AuthService>().signOut(),
          ),
        ],
        elevation: 2,
      ),
      body: StreamBuilder<List<DeviceData>>(
        stream: DatabaseService().readingsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return Center(
              child: Text(
                'No hay registros disponibles',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }
          final list = snap.data!;
          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(Duration(milliseconds: 500));
            },
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: list.length,
              separatorBuilder: (_, __) => SizedBox(height: 8),
              itemBuilder: (_, i) {
                final r = list[i];
                // Formateo manual de timestamp
                final ts = r.timestamp.toLocal();
                final day   = ts.day.toString().padLeft(2, '0');
                final month = ts.month.toString().padLeft(2, '0');
                final year  = ts.year.toString();
                final hour  = ts.hour.toString().padLeft(2, '0');
                final min   = ts.minute.toString().padLeft(2, '0');
                final formattedTime = '$day/$month/$year – $hour:$min';

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    leading: Icon(Icons.monitor_heart, color: primary, size: 36),
                    title: Text(
                      r.nombre,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Oxígeno: ${r.valor.toStringAsFixed(1)}%', style: TextStyle(fontSize: 16)),
                          SizedBox(height: 4),
                          Text(formattedTime, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    // NAVEGACIÓN al detalle
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeviceDetailScreen(data: r),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
