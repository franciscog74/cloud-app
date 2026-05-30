import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class AddGastoScreen extends StatefulWidget {
  final String tokenJWT;

  const AddGastoScreen({super.key, required this.tokenJWT});

  @override
  State<AddGastoScreen> createState() => _AddGastoScreenState();
}

class _AddGastoScreenState extends State<AddGastoScreen> {
  final TextEditingController _montoController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  List<dynamic> _categorias = [];
  int? _idCategoriaSeleccionada;
  bool _isLoadingCategorias = true;
  bool _isSaving = false;
  String _tipoSeleccionado = 'gasto';

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _cargarCategorias() async {
    if (!mounted) return;
    setState(() => _isLoadingCategorias = true);
    try {
      final lista = await _apiService.obtenerCategorias(widget.tokenJWT);
      if (mounted) {
        setState(() {
          _categorias = lista;
          if (_categorias.isNotEmpty) {
            _idCategoriaSeleccionada = _categorias[0]['id'];
          }
          _isLoadingCategorias = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCategorias = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', ''), style: const TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _guardarTransaccion() async {
    final montoText = _montoController.text.trim();
    if (montoText.isEmpty || _idCategoriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, ingresa un monto y selecciona una categoría.', style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final monto = double.tryParse(montoText);
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ingresa un monto válido mayor a 0.', style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      await _apiService.registrarGasto(
        monto: monto,
        idCategoria: _idCategoriaSeleccionada!,
        tokenJWT: widget.tokenJWT,
        tipo: _tipoSeleccionado,
      );
      
      if (mounted) {
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', ''), style: const TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Nueva Transacción', 
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: _isLoadingCategorias
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    padding: const EdgeInsets.all(40.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 15))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            _btnTipo('gasto', const Color(0xFFEF4444), Icons.arrow_upward),
                            const SizedBox(width: 16),
                            _btnTipo('ingreso', const Color(0xFF10B981), Icons.arrow_downward),
                          ],
                        ),
                        const SizedBox(height: 40),

                        const Text(
                          '¿Qué cantidad?', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                          ),
                          child: TextField(
                            controller: _montoController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -1),
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                              border: InputBorder.none,
                              prefixText: '\$ ',
                              prefixStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        const Text(
                          'Categoría', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _idCategoriaSeleccionada,
                              isExpanded: true,
                              icon: const Icon(Icons.expand_more, color: Color(0xFF94A3B8)),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                              items: _categorias.map((cat) {
                                return DropdownMenuItem<int>(
                                  value: cat['id'],
                                  child: Text(cat['nombre']),
                                );  
                              }).toList(),
                              onChanged: (nuevoValor) {
                                setState(() {
                                  _idCategoriaSeleccionada = nuevoValor;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _guardarTransaccion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                  )
                                : Text(
                                    'GUARDAR ${_tipoSeleccionado.toUpperCase()}', 
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _btnTipo(String t, Color c, IconData icon) {
    bool sel = _tipoSeleccionado == t;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tipoSeleccionado = t),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: sel ? c.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: sel ? c : const Color(0xFFE2E8F0), width: sel ? 2 : 1),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: sel ? c : const Color(0xFF94A3B8)),
              const SizedBox(width: 8),
              Text(
                t.toUpperCase(), 
                style: TextStyle(
                  color: sel ? c : const Color(0xFF64748B), 
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}