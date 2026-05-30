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

  void _navegarYActualizar(BuildContext context) async {
    final recargar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: SizedBox(
            width: 520,
            height: 700, 
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: AddGastoScreen(tokenJWT: widget.tokenJWT),
            ),
          ),
        );
      },
    );

    if (recargar == true) {
      setState(() {
        _selectedIndex = 0; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Row(
            children: [
              NavigationRail(
                backgroundColor: Colors.white,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
                labelType: NavigationRailLabelType.all,
                selectedLabelTextStyle: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelTextStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13),
                selectedIconTheme: const IconThemeData(color: Color(0xFF2563EB), size: 28),
                unselectedIconTheme: const IconThemeData(color: Color(0xFF94A3B8), size: 24),
                useIndicator: true,
                indicatorColor: const Color(0xFF2563EB).withOpacity(0.1),
                destinations: const [
                  NavigationRailDestination(
                    icon: Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Icon(Icons.dashboard_outlined)), 
                    selectedIcon: Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Icon(Icons.dashboard_rounded)), 
                    label: Text('Inicio')
                  ),
                  NavigationRailDestination(
                    icon: Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Icon(Icons.receipt_long_outlined)), 
                    selectedIcon: Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Icon(Icons.receipt_long)), 
                    label: Text('Historial')
                  ),
                  NavigationRailDestination(
                    icon: Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Icon(Icons.settings_outlined)), 
                    selectedIcon: Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Icon(Icons.settings)), 
                    label: Text('Ajustes')
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1.5, width: 1.5, color: Color(0xFFE2E8F0)),
              Expanded(child: _obtenerPantallaActual()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 4,
        hoverElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => _navegarYActualizar(context), 
        icon: const Icon(Icons.add, size: 24),
        label: const Text('Nuevo Registro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
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