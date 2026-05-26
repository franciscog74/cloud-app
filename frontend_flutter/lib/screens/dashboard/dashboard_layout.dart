import 'package:flutter/material.dart';
import 'tabs/inicio_tab.dart';
import 'tabs/historial_tab.dart';
import 'tabs/ajustes_tab.dart'; 
import 'add_gasto_screen.dart'; 

class DashboardLayout extends StatefulWidget {
  final String tokenJWT; 
  
  const DashboardLayout({super.key, required this.tokenJWT});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  int _selectedIndex = 0;

  /// Método actualizado para mostrar un Dialog (Modal) en lugar de navegar a otra página
  void _navegarYActualizar(BuildContext context) async {
    final recargar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SizedBox(
            width: 500, // Ancho controlado para que se vea como web
            height: 650, 
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AddGastoScreen(tokenJWT: widget.tokenJWT),
            ),
          ),
        );
      },
    );

    // Si el gasto se guardó con éxito ("true"), forzamos la recarga de Inicio
    if (recargar == true) {
      setState(() {
        _selectedIndex = 0; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              NavigationRail(
                backgroundColor: Colors.white,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), label: Text('Inicio')),
                  NavigationRailDestination(icon: Icon(Icons.receipt_long_outlined), label: Text('Historial')),
                  NavigationRailDestination(icon: Icon(Icons.settings_outlined), label: Text('Ajustes')),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: _obtenerPantallaActual()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => _navegarYActualizar(context), 
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Gasto'),
      ),
    );
  }

  Widget _obtenerPantallaActual() {
    switch (_selectedIndex) {
      case 0: return InicioTab(key: UniqueKey(), tokenJWT: widget.tokenJWT);
      case 1: return HistorialTab(tokenJWT: widget.tokenJWT); 
      case 2: return AjustesTab(tokenJWT: widget.tokenJWT); 
      default: return const Center(child: Text('Error'));
    }
  }
}