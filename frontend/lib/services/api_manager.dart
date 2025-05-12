import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:frontend/enums/enums.dart';
import 'real_api_service.dart';
import 'mock_api_service.dart';
import 'api_service.dart';

class ApiManager {
  static ApiService? _instance;

  // Obtiene la instancia de ApiService (Mock o Real) según el email
  static ApiService getInstance({required String email}) {
    if (_instance != null) return _instance!;

    // Si es email de prueba se usa el mock, sino el real
    if (email == 'testing.reverie@gmail.com') {
      _instance = MockApiService();
    } else {
      _instance = RealApiService();
    }

    return _instance!;
  }

  // Para resetear si se cambia de usuario
  static void reset() {
    _instance = null;
  }

  Future<dynamic> checkUserExists({required String email}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.checkUserExists(email: email);
  }

  Future<void> guardarArticuloPropio({
    required Image foto, // Para manejar imágenes desde galería/cámara
    required String nombre,
    required CategoriaEnum categoria,
    SubcategoriaRopaEnum? subcategoriaRopa,
    SubcategoriaAccesoriosEnum? subcategoriaAccesorios,
    SubcategoriaCalzadoEnum? subcategoriaCalzado,
    required List<OcasionEnum> ocasiones,
    required List<TemporadaEnum> temporadas,
    required List<ColorEnum> colores,
  }) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }

    await _instance!.guardarArticuloPropio(
      foto: foto,
      nombre: nombre,
      categoria: categoria,
      subcategoriaRopa: subcategoriaRopa,
      subcategoriaAccesorios: subcategoriaAccesorios,
      subcategoriaCalzado: subcategoriaCalzado,
      ocasiones: ocasiones,
      temporadas: temporadas,
      colores: colores,
    );
  }

  Future<List<dynamic>> getArticulosPropios({Map<String, dynamic>? filtros}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.getArticulosPropios(filtros: filtros);
  }


  Future<List<dynamic>> getArticulosPropiosPorNombre({required String nombre}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.getArticulosPropiosPorNombre(nombre: nombre);
  }


  Stream<dynamic> getArticulosPropiosStream({Map<String, dynamic>? filtros}) async* {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    yield* _instance!.getArticulosPropiosStream(filtros: filtros);
  }

  Future<void> deleteArticuloPropio({required int id}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    await _instance!.deleteArticuloPropio(id: id);
  }

  Future<File?> procesarImagen({required File imagenOriginal}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.procesarImagen(imagenOriginal: imagenOriginal);
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
     if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.editarArticuloPropio(id: id, foto: foto, nombre: nombre, categoria: categoria, subcategoriaAccesorios: subcategoriaAccesorios, subcategoriaCalzado: subcategoriaCalzado, subcategoriaRopa: subcategoriaRopa, ocasiones: ocasiones, temporadas: temporadas, colores: colores); 
  }

  // OUTFITS 

  Future<Map<String, dynamic>> generarOutfitPropio({
    required String titulo,
    String? descripcion,
    required List<OcasionEnum> ocasiones,
    List<TemporadaEnum>? temporadas,
    List<ColorEnum>? colores,
  }) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.generarOutfitPropio(titulo: titulo, descripcion: descripcion, ocasiones: ocasiones, temporadas: temporadas, colores: colores); 
  }



  Stream<dynamic> getOutfitsPropiosStream({Map<String, dynamic>? filtros}) async* {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    yield* _instance!.getOutfitsPropiosStream(filtros: filtros);
  }


  Future<void> deleteOutfitPropio({required int id}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    await _instance!.deleteOutfitPropio(id: id);
  }

  Future<List<Map<String, dynamic>>> getFeedOutfits({int page = 0, int pageSize = 20}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.getFeedOutfits();
  
  }



  /*USUARIOS*/

  Future<dynamic> registerUser({
    required String email,
    required String username,
    required int edad,
    required GeneroPrefEnum genero_pref,
  }) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.registerUser(email: email, username: username, edad: edad, genero_pref: genero_pref);
  }

  Future<Map<String, dynamic>> getUsuarioActual() async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.getUsuarioActual();
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    } else {
      return _instance!.getAllUsers();
    }
  }

  Future<Map<String, dynamic>> getUserById({required int id}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.getUserById(id: id);
  }

}
