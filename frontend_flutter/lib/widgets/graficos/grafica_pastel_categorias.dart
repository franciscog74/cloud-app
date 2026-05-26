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
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No hay datos suficientes para graficar.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    // Calculamos el total para sacar porcentajes
    double totalMonto = widget.datosCategorias.fold(
      0.0, 
      (sum, item) => sum + (double.tryParse(item['monto'].toString()) ?? 0.0)
    );

    return Row(
      children: [
        // La gráfica tipo Dona
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 200,
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
                sectionsSpace: 2, // Espacio entre las rebanadas
                centerSpaceRadius: 40, // Esto hace que parezca una dona
                sections: _generarSecciones(totalMonto),
              ),
            ),
          ),
        ),
        
        // Leyenda lateral con el detalle de categorías
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.datosCategorias.map((categoria) {
              Color colorIcono;
              try {
                colorIcono = Color(int.parse("0xFF${categoria['colorHex']}"));
              } catch (_) {
                colorIcono = Colors.black;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorIcono,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        categoria['nombre'] ?? 'Desconocido',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
      final double fontSize = isTouched ? 16.0 : 12.0;
      final double radius = isTouched ? 60.0 : 50.0;
      
      final data = widget.datosCategorias[i];
      final double monto = double.tryParse(data['monto'].toString()) ?? 0.0;
      final double porcentaje = totalMonto == 0 ? 0 : (monto / totalMonto) * 100;

      Color colorSeccion;
      try {
        colorSeccion = Color(int.parse("0xFF${data['colorHex']}"));
      } catch (_) {
        colorSeccion = Colors.grey;
      }

      return PieChartSectionData(
        color: colorSeccion,
        value: monto,
        title: '${porcentaje.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    });
  }
}