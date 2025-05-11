// frontend/lib/services/real_api_service.dart

import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    request.fields['categoria'] = categoria.name;

    if (subcategoriaRopa != null) {
      request.fields['subcategoria_ropa'] = subcategoriaRopa.name;
    }
    if (subcategoriaCalzado != null) {
      request.fields['subcategoria_calzado'] = subcategoriaCalzado.name;
    }
    if (subcategoriaAccesorios != null) {
      request.fields['subcategoria_accesorios'] = subcategoriaAccesorios.name;
    }

    

    // Convertir las listas de enums a sus valores
    for (var o in ocasiones) {
      request.files.add(
        await http.MultipartFile.fromString('ocasiones[]', o.name),
      );
    }
    for (var t in temporadas) {
      request.files.add(
        await http.MultipartFile.fromString('temporadas[]', t.name),
      );
    }
    for (var c in colores) {
      request.files.add(
        await http.MultipartFile.fromString('colores[]', c.name),
      );
    }

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = await response.stream.bytesToString();
      throw Exception('Error al guardar artículo: $body');
    }
  }

  @override
  Future<List<dynamic>> getArticulosPropios({Map<String, dynamic>? filtros}) async {
  final queryString = filtros != null
        ? filtros.entries
            .where((e) => e.value != null)
            .expand((e) {
              if (e.value is List) {
                return (e.value as List).map((v) => '${e.key}=$v');
              } else {
                return ['${e.key}=${e.value}'];
              }
            })
            .join('&')
        : '';

    final token = await GoogleSignInService().getToken();
    if (token == null) {
      throw Exception('No se pudo obtener el token. El usuario no está autenticado.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/articulos-propios/?$queryString'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> articulos = [];
      bool streamSuccess = true;

      final byteStream = Stream.fromIterable([response.bodyBytes]);
      final responseBody = byteStream.transform(
          StreamTransformer.fromBind(utf8.decoder.bind)).transform(const LineSplitter());

      await for (final data in responseBody) {
        if (data.isNotEmpty) {
          final decodedData = jsonDecode(data);
          if (decodedData is Map<String, dynamic> && decodedData.containsKey("error")) {
            // Handle error object
            print("Error from stream: ${decodedData["error"]}");
            streamSuccess = false;
            // You might want to log this or take other actions
          } else if (decodedData is Map<String, dynamic> && decodedData.containsKey("stream_status")) {
            if (decodedData["stream_status"] != "success") {
              streamSuccess = false;
            }
          }
          else {
            articulos.add(decodedData);
          }
        }
      }

      if (!streamSuccess) {
        // Handle the partial failure scenario
        print("Stream completed with errors. Some data might be incomplete.");
      }

      return articulos;

    } else {
      throw Exception('Error al cargar artículos');
    }
  }


  @override
  Stream<dynamic> getArticulosPropiosStream({Map<String, dynamic>? filtros}) async* {
    final queryString = filtros != null
        ? filtros.entries
            .where((e) => e.value != null)
            .expand((e) {
              if (e.value is List) {
                return (e.value as List).map((v) => '${e.key}=$v');
              } else {
                return ['${e.key}=${e.value}'];
              }
            })
            .join('&')
        : '';

    final token = await GoogleSignInService().getToken();
    if (token == null) {
      throw Exception('No se pudo obtener el token. El usuario no está autenticado.');
    }

    final request = http.Request(
      'GET',
      Uri.parse('$_baseUrl/articulos-propios/stream?$queryString'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    final response = await request.send();

    if (response.statusCode == 200) {
      final utf8Stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());
      await for (final line in utf8Stream) {
        if (line.isNotEmpty) {
          yield jsonDecode(line);
        }
      }
    } else {
      throw Exception('Error al cargar artículos (stream)');
    }
  }


  @override
  Future<List<dynamic>> getArticulosPropiosPorNombre({required String nombre}) async {
    final token = await GoogleSignInService().getToken();
    if (token == null) {
      throw Exception('No se pudo obtener el token. El usuario no está autenticado.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/articulos-propios/?nombre=$nombre'),
      headers: {
        'Authorization': 'Bearer $token', 
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Error al cargar artículos');
    }
  }


  Future<File?> _getImageFileFromProvider(ImageProvider provider) async {
    if (provider is FileImage) {
      return provider.file;
    }
    return null;
  }


  @override
  Future<void> deleteArticuloPropio({required int id}) async {
    final url = Uri.parse('$_baseUrl/articulos-propios/$id');

    // Obtén el token desde GoogleSignInService
    final token = await GoogleSignInService().getToken();

    if (token == null) {
      throw Exception('No se pudo obtener el token. El usuario no está autenticado.');
    }

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar artículo: ${response.body}');
    }
  }

  Future<void> editarArticuloPropio({
    required int id,
    Image? foto,
    String? nombre,
    CategoriaEnum? categoria,
    SubcategoriaRopaEnum? subcategoriaRopa,
    SubcategoriaAccesoriosEnum? subcategoriaAccesorios,
    SubcategoriaCalzadoEnum? subcategoriaCalzado,
    List<OcasionEnum>? ocasiones,
    List<TemporadaEnum>? temporadas,
    List<ColorEnum>? colores,
  }) async {
    final url = Uri.parse('$_baseUrl/articulos-propios/editar/$id');
    final token = await GoogleSignInService().getToken();

    if (token == null) {
      throw Exception('No se pudo obtener el token. El usuario no está autenticado.');
    }

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    if (foto != null) {
      final imageProvider = foto.image;
      final file = await _getImageFileFromProvider(imageProvider);
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }
    }

    if (nombre != null) request.fields['nombre'] = nombre;
    if (categoria != null) request.fields['categoria'] = categoria.name;
    if (subcategoriaRopa != null) request.fields['subcategoria_ropa'] = subcategoriaRopa.name;
    if (subcategoriaCalzado != null) request.fields['subcategoria_calzado'] = subcategoriaCalzado.name;
    if (subcategoriaAccesorios != null) request.fields['subcategoria_accesorios'] = subcategoriaAccesorios.name;

    if (ocasiones != null) {
      for (var o in ocasiones) {
        request.files.add(await http.MultipartFile.fromString('ocasiones[]', o.name));
      }
    }

    if (temporadas != null) {
      for (var t in temporadas) {
        request.files.add(await http.MultipartFile.fromString('temporadas[]', t.name));
      }
    }

    if (colores != null) {
      for (var c in colores) {
        request.files.add(await http.MultipartFile.fromString('colores[]', c.name));
      }
    }

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = await response.stream.bytesToString();
      throw Exception('Error al editar artículo: $body');
    }
  }

  Future<File?> procesarImagen({required File imagenOriginal}) async {
    final url = Uri.parse('$_baseUrl/imagen/procesar');
    final token = await GoogleSignInService().getToken();

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('foto', imagenOriginal.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final decoded = jsonDecode(body);
      final base64Str = decoded['imagen_base64'] as String;
      final bytes = base64Decode(base64Str);

      final tempDir = Directory.systemTemp;
      final processedFile = File('${tempDir.path}/sin_fondo_${DateTime.now().millisecondsSinceEpoch}.png');
      print(base64Str);
      return await processedFile.writeAsBytes(bytes);
    } else {
      final error = await response.stream.bytesToString();
      print("Error al procesar imagen: $error");
      return null;
    }
  }



 /*------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 -------------------FUNCIONES DE OUTFITS-----------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------*/

  @override
  Future<Map<String, dynamic>> generarOutfitPropio({
    required String titulo,
    String? descripcion,
    required List<OcasionEnum> ocasiones,
    List<TemporadaEnum>? temporadas,
    List<ColorEnum>? colores,
  }) async {
    final url = Uri.parse('$_baseUrl/outfits/generar');

    final token = await GoogleSignInService().getToken();
    if (token == null) {
      throw Exception('No se pudo obtener el token. El usuario no está autenticado.');
    }

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['titulo'] = titulo;
    if (descripcion != null && descripcion.isNotEmpty) {
      request.fields['descripcion'] = descripcion;
    }
    
    for (final o in ocasiones) {
        request.fields['ocasiones[]'] = o.name;
      }

    if (temporadas != null) {
      for (final t in temporadas) {
        request.fields['temporadas[]'] = t.name;
      }
    }

    if (colores != null) {
      for (final c in colores) {
        request.fields['colores[]'] = c.name;
      }
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('Error al generar outfit: $responseBody');
    }
  }


  @override
  Stream<dynamic> getOutfitsPropiosStream({Map<String, dynamic>? filtros}) async* {
    final queryString = filtros != null
        ? filtros.entries
            .where((e) => e.value != null)
            .expand((e) {
              if (e.value is List) {
                return (e.value as List).map((v) => '${e.key}=$v');
              } else {
                return ['${e.key}=${e.value}'];
              }
            })
            .join('&')
        : '';

    final token = await GoogleSignInService().getToken();
    if (token == null) {
      throw Exception('No se pudo obtener el token. El usuario no está autenticado.');
    }

   final request = http.Request(
      'GET',
      Uri.parse(queryString.isNotEmpty
        ? '$_baseUrl/outfits/stream?$queryString'
        : '$_baseUrl/outfits/stream')
    );
    request.headers['Authorization'] = 'Bearer $token';

    final response = await request.send();

    if (response.statusCode == 200) {
      final utf8Stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());
      await for (final line in utf8Stream) {
        if (line.isNotEmpty) {
          yield jsonDecode(line);
        }
      }
    } else {
      throw Exception('Error al cargar outfits (stream)');
    }
  }

  
  @override
  Future<void> deleteOutfitPropio({required int id}) async {
    final url = Uri.parse('$_baseUrl/outfits/$id');

    // Obtén el token desde GoogleSignInService
    final token = await GoogleSignInService().getToken();

    if (token == null) {
      throw Exception('No se pudo obtener el token. El usuario no está autenticado.');
    }

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar artículo: ${response.body}');
    }
  }
}