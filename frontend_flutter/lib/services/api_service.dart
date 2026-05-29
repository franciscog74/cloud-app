import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://backend:3000/api';
  final Duration _timeout = const Duration(seconds: 10);

  Future<void> registrarGasto({
    required double monto,
    required int idCategoria,
    required String tokenJWT,
    required String tipo,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/gastos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tokenJWT',
      },
      body: jsonEncode({
        'monto': monto,
        'categoria_id': idCategoria,
        'tipo': tipo,
      }),
    ).timeout(_timeout);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al registrar $tipo: HTTP ${response.statusCode}');
    }
  }

  Future<List<dynamic>> obtenerGastos(String tokenJWT) async {
    final response = await http.get(
      Uri.parse('$baseUrl/gastos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tokenJWT',
      },
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    } else {
      throw Exception('Error al obtener gastos: HTTP ${response.statusCode}');
    }
  }

  Future<void> eliminarGasto(int id, String tokenJWT) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/gastos/$id'),
      headers: {
        'Authorization': 'Bearer $tokenJWT',
      },
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar gasto: HTTP ${response.statusCode}');
    }
  }

  Future<List<dynamic>> obtenerCategorias(String tokenJWT) async {
    final url = Uri.parse('$baseUrl/categorias');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $tokenJWT',
        'Content-Type': 'application/json',
      },
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener categorías: HTTP ${response.statusCode}');
    }
  }

  Future<void> crearCategoria(String tokenJWT, String nombre, String colorHex) async {
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
    ).timeout(_timeout);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear categoría: HTTP ${response.statusCode}');
    }
  }

  Future<void> actualizarCategoria(String tokenJWT, int id, String nombre, String colorHex) async {
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
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar categoría: HTTP ${response.statusCode}');
    }
  }

  Future<void> eliminarCategoria(String tokenJWT, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/categorias/$id'),
      headers: {
        'Authorization': 'Bearer $tokenJWT',
      },
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar categoría: HTTP ${response.statusCode}');
    }
  }
}