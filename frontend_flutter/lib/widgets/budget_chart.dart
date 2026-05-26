import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BudgetChart extends StatelessWidget {
  const BudgetChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(color: Colors.blue, value: 40, title: '40%'),
            PieChartSectionData(color: Colors.green, value: 30, title: '30%'),
            PieChartSectionData(color: Colors.orange, value: 30, title: '30%'),
          ],
        ),
      ),
    );
  }
}