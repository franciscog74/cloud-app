import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GastosMensualesChart extends StatelessWidget {
  final List<FlSpot> puntosGrafica;
  final List<String> etiquetasMeses;
  final double maximoY;

  const GastosMensualesChart({
    super.key, 
    required this.puntosGrafica, 
    required this.etiquetasMeses,
    required this.maximoY,
  });

  @override
  Widget build(BuildContext context) {
    if (puntosGrafica.isEmpty) {
      return Container(
        height: 280,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: const Text('No hay datos históricos suficientes', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
      );
    }

    double topeGrafico = maximoY == 0 ? 100 : maximoY * 1.2;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 10))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tendencia de Gastos (6 Meses)',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 280,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: topeGrafico / 5 > 0 ? topeGrafico / 5 : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 2);
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= etiquetasMeses.length) return const Text('');
                        return Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            etiquetasMeses[index],
                            style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: topeGrafico / 5 > 0 ? topeGrafico / 5 : 1,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('');
                        if (value >= 1000) {
                          return Text('\$${(value / 1000).toStringAsFixed(1)}k', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.left);
                        }
                        return Text('\$${value.toInt()}', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.left);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (etiquetasMeses.length - 1).toDouble(),
                minY: 0,
                maxY: topeGrafico,
                lineBarsData: [
                  LineChartBarData(
                    spots: puntosGrafica,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFF10B981),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: const Color(0xFF10B981),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF10B981).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}