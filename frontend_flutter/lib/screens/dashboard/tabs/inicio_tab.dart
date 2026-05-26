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
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Error al cargar datos desde AWS'));
        }

        final listaTransacciones = snapshot.data!;
        
        // --- PROCESAMIENTO DE DATOS OPTIMIZADO ---
        double totalGastos = 0;
        double totalIngresos = 0;
        List<double> gastosPorDia = List.filled(7, 0.0);
        double maxGastoDiario = 0.0;
        
        // Mapa para agrupar gastos por categoría para la Gráfica de Pastel
        Map<String, Map<String, dynamic>> categoriasMap = {};

        for (var tx in listaTransacciones) {
          double monto = double.tryParse(tx['monto'].toString()) ?? 0;
          String tipo = tx['tipo'] ?? 'gasto';

          if (tipo == 'gasto') {
            totalGastos += monto;
            
            // 1. Lógica BarChart (Semanal)
            if (tx['fecha_registro'] != null) {
              try {
                int indiceDia = DateTime.parse(tx['fecha_registro']).weekday - 1;
                gastosPorDia[indiceDia] += monto;
                if (gastosPorDia[indiceDia] > maxGastoDiario) maxGastoDiario = gastosPorDia[indiceDia];
              } catch (_) {}
            }

            // 2. Lógica PieChart (Agrupación por Categoría)
            String catNombre = tx['categoria_nombre'] ?? 'Otros';
            String catColor = tx['categoria_color'] ?? '9E9E9E'; // Gris por defecto
            
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
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  
                  // Tarjetas de Resumen
                  Wrap(
                    spacing: 24, runSpacing: 24,
                    children: [
                      _buildSummaryCard('Balance Disponible', '\$${(totalIngresos - totalGastos).toStringAsFixed(2)}', Icons.account_balance, Colors.black, Colors.white),
                      _buildSummaryCard('Ingresos (Mes)', '\$${totalIngresos.toStringAsFixed(2)}', Icons.arrow_downward, Colors.white, Colors.black),
                      _buildSummaryCard('Gastos Reales', '\$${totalGastos.toStringAsFixed(2)}', Icons.arrow_upward, Colors.white, Colors.black),
                    ],
                  ),
                  
                  const SizedBox(height: 40),

                  // Contenedor Principal de Gráficos y Transacciones
                  Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildChartHeader('Análisis Semanal'),
                        const SizedBox(height: 40),
                        SizedBox(height: 250, child: _buildWeeklyChart(gastosPorDia, maxGastoDiario, diaActual)),
                        
                        const Padding(padding: EdgeInsets.symmetric(vertical: 32.0), child: Divider()),

                        // --- SECCIÓN DE GRAFICA DE PASTEL ---
                        const Text('Distribución de Gastos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        GraficaPastelCategorias(datosCategorias: datosParaPastel),
                        
                        const Padding(padding: EdgeInsets.symmetric(vertical: 32.0), child: Divider()),

                        const Text('Transacciones Recientes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
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

  // --- WIDGETS DE APOYO OPTIMIZADOS ---

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
    );
  }

  Widget _buildHeader() {
    return const Text('Resumen Financiero', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black));
  }

  Widget _buildChartHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Row(children: ['7 días', '30 días', '12 meses'].map((f) => _buildFilterButton(f)).toList()),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String amount, IconData icon, Color bgColor, Color textColor) {
    return Container(
      width: 300, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor, borderRadius: BorderRadius.circular(20),
        border: bgColor == Colors.white ? Border.all(color: Colors.grey.shade200) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.w500)),
              Icon(icon, color: textColor.withOpacity(0.7), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(amount, style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    bool isSelected = _filtroSeleccionado == label;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: InkWell(
        onTap: () => setState(() => _filtroSeleccionado = label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.transparent, borderRadius: BorderRadius.circular(20)),
          child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade600, fontSize: 14)),
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
                return SideTitleWidget(axisSide: meta.axisSide, child: Text(dias[val.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 12)));
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
            toY: gastosPorDia[i] == 0 ? topeGrafico * 0.05 : gastosPorDia[i],
            color: i == diaActual ? Colors.black : Colors.grey.shade300,
            width: 22,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(show: true, toY: topeGrafico, color: Colors.grey.shade100),
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
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: (esIngreso ? Colors.green : colorCat).withOpacity(0.1),
            child: Icon(esIngreso ? Icons.arrow_downward : Icons.arrow_upward, color: esIngreso ? Colors.green : colorCat),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['categoria_nombre'] ?? 'General', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                Text('${tx['fecha_registro']?.toString().split('T')[0] ?? ''}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
          Text(
            '${esIngreso ? '+' : '-'}\$${monto.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: esIngreso ? Colors.green.shade700 : Colors.black),
          ),
        ],
      ),
    );
  }
}