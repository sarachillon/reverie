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
    int? articulo_fijo_id,
  }) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.generarOutfitPropio(titulo: titulo, descripcion: descripcion, ocasiones: ocasiones, temporadas: temporadas, colores: colores, articulo_fijo_id: articulo_fijo_id); 
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

Stream<Map<String, dynamic>> getFeedOutfitsStream({
    int page = 0,
    int pageSize = 6,
    required String type,
  }) async* {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    yield* _instance!.getFeedOutfitsStream(page: page, pageSize: pageSize, type: type);
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

  Future<void> editarPerfilUsuario({
    required String username,
    required int edad,
    required GeneroPrefEnum generoPref,
    File? fotoPerfil,
  }) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    await _instance!.editarPerfilUsuario(username: username, edad: edad, generoPref: generoPref, fotoPerfil: fotoPerfil);
  }

  
  Future<List<Map<String, dynamic>>> obtenerSeguidos(int idUsuario) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.obtenerSeguidos(idUsuario);
  }
  Future<List<Map<String, dynamic>>> obtenerSeguidores(int idUsuario) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.obtenerSeguidores(idUsuario);
  }
  Future<void> seguirUsuario(int idUsuario) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    await _instance!.seguirUsuario(idUsuario);
  }
  Future<void> dejarDeSeguirUsuario(int idUsuario) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    await _instance!.dejarDeSeguirUsuario(idUsuario);
  }


  Future<int> getNumeroOutfits({int? usuarioId}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.getNumeroOutfits(usuarioId: usuarioId);
  }
  Future<int> getNumeroArticulos({int? usuarioId}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.getNumeroArticulos(usuarioId: usuarioId);
  }

    Future<void> guardarArticuloPropioDesdeArchivo({ required File imagenFile, required String nombre, required CategoriaEnum categoria, SubcategoriaRopaEnum? subcategoriaRopa, SubcategoriaAccesoriosEnum? subcategoriaAccesorios, SubcategoriaCalzadoEnum? subcategoriaCalzado, required List<OcasionEnum> ocasiones, required List<TemporadaEnum> temporadas, required List<ColorEnum> colores}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    await _instance!.guardarArticuloPropioDesdeArchivo(
      imagenFile: imagenFile,
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

  Future<void> eliminarCuenta() async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    await _instance!.eliminarCuenta();
  }

   Future<bool> crearOutfitManual({
    required String titulo,
    required List<OcasionEnum> ocasiones,
    required List<Map<String, dynamic>> items,
    required String imagenBase64,
  }) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.crearOutfitManual(titulo: titulo, ocasiones: ocasiones, items: items, imagenBase64: imagenBase64);
  }

  Future<bool> editarCollageOutfitPropio({required int outfitId,required List<Map<String, dynamic>> items,required String imagenBase64,}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.editarCollageOutfitPropio(outfitId: outfitId,items: items,imagenBase64: imagenBase64);
  }

   Future<Map<String, dynamic>> getArticuloPropioPorId({required int id,}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.getArticuloPropioPorId(id: id);
  }

  Future<Map<String, dynamic>> getOutfitById({required int id}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.getOutfitById(id: id);
  }

  Future<List<Map<String, dynamic>>> getTodosLosArticulosDeBD() async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.getTodosLosArticulosDeBD();
  }

  Future<void> editarOutfitPropio({required int id,String? titulo,String? descripcion,List<OcasionEnum>? ocasiones,List<TemporadaEnum>? temporadas,List<ColorEnum>? colores,}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.editarOutfitPropio(id: id, titulo: titulo, descripcion: descripcion, ocasiones: ocasiones, temporadas: temporadas, colores: colores);
  }




  // COLECCIONES
  Future<void> crearColeccion({required String nombre, required int userId, int? outfitId}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.crearColeccion(nombre: nombre, userId: userId, outfitId: outfitId);
  }


  Future<List<Map<String, dynamic>>> obtenerColeccionesDeUsuario(int userId) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.obtenerColeccionesDeUsuario(userId);
  }


  Future<void> addOutfitColeccion({required int coleccionId, required int outfitId}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.addOutfitColeccion(coleccionId: coleccionId, outfitId: outfitId);
  }

  Future<void> deleteColeccion({required int coleccionId}) async {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.deleteColeccion(coleccionId: coleccionId);
  }

  Future<void> removeOutfitDeColeccion({required int coleccionId, required int outfitId}) {
    if (_instance == null) {
      throw Exception("ApiManager no ha sido inicializado. Llama a getInstance primero.");
    }
    return _instance!.removeOutfitDeColeccion(coleccionId: coleccionId, outfitId: outfitId);
  }







}
