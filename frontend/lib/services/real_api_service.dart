// frontend/lib/services/real_api_service.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';
import '../enums/enums.dart';
import 'package:http_parser/http_parser.dart';
import '../services/google_sign_in_service.dart';


class RealApiService implements ApiService {
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';

  @override
  Future<dynamic> loginWithEmail({required String email}) async {
    final url = Uri.parse('$_baseUrl/auth/login?email=$email'); 

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);  // Retorna la respuesta completa
    } else if (response.statusCode == 404) {
      return null;  // Usuario no encontrado
    } else {
      throw Exception('Error al hacer login: ${response.body}');
    }
  }


  @override
  Future<dynamic> registerUser({
    required String email,
    required String username,
    required int edad,
    required String genero_pref,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/users');

    // Crear el cuerpo de la solicitud
    final body = jsonEncode({
      'email': email,
      'username': username,
      'edad': edad,
      'genero_pref': genero_pref,
    });

    // Enviar la solicitud POST con el cuerpo
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,  // Aquí estamos incluyendo el cuerpo con los datos
    );

    // Verificar la respuesta
    if (response.statusCode == 200) {
      return jsonDecode(response.body);  // Retorna la respuesta completa
    } else if (response.statusCode == 404) {
      return null;  // Usuario no encontrado
    } else {
      throw Exception('Error al hacer login: ${response.body}');
    }
  }


  @override
  Future<dynamic> checkUserExists({required String email}) async {
    final url = Uri.parse('$_baseUrl/auth/users/$email');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print('Usuario existe: ${response.body}');
      return jsonDecode(response.body); // Retorna la respuesta completa como un mapa
    } else if (response.statusCode == 404) {
      print("Usuario no existe");
      return null; // Retorna null si el usuario no existe
    } else {
      print("Error inesperado: ${response.statusCode}");
      throw Exception('Error al verificar usuario: ${response.body}');
    }
  }

  @override
  Future<String> ping() async {
    final url = Uri.parse('$_baseUrl/ping');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['message'];
    } else {
      throw Exception('Error en el ping');
    }
  }

  @override
  Future<void> guardarArticuloPropio({
    required Image foto,
    required String nombre,
    required CategoriaEnum categoria,
    SubcategoriaRopaEnum? subcategoriaRopa,
    SubcategoriaAccesoriosEnum? subcategoriaAccesorios,
    SubcategoriaCalzadoEnum? subcategoriaCalzado,
    required List<OcasionEnum> ocasiones,
    required List<TemporadaEnum> temporadas,
    required List<ColorEnum> colores,
  }) async {
    final url = Uri.parse('$_baseUrl/articulos-propios/');

    // Obtén el token desde GoogleSignInService
    final token = await GoogleSignInService().getToken();

    if (token == null) {
      throw Exception('No se pudo obtener el token. El usuario no está autenticado.');
    }

    final ImageProvider imageProvider = foto.image;
    final File? imageFile = await _getImageFileFromProvider(imageProvider);

    if (imageFile == null) {
      throw Exception('No se pudo obtener la imagen');
    }

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token'; // Usa el token en el encabezado

    request.files.add(await http.MultipartFile.fromPath(
      'foto',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    request.fields['nombre'] = nombre;
    request.fields['categoria'] = categoria.value;

    if (subcategoriaRopa != null) {
      request.fields['subcategoria_ropa'] = subcategoriaRopa.value;
    }
    if (subcategoriaCalzado != null) {
      request.fields['subcategoria_calzado'] = subcategoriaCalzado.value;
    }
    if (subcategoriaAccesorios != null) {
      request.fields['subcategoria_accesorios'] = subcategoriaAccesorios.value;
    }

    

    // Convertir las listas de enums a sus valores
    for (var o in ocasiones) {
      request.files.add(
        await http.MultipartFile.fromString('ocasiones[]', o.value),
      );
    }
    for (var t in temporadas) {
      request.files.add(
        await http.MultipartFile.fromString('temporadas[]', t.value),
      );
    }
    for (var c in colores) {
      request.files.add(
        await http.MultipartFile.fromString('colores[]', c.value),
      );
    }

    // TODO: Eliminar este print
    print(request.fields);

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = await response.stream.bytesToString();
      throw Exception('Error al guardar artículo: $body');
    }
  }


  Future<File?> _getImageFileFromProvider(ImageProvider provider) async {
    if (provider is FileImage) {
      return provider.file;
    }
    return null;
  }
}
