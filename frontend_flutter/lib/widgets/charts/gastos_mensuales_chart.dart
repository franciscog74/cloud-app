import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GastosMensualesChart extends StatelessWidget {
  const GastosMensualesChart({super.key});

  @override
  Widget build(BuildContext context) {
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
            'Evolución de Gastos (6 Meses)',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 280,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20000,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            titles[value.toInt()],
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('');
                        return Text(
                          '\$${(value / 1000).toInt()}k',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFFF1F5F9),
                    strokeWidth: 2,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildBar(0, 12000),
                  _buildBar(1, 15000),
                  _buildBar(2, 8000),
                  _buildBar(3, 18000),
                  _buildBar(4, 14000),
                  _buildBar(5, 9500),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF2563EB), 
          width: 28, 
          borderRadius: BorderRadius.circular(8),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20000, 
            color: const Color(0xFFF1F5F9),
          ),
        ),
      ],
    );
  }
}