// real_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RealApiService implements ApiService {
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';

  @override
  Future<void> registerUser({
    required String email,
    required String username,
    required int edad,
    required String genero_pref,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/users');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'edad': edad,
        'genero_pref': genero_pref,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al registrar usuario: ${response.body}');
    }
  }


  @override
  Future<bool> checkUserExists({required String email}) async {
    final url = Uri.parse('$_baseUrl/auth/users/$email');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print('Usuario existe: ${response.body}');
      return true;
    } else if (response.statusCode == 404) {
      print("Usuario no existe");
      return false;
    } else {
      print("Otro error");
      return false;
    }
  }



  Future<String> ping() async {
  final url = Uri.parse('$_baseUrl/ping');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return jsonDecode(response.body)['message'];
  } else {
    throw Exception('Error en el ping');
  }
}

}
