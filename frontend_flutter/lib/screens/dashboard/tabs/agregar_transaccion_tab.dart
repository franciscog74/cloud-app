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
  
  String _tipo = 'gasto'; // Gasto o Ingreso
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
      backgroundColor: Colors.grey.shade100, 
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480), // Ancho máximo más compacto para web
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, //obliga a la tarjeta a usar solo el alto que necesita
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Nuevo Registro', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  
                  // Selector Gasto / Ingreso
                  Row(
                    children: [
                      _btnTipo('gasto', Colors.red),
                      const SizedBox(width: 16),
                      _btnTipo('ingreso', Colors.green),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Entrada de dinero
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _montoController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: '\$0.00', 
                        border: InputBorder.none,
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Selecciona una Categoría', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 16),

                  // Grilla de Categorías adaptada
                  if (_categorias.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: Colors.black),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true, 
                      physics: const NeverScrollableScrollPhysics(), 
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, 
                        mainAxisSpacing: 16, 
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85, // EVITA QUE LAS CATEGORÍAS SE ESTIREN
                      ),
                      itemCount: _categorias.length,
                      itemBuilder: (context, i) {
                        final c = _categorias[i];
                        bool isSelected = _idCat == c['id'];
                        return InkWell(
                          onTap: () => setState(() => _idCat = c['id']),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black.withOpacity(0.05) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? Colors.black : Colors.transparent, width: 2)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isSelected ? Colors.black : Colors.grey.shade100, 
                                  child: Icon(Icons.category, size: 18, color: isSelected ? Colors.white : Colors.black54),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  c['nombre'], 
                                  style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal), 
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 40),

                  // Botón Guardar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _cargando ? null : () async {
                        if (_montoController.text.isEmpty || _idCat == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa monto y categoría')));
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
                        
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado con éxito')));
                        _montoController.clear();
                        setState(() => _idCat = null); // Limpiar categoría seleccionada
                      },
                      child: _cargando 
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('GUARDAR REGISTRO', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
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

  Widget _btnTipo(String t, Color c) {
    bool sel = _tipo == t;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tipo = t),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: sel ? c : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? c : Colors.grey.shade300, width: sel ? 0 : 1),
          ),
          alignment: Alignment.center,
          child: Text(
            t.toUpperCase(), 
            style: TextStyle(color: sel ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)
          ),
        ),
      ),
    );
  }
}