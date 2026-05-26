import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // servidor EC2, FALTA esto por la IP pública de la instancia EC2
  final String baseUrl = 'http://localhost:3000/api'; 

  // --- MÉTODOS DE GASTOS E INGRESOS ---

  // Guardar un gasto o ingreso en AWS
  Future<bool> registrarGasto({
    required double monto,
    required int idCategoria,
    required String tokenJWT,
    required String tipo, // Recibe si es gasto o ingreso
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/gastos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenJWT',
        },
        body: jsonEncode({
          'monto': monto,
          'categoria_id': idCategoria, 
          'fecha': DateTime.now().toIso8601String(),
          'tipo': tipo, // Se envía a backend en Node.js
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error de conexión registrarGasto: $e');
      return false;
    }
  }

  // Leer historial de transacciones desde AWS
  Future<List<dynamic>> obtenerGastos(String tokenJWT) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/gastos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenJWT',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List;
      } else {
        print('Error del servidor al obtener gastos: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error de conexión obtenerGastos: $e');
      return [];
    }
  }

  // Eliminar una transacción en AWS
  Future<bool> eliminarGasto(int id, String tokenJWT) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/gastos/$id'),
        headers: {
          'Authorization': 'Bearer $tokenJWT',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error de conexión eliminarGasto: $e');
      return false;
    }
  }

  // --- MÉTODOS DE CATEGORÍAS ---

  // Función para obtener las categorías actuales desde el Backend
  Future<List<dynamic>> obtenerCategorias(String tokenJWT) async {
    try {
      final url = Uri.parse('$baseUrl/categorias'); 
      
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $tokenJWT',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error en API de categorías: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error de conexión al obtener categorías: $e');
      return [];
    }
  }

  // Crear una nueva categoría
  Future<bool> crearCategoria(String tokenJWT, String nombre, String colorHex) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/categorias'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenJWT',
        },
        body: jsonEncode({
          'nombre': nombre,
          'colorHex': colorHex,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error de conexión crearCategoria: $e');
      return false;
    }
  }

  // Actualizar una categoría existente
  Future<bool> actualizarCategoria(String tokenJWT, int id, String nombre, String colorHex) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/categorias/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenJWT',
        },
        body: jsonEncode({
          'nombre': nombre,
          'colorHex': colorHex,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error de conexión actualizarCategoria: $e');
      return false;
    }
  }

  // Eliminar una categoría
  Future<bool> eliminarCategoria(String tokenJWT, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/categorias/$id'),
        headers: {
          'Authorization': 'Bearer $tokenJWT',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error de conexión eliminarCategoria: $e');
      return false;
    }
  }
}