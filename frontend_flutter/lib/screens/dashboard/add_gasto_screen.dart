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
  
  // NUEVO: 'gasto' o 'ingreso' para controlar el tipo de transacción
  String _tipoSeleccionado = 'gasto'; 

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    try {
      final lista = await _apiService.obtenerCategorias(widget.tokenJWT);
      setState(() {
        _categorias = lista;
        if (_categorias.isNotEmpty) {
          _idCategoriaSeleccionada = _categorias[0]['id'];
        }
        _isLoadingCategorias = false;
      });
    } catch (e) {
      setState(() => _isLoadingCategorias = false);
    }
  }

  Future<void> _guardarTransaccion() async {
    final montoText = _montoController.text.trim();
    if (montoText.isEmpty || _idCategoriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un monto y selecciona una categoría.')),
      );
      return;
    }

    final monto = double.tryParse(montoText);
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto válido mayor a 0.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Mandamos los datos Backend
    // NOTA:ApiService en registrarGasto debe aceptar ahora el parámetro 'tipo'
    final exito = await _apiService.registrarGasto(
      monto: monto,
      idCategoria: _idCategoriaSeleccionada!,
      tokenJWT: widget.tokenJWT,
      tipo: _tipoSeleccionado, //ENVIAMOS EL TIPO A AWS
    );

    setState(() => _isSaving = false);

    if (exito) {
      Navigator.pop(context, true); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar en AWS.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nueva Transacción', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoadingCategorias
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. selector para Gasto vs Ingreso
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Gasto', style: TextStyle(fontWeight: FontWeight.bold))),
                          selected: _tipoSeleccionado == 'gasto',
                          selectedColor: Colors.black,
                          labelStyle: TextStyle(color: _tipoSeleccionado == 'gasto' ? Colors.white : Colors.black),
                          onSelected: (selected) {
                            if (selected) setState(() => _tipoSeleccionado = 'gasto');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Ingreso', style: TextStyle(fontWeight: FontWeight.bold))),
                          selected: _tipoSeleccionado == 'ingreso',
                          selectedColor: Colors.green.shade700,
                          labelStyle: TextStyle(color: _tipoSeleccionado == 'ingreso' ? Colors.white : Colors.black),
                          onSelected: (selected) {
                            if (selected) setState(() => _tipoSeleccionado = 'ingreso');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text('¿Qué cantidad?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _montoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      hintText: '0.00',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text('Categoría', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _idCategoriaSeleccionada,
                        isExpanded: true,
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
                  const Spacer(),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _guardarTransaccion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _tipoSeleccionado == 'gasto' ? Colors.black : Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Guardar ${_tipoSeleccionado == 'gasto' ? "Gasto" : "Ingreso"}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}