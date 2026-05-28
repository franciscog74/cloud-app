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

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final lista = await _apiService.obtenerCategorias(widget.tokenJWT);
      if (mounted) {
        setState(() {
          _categorias = lista;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categorias = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  void _mostrarEditorCategoria({Map<String, dynamic>? categoriaEdicion}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return CategoriaEditorModal(
          categoriaEdicion: categoriaEdicion,
          tokenJWT: widget.tokenJWT,
          apiService: _apiService,
          onSaved: _cargarCategorias,
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                onPressed: () => _mostrarEditorCategoria(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                  )
                : _categorias.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            'No hay categorías creadas aún.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _categorias.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final cat = _categorias[index];
                          Color colorIcono = Colors.black;

                          if (cat['colorHex'] != null) {
                            final int? hexCasted = int.tryParse("0xFF${cat['colorHex']}");
                            if (hexCasted != null) {
                              colorIcono = Color(hexCasted);
                            }
                          }

                          return ListTile(
                            leading: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colorIcono,
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: Text(
                              cat['nombre'] ?? 'Sin nombre',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                            onTap: () => _mostrarEditorCategoria(categoriaEdicion: cat),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 40),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriaEditorModal extends StatefulWidget {
  final Map<String, dynamic>? categoriaEdicion;
  final String tokenJWT;
  final ApiService apiService;
  final VoidCallback onSaved;

  const CategoriaEditorModal({
    super.key,
    this.categoriaEdicion,
    required this.tokenJWT,
    required this.apiService,
    required this.onSaved,
  });

  @override
  State<CategoriaEditorModal> createState() => _CategoriaEditorModalState();
}

class _CategoriaEditorModalState extends State<CategoriaEditorModal> {
  late TextEditingController _nombreController;
  late String _colorSeleccionado;
  bool _isSaving = false;
  bool _isDeleting = false;

  final List<String> _coloresDisponibles = [
    '000000',
    'FF3B30',
    'FF9500',
    'FFCC00',
    '34C759',
    '007AFF',
    '5856D6',
    'FF2D55',
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.categoriaEdicion?['nombre'] ?? '',
    );
    _colorSeleccionado = widget.categoriaEdicion?['colorHex'] ?? '000000';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _eliminarCategoria() async {
    setState(() => _isDeleting = true);
    try {
      await widget.apiService.eliminarCategoria(
        widget.tokenJWT,
        widget.categoriaEdicion!['id'],
      );
      if (mounted) {
        widget.onSaved();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _guardarCategoria() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      if (widget.categoriaEdicion != null) {
        await widget.apiService.actualizarCategoria(
          widget.tokenJWT,
          widget.categoriaEdicion!['id'],
          nombre,
          _colorSeleccionado,
        );
      } else {
        await widget.apiService.crearCategoria(
          widget.tokenJWT,
          nombre,
          _colorSeleccionado,
        );
      }
      if (mounted) {
        widget.onSaved();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esEdicion = widget.categoriaEdicion != null;
    final bool isProcessing = _isSaving || _isDeleting;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
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
                onPressed: isProcessing ? null : () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nombreController,
            enabled: !isProcessing,
            decoration: InputDecoration(
              labelText: 'Nombre de la categoría',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Color de la categoría',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _coloresDisponibles.length,
              itemBuilder: (context, index) {
                String colorHex = _coloresDisponibles[index];
                bool isSelected = _colorSeleccionado == colorHex;
                return GestureDetector(
                  onTap: isProcessing
                      ? null
                      : () => setState(() => _colorSeleccionado = colorHex),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse("0xFF$colorHex")),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              if (esEdicion) ...[
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: isProcessing ? null : _eliminarCategoria,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isDeleting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.red,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.delete_outline),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: isProcessing ? null : _guardarCategoria,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Guardar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}