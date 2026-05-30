import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class AgregarDatosTab extends StatefulWidget {
  final String tokenJWT;
  const AgregarDatosTab({super.key, required this.tokenJWT});

  @override
  State<AgregarDatosTab> createState() => _AgregarDatosTabState();
}

class _AgregarDatosTabState extends State<AgregarDatosTab> {
  final ApiService _apiService = ApiService();
  final TextEditingController _montoController = TextEditingController();
  
  String _tipo = 'gasto';
  int? _idCat;
  List<dynamic> _categorias = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  _cargarCategorias() async {
    final res = await _apiService.obtenerCategorias(widget.tokenJWT);
    setState(() => _categorias = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Hereda el fondo del layout padre
      body: Align(
        alignment: Alignment.topCenter,   
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
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
                mainAxisSize: MainAxisSize.min, 
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Nuevo Registro', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                  const SizedBox(height: 40),
                  
                  // Selector Gasto / Ingreso
                  Row(
                    children: [
                      _btnTipo('gasto', const Color(0xFFEF4444), Icons.arrow_upward),
                      const SizedBox(width: 16),
                      _btnTipo('ingreso', const Color(0xFF10B981), Icons.arrow_downward),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Entrada de dinero
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
                  const SizedBox(height: 48),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Selecciona una Categoría', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1E293B))),
                  ),
                  const SizedBox(height: 24),

                  // Grilla de Categorías
                  if (_categorias.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true, 
                      physics: const NeverScrollableScrollPhysics(), 
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, 
                        mainAxisSpacing: 16, 
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85, 
                      ),
                      itemCount: _categorias.length,
                      itemBuilder: (context, i) {
                        final c = _categorias[i];
                        bool isSelected = _idCat == c['id'];
                        Color catColor = Color(int.parse("0xFF${c['colorHex'] ?? '94A3B8'}"));
                        
                        return InkWell(
                          onTap: () => setState(() => _idCat = c['id']),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? catColor.withOpacity(0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isSelected ? catColor : const Color(0xFFF1F5F9), width: 2)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? catColor : const Color(0xFFF8FAFC),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.category, size: 22, color: isSelected ? Colors.white : const Color(0xFF94A3B8)),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  c['nombre'], 
                                  style: TextStyle(
                                    fontSize: 12, 
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B)
                                  ), 
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 48),

                  // Botón Guardar
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB), 
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _cargando ? null : () async {
                        if (_montoController.text.isEmpty || _idCat == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Ingresa un monto y selecciona una categoría', style: TextStyle(fontWeight: FontWeight.w600)),
                              backgroundColor: const Color(0xFF0F172A),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            )
                          );
                          return;
                        }

                        setState(() => _cargando = true);
                        await _apiService.registrarGasto(
                          monto: double.parse(_montoController.text),
                          idCategoria: _idCat!,
                          tokenJWT: widget.tokenJWT,
                          tipo: _tipo
                        );
                        setState(() => _cargando = false);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Registro guardado exitosamente', style: TextStyle(fontWeight: FontWeight.w600)),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          )
                        );
                        _montoController.clear();
                        setState(() => _idCat = null); 
                      },
                      child: _cargando 
                        ? const SizedBox(height: 28, width: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Text('GUARDAR REGISTRO', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1)),
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
    bool sel = _tipo == t;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tipo = t),
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