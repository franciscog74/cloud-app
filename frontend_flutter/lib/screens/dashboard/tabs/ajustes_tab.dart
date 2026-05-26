import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../auth/login_screen.dart';

class AjustesTab extends StatefulWidget {
  final String tokenJWT; 

  const AjustesTab({super.key, required this.tokenJWT});

  @override
  State<AjustesTab> createState() => _AjustesTabState();
}

class _AjustesTabState extends State<AjustesTab> {
  List<dynamic> _categorias = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  // Lista de colores predefinidos para elegir
  final List<String> _coloresDisponibles = [
    '000000', // Negro
    'FF3B30', // Rojo
    'FF9500', // Naranja
    'FFCC00', // Amarillo
    '34C759', // Verde
    '007AFF', // Azul
    '5856D6', // Morado
    'FF2D55', // Rosa
  ];

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    setState(() => _isLoading = true);
    try {
      final lista = await _apiService.obtenerCategorias(widget.tokenJWT);
      setState(() {
        _categorias = lista;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar categorías')),
        );
      }
    }
  }

  void _mostrarEditorCategoria({Map<String, dynamic>? categoriaEdicion}) {
    final TextEditingController nombreController = TextEditingController(text: categoriaEdicion?['nombre'] ?? '');
    String colorSeleccionado = categoriaEdicion?['colorHex'] ?? '000000';
    bool esEdicion = categoriaEdicion != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        esEdicion ? 'Editar Categoría' : 'Nueva Categoría',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Campo de Texto
                  TextField(
                    controller: nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de la categoría',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Selector de Color
                  const Text('Color de la categoría', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _coloresDisponibles.length,
                      itemBuilder: (context, index) {
                        String colorHex = _coloresDisponibles[index];
                        bool isSelected = colorSeleccionado == colorHex;
                        return GestureDetector(
                          onTap: () => setModalState(() => colorSeleccionado = colorHex),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(int.parse("0xFF$colorHex")),
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                              boxShadow: [
                                if (isSelected) BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
                              ]
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Botones de Acción
                  Row(
                    children: [
                      if (esEdicion) ...[
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: () async {
                              //llamada a la API para eliminar
                              // await _apiService.eliminarCategoria(widget.tokenJWT, categoriaEdicion['id']);
                              Navigator.pop(context);
                              _cargarCategorias();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Icon(Icons.delete_outline),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: () async {
                            final nombre = nombreController.text.trim();
                            if (nombre.isEmpty) return;

                            // llamada a la API para Guardar/Actualizar
                            if (esEdicion) {
                              // await _apiService.actualizarCategoria(widget.tokenJWT, categoriaEdicion['id'], nombre, colorSeleccionado);
                            } else {
                              // await _apiService.crearCategoria(widget.tokenJWT, nombre, colorSeleccionado);
                            }
                            
                            Navigator.pop(context);
                            _cargarCategorias(); // Recargar la lista
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MIS CATEGORÍAS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                onPressed: () => _mostrarEditorCategoria(), // Abrir modal para Crear
                tooltip: 'Añadir categoría',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lista de categorías dinámica
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: _isLoading 
              ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.black)))
              : _categorias.isEmpty 
                ? const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text('No hay categorías creadas aún.', style: TextStyle(color: Colors.grey))),
                  )
                : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _categorias.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cat = _categorias[index];
                    
                    // Lógica para pintar el color de AWS
                    Color colorIcono = Colors.black;
                    if (cat['colorHex'] != null) {
                      try {
                        colorIcono = Color(int.parse("0xFF${cat['colorHex']}"));
                      } catch (_) {}
                    }

                    return ListTile(
                      leading: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(color: colorIcono, shape: BoxShape.circle),
                      ),
                      title: Text(cat['nombre'] ?? 'Sin nombre', style: const TextStyle(fontWeight: FontWeight.w500)),
                      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                      onTap: () => _mostrarEditorCategoria(categoriaEdicion: cat), // Abrir modal para Editar
                    );
                  },
                ),
          ),
          
          const SizedBox(height: 40),
          
          // Botón de Cerrar Sesión
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()), 
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade100),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ),
        ],
      ),
    );
  }
}