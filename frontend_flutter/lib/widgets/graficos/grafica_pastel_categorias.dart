import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraficaPastelCategorias extends StatefulWidget {
  final List<Map<String, dynamic>> datosCategorias;

  const GraficaPastelCategorias({super.key, required this.datosCategorias});

  @override
  State<GraficaPastelCategorias> createState() => _GraficaPastelCategoriasState();
}

class _GraficaPastelCategoriasState extends State<GraficaPastelCategorias> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.datosCategorias.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No hay datos para graficar',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    double totalMonto = widget.datosCategorias.fold(
      0.0, 
      (sum, item) => sum + (double.tryParse(item['monto'].toString()) ?? 0.0)
    );

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: SizedBox(
            height: 240,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 4,
                centerSpaceRadius: 50,
                sections: _generarSecciones(totalMonto),
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.datosCategorias.map((categoria) {
              Color colorIcono;
              try {
                String hexStr = categoria['colorHex'].toString().replaceAll('#', '').trim();
                if (hexStr.length == 6) {
                  colorIcono = Color(int.parse("0xFF$hexStr"));
                } else {
                  colorIcono = const Color(0xFF94A3B8);
                }
              } catch (_) {
                colorIcono = const Color(0xFF94A3B8);
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorIcono,
                        boxShadow: [
                          BoxShadow(color: colorIcono.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                        ]
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        categoria['nombre'] ?? 'Desconocido',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _generarSecciones(double totalMonto) {
    return List.generate(widget.datosCategorias.length, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 16.0 : 13.0;
      final double radius = isTouched ? 70.0 : 60.0;
      
      final data = widget.datosCategorias[i];
      final double monto = double.tryParse(data['monto'].toString()) ?? 0.0;
      final double porcentaje = totalMonto == 0 ? 0 : (monto / totalMonto) * 100;

      Color colorSeccion;
      try {
        String hexStr = data['colorHex'].toString().replaceAll('#', '').trim();
        if (hexStr.length == 6) {
          colorSeccion = Color(int.parse("0xFF$hexStr"));
        } else {
          colorSeccion = const Color(0xFF94A3B8);
        }
      } catch (_) {
        colorSeccion = const Color(0xFF94A3B8);
      }

      return PieChartSectionData(
        color: colorSeccion,
        value: monto,
        title: '${porcentaje.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)],
        ),
      );
    });
  }
}