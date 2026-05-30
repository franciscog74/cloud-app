import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class HistorialTab extends StatelessWidget {
  final String tokenJWT;

  const HistorialTab({super.key, required this.tokenJWT});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService().obtenerGastos(tokenJWT),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar el historial', style: TextStyle(color: Color(0xFFEF4444))));
        }

        final lista = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Historial de Transacciones", 
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Revisa todos tus movimientos financieros registrados en la nube.",
                    style: TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 40),
                  
                  if (lista.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFFCBD5E1)),
                          SizedBox(height: 24),
                          Text("Sin movimientos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          SizedBox(height: 8),
                          Text("Aún no tienes ingresos o gastos registrados.", style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.1), blurRadius: 24, offset: const Offset(0, 10))]
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: lista.length,
                        separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFF1F5F9), thickness: 1.5),
                        itemBuilder: (context, index) {
                          final tx = lista[index];
                          String tipo = tx['tipo'] ?? 'gasto';
                          bool esIngreso = tipo == 'ingreso';
                          double monto = double.tryParse(tx['monto'].toString()) ?? 0.0;
                          
                          Color colorCat = const Color(0xFF94A3B8);
                          if (tx['categoria_colorHex'] != null) {
                            int? hex = int.tryParse("0xFF${tx['categoria_colorHex']}");
                            if (hex != null) colorCat = Color(hex);
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: (esIngreso ? const Color(0xFF10B981) : colorCat).withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    esIngreso ? Icons.arrow_downward_rounded : Icons.shopping_bag_rounded, 
                                    color: esIngreso ? const Color(0xFF10B981) : colorCat, 
                                    size: 24
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx['categoria_nombre'] ?? 'General', 
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1E293B))
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        tx['fecha_registro']?.toString().split('T')[0] ?? '', 
                                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500)
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${esIngreso ? '+' : '-'}\$${monto.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800, 
                                    fontSize: 18, 
                                    color: esIngreso ? const Color(0xFF10B981) : const Color(0xFF0F172A)
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}