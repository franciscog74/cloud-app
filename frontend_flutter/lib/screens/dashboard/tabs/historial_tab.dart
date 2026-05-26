import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class HistorialTab extends StatelessWidget {
  final String tokenJWT; // Pedimos el token

  const HistorialTab({super.key, required this.tokenJWT});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService().obtenerGastos(tokenJWT), // Buscamos en AWS
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final lista = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Historial de Gastos", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              
              if (lista.isEmpty)
                const Center(child: Text("No hay movimientos que mostrar"))
              else
                // *PENDIENTE:tabla dinámica o un ListView con los datos de 'lista'
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Fecha')),
                      DataColumn(label: Text('Categoría')),
                      DataColumn(label: Text('Monto')),
                    ],
                    rows: lista.map((gasto) => DataRow(cells: [
                      DataCell(Text(gasto['fecha_registro'].toString().split('T')[0])),
                      DataCell(Text(gasto['categoria_nombre'] ?? 'N/A')),
                      DataCell(Text('\$${gasto['monto']}')),
                    ])).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}