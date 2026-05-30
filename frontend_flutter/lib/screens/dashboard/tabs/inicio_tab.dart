import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/api_service.dart';
import '../../../widgets/graficos/grafica_pastel_categorias.dart';

class InicioTab extends StatefulWidget {
  final String tokenJWT;

  const InicioTab({super.key, required this.tokenJWT});

  @override
  State<InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends State<InicioTab> {
  String _filtroSeleccionado = '30 días';
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _apiService.obtenerGastos(widget.tokenJWT),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Error al cargar datos desde AWS'));
        }

        final listaTransacciones = snapshot.data!;
        
        double totalGastos = 0;
        double totalIngresos = 0;
        List<double> gastosPorDia = List.filled(7, 0.0);
        double maxGastoDiario = 0.0;
        
        Map<String, Map<String, dynamic>> categoriasMap = {};

        for (var tx in listaTransacciones) {
          double monto = double.tryParse(tx['monto'].toString()) ?? 0;
          String tipo = tx['tipo'] ?? 'gasto';

          if (tipo == 'gasto') {
            totalGastos += monto;
            
            if (tx['fecha_registro'] != null) {
              try {
                int indiceDia = DateTime.parse(tx['fecha_registro']).weekday - 1;
                gastosPorDia[indiceDia] += monto;
                if (gastosPorDia[indiceDia] > maxGastoDiario) maxGastoDiario = gastosPorDia[indiceDia];
              } catch (_) {}
            }

            String catNombre = tx['categoria_nombre'] ?? 'Otros';
            String catColor = tx['categoria_color'] ?? '9E9E9E'; 
            
            if (categoriasMap.containsKey(catNombre)) {
              categoriasMap[catNombre]!['monto'] += monto;
            } else {
              categoriasMap[catNombre] = {
                'nombre': catNombre,
                'monto': monto,
                'colorHex': catColor,
              };
            }
          } else {
            totalIngresos += monto;
          }
        }

        List<Map<String, dynamic>> datosParaPastel = categoriasMap.values.toList();
        int diaActual = DateTime.now().weekday - 1;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  
                  Wrap(
                    spacing: 24, runSpacing: 24,
                    children: [
                      _buildSummaryCard('Balance Disponible', '\$${(totalIngresos - totalGastos).toStringAsFixed(2)}', Icons.account_balance_wallet, const Color(0xFF0F172A), const Color(0xFF3B82F6)),
                      _buildSummaryCard('Ingresos (Mes)', '\$${totalIngresos.toStringAsFixed(2)}', Icons.trending_up, Colors.white, const Color(0xFF10B981)),
                      _buildSummaryCard('Gastos Reales', '\$${totalGastos.toStringAsFixed(2)}', Icons.trending_down, Colors.white, const Color(0xFFEF4444)),
                    ],
                  ),
                  
                  const SizedBox(height: 48),

                  Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildChartHeader('Análisis Semanal'),
                        const SizedBox(height: 40),
                        SizedBox(height: 280, child: _buildWeeklyChart(gastosPorDia, maxGastoDiario, diaActual)),
                        
                        const Padding(padding: EdgeInsets.symmetric(vertical: 40.0), child: Divider(color: Color(0xFFF1F5F9), thickness: 2)),

                        const Text('Distribución de Gastos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 32),
                        GraficaPastelCategorias(datosCategorias: datosParaPastel),
                        
                        const Padding(padding: EdgeInsets.symmetric(vertical: 40.0), child: Divider(color: Color(0xFFF1F5F9), thickness: 2)),

                        const Text('Transacciones Recientes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 24),
                        ...listaTransacciones.take(5).map((tx) => _buildTransactionRow(tx)),
                      ],
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 10))
      ]
    );
  }

  Widget _buildHeader() {
    return const Text('Resumen Financiero', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5));
  }

  Widget _buildChartHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        Row(children: ['7 días', '30 días', '12 meses'].map((f) => _buildFilterButton(f)).toList()),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String amount, IconData icon, Color bgColor, Color accentColor) {
    bool isDark = bgColor != Colors.white;
    return Container(
      width: 320, padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(24),
        border: isDark ? null : Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: isDark ? [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))] : [BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: accentColor.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: accentColor, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(amount, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1)),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    bool isSelected = _filtroSeleccionado == label;
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: InkWell(
        onTap: () => setState(() => _filtroSeleccionado = label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF8FAFC), 
            borderRadius: BorderRadius.circular(20),
            border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0))
          ),
          child: Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF64748B), fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(List<double> gastosPorDia, double maxGasto, int diaActual) {
    double topeGrafico = maxGasto == 0 ? 100 : maxGasto * 1.2;
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: topeGrafico,
        barTouchData: BarTouchData(enabled: true),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                bool isToday = val.toInt() == diaActual;
                return SideTitleWidget(
                  axisSide: meta.axisSide, 
                  child: Text(dias[val.toInt()], style: TextStyle(color: isToday ? const Color(0xFF2563EB) : const Color(0xFF94A3B8), fontSize: 13, fontWeight: isToday ? FontWeight.bold : FontWeight.w500))
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(7, (i) => BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(
            toY: gastosPorDia[i] == 0 ? topeGrafico * 0.02 : gastosPorDia[i],
            color: i == diaActual ? const Color(0xFF2563EB) : const Color(0xFF93C5FD),
            width: 28,
            borderRadius: BorderRadius.circular(8),
            backDrawRodData: BackgroundBarChartRodData(show: true, toY: topeGrafico, color: const Color(0xFFF1F5F9)),
          )],
        )),
      ),
    );
  }

  Widget _buildTransactionRow(dynamic tx) {
    String tipo = tx['tipo'] ?? 'gasto';
    bool esIngreso = tipo == 'ingreso';
    double monto = double.tryParse(tx['monto'].toString()) ?? 0.0;
    Color colorCat = Color(int.parse("0xFF${tx['categoria_color'] ?? '000000'}"));

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (esIngreso ? const Color(0xFF10B981) : colorCat).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14)
            ),
            child: Icon(esIngreso ? Icons.arrow_downward : Icons.local_offer, color: esIngreso ? const Color(0xFF10B981) : colorCat, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['categoria_nombre'] ?? 'General', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text('${tx['fecha_registro']?.toString().split('T')[0] ?? ''}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
              ],
            ),
          ),
          Text(
            '${esIngreso ? '+' : '-'}\$${monto.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: esIngreso ? const Color(0xFF10B981) : const Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }
}