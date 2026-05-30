import 'dart:convert';
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
  String _correoUsuario = 'Usuario';
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _extraerDatosUsuario();
    _cargarCategorias();
  }

  void _extraerDatosUsuario() {
    try {
      final parts = widget.tokenJWT.split('.');
      if (parts.length == 3) {
        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final resp = utf8.decode(base64Url.decode(normalized));
        final payloadMap = json.decode(resp);
        setState(() {
          _correoUsuario = payloadMap['email'] ?? 'Usuario Registrado';
        });
      }
    } catch (_) {}
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
            content: const Text('Error de conexión', style: TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _mostrarEditorCategoria({Map<String, dynamic>? categoriaEdicion}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ajustes',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
              ),
              const SizedBox(height: 40),
              
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))
                  ]
                ),
                child: Row(
                  children: [
                    Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, size: 32, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _correoUsuario,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              const Text('Cuenta Segura', style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MIS CATEGORÍAS',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1.2),
                  ),
                  InkWell(
                    onTap: () => _mostrarEditorCategoria(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, size: 18, color: Color(0xFF2563EB)),
                          SizedBox(width: 4),
                          Text('Nueva', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                child: _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                        ),
                      )
                    : _categorias.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.category_outlined, size: 48, color: Color(0xFFCBD5E1)),
                                  SizedBox(height: 16),
                                  Text(
                                    'No hay categorías creadas',
                                    style: TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _categorias.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            itemBuilder: (context, index) {
                              final cat = _categorias[index];
                              Color colorIcono = const Color(0xFF94A3B8);

                              if (cat['colorHex'] != null) {
                                final int? hexCasted = int.tryParse("0xFF${cat['colorHex']}");
                                if (hexCasted != null) colorIcono = Color(hexCasted);
                              }

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colorIcono.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.local_offer, color: colorIcono, size: 20),
                                ),
                                title: Text(
                                  cat['nombre'] ?? 'Sin nombre',
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 16),
                                ),
                                trailing: const Icon(Icons.chevron_right, size: 24, color: Color(0xFFCBD5E1)),
                                onTap: () => _mostrarEditorCategoria(categoriaEdicion: cat),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFFECACA), width: 2),
                    backgroundColor: const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text('Cerrar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
    '0F172A',
    'EF4444',
    'F59E0B',
    '10B981',
    '3B82F6',
    '8B5CF6',
    'EC4899',
    '14B8A6',
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.categoriaEdicion?['nombre'] ?? '',
    );
    _colorSeleccionado = widget.categoriaEdicion?['colorHex'] ?? '0F172A';
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
          SnackBar(
            content: const Text('Error al eliminar', style: TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )
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
          SnackBar(
            content: const Text('Error al guardar', style: TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )
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

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        left: 32,
        right: 32,
        top: 32,
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
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                onPressed: isProcessing ? null : () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nombreController,
            enabled: !isProcessing,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              labelText: 'Nombre de la categoría',
              labelStyle: const TextStyle(color: Color(0xFF64748B)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2)),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Color de la categoría',
            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B), fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _coloresDisponibles.length,
              itemBuilder: (context, index) {
                String colorHex = _coloresDisponibles[index];
                bool isSelected = _colorSeleccionado == colorHex;
                Color itemColor = Color(int.parse("0xFF$colorHex"));
                
                return GestureDetector(
                  onTap: isProcessing ? null : () => setState(() => _colorSeleccionado = colorHex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 16),
                    width: isSelected ? 56 : 48,
                    height: isSelected ? 56 : 48,
                    decoration: BoxDecoration(
                      color: itemColor,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: const Color(0xFF2563EB), width: 4) : null,
                      boxShadow: [
                        if (isSelected) BoxShadow(color: itemColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))
                      ],
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              if (esEdicion) ...[
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: isProcessing ? null : _eliminarCategoria,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFFECACA), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isDeleting
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFFEF4444), strokeWidth: 2))
                          : const Icon(Icons.delete_outline, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : _guardarCategoria,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Guardar Categoría', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}