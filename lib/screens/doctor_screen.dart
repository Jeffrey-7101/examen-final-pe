import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/device_data.dart';

class DoctorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Doctor - Últimos registros')),
      body: StreamBuilder<List<DeviceData>>(
        stream: DatabaseService().readingsStream(),
        builder: (context, snap) {
          if (!snap.hasData) return Center(child: CircularProgressIndicator());
          final list = snap.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final r = list[i];
              return ListTile(
                title: Text(r.nombre),
                subtitle: Text('Valor: ${r.valor}% • ${r.timestamp.toLocal()}'),
              );
            },
          );
        },
      ),
    );
  }
}
