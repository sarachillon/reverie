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




 /*------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 -------------------FUNCIONES DE PERFIL------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------*/


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
    required GeneroPrefEnum genero_pref,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/users');

    final request = http.MultipartRequest('POST', url);

    request.fields['email'] = email;
    request.fields['username'] = username;
    request.fields['edad'] = edad.toString();
    request.fields['genero_pref'] = genero_pref.name;

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(responseBody);
    } else {
      print('Error del servidor: $responseBody');
      throw Exception('Error al registrar el usuario: $responseBody');
    }
  }



  @override
  Future<dynamic> checkUserExists({required String email}) async {
    final url = Uri.parse('$_baseUrl/auth/users/email/$email');
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
  Future<Map<String, dynamic>> getUsuarioActual() async {
    final token = await GoogleSignInService().getToken();
    if (token == null) throw Exception('Token no disponible');

    final response = await http.get(
      Uri.parse('$_baseUrl/auth/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener el usuario actual');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final token = await GoogleSignInService().getToken();
    if (token == null) throw Exception('Token no disponible');

    final response = await http.get(
      Uri.parse('$_baseUrl/auth/users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener todos los usuarios: ${response.body}');
    }
  }


  @override
  Future<Map<String, dynamic>> getUserById({required int id}) async {
    final token = await GoogleSignInService().getToken();
    if (token == null) throw Exception('Token no disponible');

    final response = await http.get(
      Uri.parse('$_baseUrl/auth/users/id/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener el usuario por ID');
    }
  }

  @override
  Future<void> editarPerfilUsuario({
    required String username,
    required int edad,
    required GeneroPrefEnum generoPref,
    File? fotoPerfil,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/users/editar');
    final token = await GoogleSignInService().getToken();

    if (token == null) throw Exception('No autenticado');

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['username'] = username;
    request.fields['edad'] = edad.toString();
    request.fields['genero_pref'] = generoPref.name;

    if (fotoPerfil != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'foto_perfil',
        fotoPerfil.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Error al editar perfil: $body');
    }
  }

  @override
  Future<void> eliminarCuenta() async {
    final token = await GoogleSignInService().getToken();
    if (token == null) throw Exception('Token no disponible');

    final response = await http.delete(
      Uri.parse('$_baseUrl/auth/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar cuenta: ${response.body}');
    }
  }


  @override
  Future<void> seguirUsuario(int idUsuario) async {
    final token = await GoogleSignInService().getToken();
    final url = Uri.parse('$_baseUrl/auth/users/$idUsuario/seguir');

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al seguir usuario: ${response.body}');
    }
  }

  @override
  Future<void> dejarDeSeguirUsuario(int idUsuario) async {
    final token = await GoogleSignInService().getToken();
    final url = Uri.parse('$_baseUrl/auth/users/$idUsuario/dejar_de_seguir');

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al dejar de seguir usuario: ${response.body}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> obtenerSeguidos(int idUsuario) async {
    final token = await GoogleSignInService().getToken();
    final url = Uri.parse('$_baseUrl/auth/users/$idUsuario/seguidos');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener seguidos: ${response.body}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> obtenerSeguidores(int idUsuario) async {
    final token = await GoogleSignInService().getToken();
    final url = Uri.parse('$_baseUrl/auth/users/$idUsuario/seguidores');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener seguidores: ${response.body}');
    }
  }

  


 /*------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 -------------------FUNCIONES DE ARTICULOS---------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------*/


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
  Future<void> guardarArticuloPropioDesdeArchivo({
    required File imagenFile,
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
    final token = await GoogleSignInService().getToken();

    if (token == null) throw Exception('Token no disponible');

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['nombre'] = nombre;
    request.fields['categoria'] = categoria.name;

    if (subcategoriaRopa != null) {
      request.fields['subcategoria_ropa'] = subcategoriaRopa.name;
    }
    if (subcategoriaAccesorios != null) {
      request.fields['subcategoria_accesorios'] = subcategoriaAccesorios.name;
    }
    if (subcategoriaCalzado != null) {
      request.fields['subcategoria_calzado'] = subcategoriaCalzado.name;
    }

    for (final o in ocasiones) {
      request.fields['ocasiones[]'] = o.name;
    }
    for (final t in temporadas) {
      request.fields['temporadas[]'] = t.name;
    }
    for (final c in colores) {
      request.fields['colores[]'] = c.name;
    }

    request.files.add(await http.MultipartFile.fromPath(
      'foto',
      imagenFile.path,
      contentType: MediaType('image', 'png'),
    ));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al guardar el artículo: $body');
    }
  }

  @override
  Future<Map<String, dynamic>> getArticuloPropioPorId({
    required int id,
  }) async {
    final token = await GoogleSignInService().getToken();
    if (token == null) throw Exception('Usuario no autenticado');
    final uri = Uri.parse('$_baseUrl/articulos-propios/$id');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 404) {
      throw Exception('Artículo no encontrado');
    } else {
      throw Exception('Error al obtener artículo: ${response.body}');
    }
  }


@override
Stream<dynamic> getArticulosPropiosStream({Map<String, dynamic>? filtros}) async* {
  final queryParams = <String>[];

  if (filtros != null) {
    queryParams.addAll(
      filtros.entries
          .where((e) => e.value != null)
          .expand((e) {
            if (e.value is List) {
              return (e.value as List).map((v) => '${e.key}=$v');
            } else {
              return ['${e.key}=${e.value}'];
            }
          }),
    );
  }

  final queryString = queryParams.join('&');

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


  @override
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


  @override
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


  @override
  Future<int> getNumeroArticulos({int? usuarioId, String? categoria}) async {
  final token = await GoogleSignInService().getToken();

  final queryParams = {
    if (usuarioId != null) 'usuario_id': usuarioId.toString(),
    if (categoria != null) 'categoria': categoria,
  };

  final uri = Uri.parse('$_baseUrl/articulos-propios/count').replace(queryParameters: queryParams);

  final response = await http.get(uri, headers: {
    'Authorization': 'Bearer $token',
  });

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['total'] as int;
  } else {
    throw Exception('Error al obtener número de artículos');
  }
}


Future<List<Map<String, dynamic>>> getTodosLosArticulosDeBD() async {
  final response = await http.get(Uri.parse('$_baseUrl/articulos-propios/all-with-url'));
  if (response.statusCode != 200) throw Exception('Error al obtener artículos');
  final List data = jsonDecode(response.body);
  return data.cast<Map<String, dynamic>>();
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
    int? articulo_fijo_id,
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
      request.files.add(
        await http.MultipartFile.fromString('ocasiones[]', o.name),
      );
    }

    if (temporadas != null) {
      for (final t in temporadas) {
        request.files.add(
          await http.MultipartFile.fromString('temporadas[]', t.name),
        );
      }
    }

    if (colores != null) {
      for (final c in colores) {
        request.files.add(
          await http.MultipartFile.fromString('colores[]', c.name),
        );
      }
    }

    print('articulo_fijo_id: $articulo_fijo_id');
    if (articulo_fijo_id != null) {
      request.fields['articuloFijoId'] = articulo_fijo_id.toString();
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


  @override
  Stream<Map<String, dynamic>> getFeedOutfitsStream({
    int page = 0,
    int pageSize = 6,
    required String type,
  }) async* {
    final token = await GoogleSignInService().getToken();
    if (token == null) throw Exception('Token no disponible');

    final endpoint = type == 'seguidos' ? 'feed/seguidos' : 'feed/global';
    final url = Uri.parse('$_baseUrl/outfits/$endpoint?page=$page&page_size=$pageSize');

    final request = http.Request('GET', url);
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
      throw Exception('Error al cargar feed: ${response.statusCode} ${await response.stream.bytesToString()}');
    }
  }


  @override
  Future<int> getNumeroOutfits({int? usuarioId}) async {
  final token = await GoogleSignInService().getToken();
  final uri = Uri.parse(
    usuarioId != null
      ? '$_baseUrl/outfits/count?usuario_id=$usuarioId'
      : '$_baseUrl/outfits/count',
  );

  final response = await http.get(uri, headers: {
    'Authorization': 'Bearer $token',
  });

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['total'] as int;
  } else {
    throw Exception('Error al obtener número de outfits');
  }
}


  @override
  Future<bool> crearOutfitManual({
    required String titulo,
    required List<OcasionEnum> ocasiones,
    required List<Map<String, dynamic>> items,
    required String imagenBase64,
  }) async {
    final token = await GoogleSignInService().getToken();
    if (token == null) {
      throw Exception('Usuario no autenticado');
    }

    final url = Uri.parse('$_baseUrl/outfits/manual');
    final body = {
      'titulo': titulo,
      'ocasiones': ocasiones.map((o) => o.name).toList(),
      'items': items,
      'imagen_base64': imagenBase64,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final msg = response.body.isNotEmpty ? response.body : response.statusCode.toString();
      throw Exception('Error al guardar outfit manual: $msg');
    }
  }

@override
Future<bool> editarCollageOutfitPropio({
  required int outfitId,
  required List<Map<String, dynamic>> items,
  required String imagenBase64,
}) async {
  final token = await GoogleSignInService().getToken();
  if (token == null) {
    throw Exception('Usuario no autenticado');
  }

  // OJO: comillas dobles y sin barra invertida
  final url = Uri.parse('$_baseUrl/outfits/editcollage/$outfitId');
  final body = {
    'items': items,
    'imagen_base64': imagenBase64,
  };

  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // <- Correcto aquí
    },
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    final msg = response.body.isNotEmpty ? response.body : response.statusCode.toString();
    throw Exception('Error al editar collage outfit: $msg');
  }
}


  @override
  Future<Map<String, dynamic>> getOutfitById({required int id}) async {
    final token = await GoogleSignInService().getToken();
    if (token == null) {
      throw Exception('Usuario no autenticado');
    }

    final url = Uri.parse('$_baseUrl/outfits/$id');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // El endpoint devuelve un JSON que se ajusta a OutfitPropioConUsuarioResponse
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al obtener outfit: ${response.body}');
    }
  }


  @override
  Future<void> editarOutfitPropio({
    required int id,
    String? titulo,
    String? descripcion,
    List<OcasionEnum>? ocasiones,
    List<TemporadaEnum>? temporadas,
    List<ColorEnum>? colores,
  }) async {
    final token = await GoogleSignInService().getToken();
    if (token == null) throw Exception('Usuario no autenticado');

    final url = Uri.parse('$_baseUrl/outfits/$id');
    final Map<String, dynamic> body = {};
    if (titulo != null) body['titulo'] = titulo;
    if (descripcion != null) body['descripcion'] = descripcion;
    if (ocasiones != null) body['ocasiones'] = ocasiones.map((e) => e.name).toList();
    if (temporadas != null) body['temporadas'] = temporadas.map((e) => e.name).toList();
    if (colores != null) body['colores'] = colores.map((e) => e.name).toList();

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al editar outfit: ${response.body}');
    }
  }
















  // Colecciones


  @override
  Future<void> crearColeccion({
    required String nombre,
    required int userId,
    int? outfitId, // <-- único outfitId opcional
  }) async {
    final token = await GoogleSignInService().getToken();
    if (token == null) throw Exception('Usuario no autenticado');

    final url = Uri.parse('$_baseUrl/colecciones/');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['nombre'] = nombre
      ..fields['userId'] = userId.toString();

    if (outfitId != null) {
      request.fields['outfitId'] = outfitId.toString();
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Error al crear colección: ${response.body}');
    }
  }


  @override
  Future<List<Map<String, dynamic>>> obtenerColeccionesDeUsuario(int userId) async {
    final token = await GoogleSignInService().getToken();
    if (token == null) throw Exception('Usuario no autenticado');

    final url = Uri.parse('$_baseUrl/colecciones/usuario/$userId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener colecciones: ${response.body}');
    }
  }


  @override
  Future<void> addOutfitColeccion({required int coleccionId, required int outfitId}) async {
    final token = await GoogleSignInService().getToken();
    if (token == null) throw Exception('Usuario no autenticado');

    final url = Uri.parse('$_baseUrl/colecciones/$coleccionId/add_outfit');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['outfit_id'] = outfitId.toString();

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Error al añadir outfit: ${response.body}');
    }
  }

  @override
Future<void> deleteColeccion({required int coleccionId}) async {
  final token = await GoogleSignInService().getToken();
  if (token == null) throw Exception('Usuario no autenticado');

  final url = Uri.parse('$_baseUrl/colecciones/$coleccionId');
  final response = await http.delete(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Error al eliminar colección: ${response.body}');
  }
}

@override
Future<void> removeOutfitDeColeccion({
  required int coleccionId,
  required int outfitId,
}) async {
  final token = await GoogleSignInService().getToken();
  if (token == null) throw Exception('Usuario no autenticado');

  final url = Uri.parse(
    '$_baseUrl/colecciones/$coleccionId/remove_outfit?outfit_id=$outfitId',
  );

  final response = await http.delete(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode != 200) {
    throw Exception('Error al eliminar outfit de colección: ${response.body}');
  }
}


}