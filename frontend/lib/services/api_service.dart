// frontend/lib/services/api_service.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';

abstract class ApiService {
  Future<String> ping();


  // USUARIOS

  Future<dynamic> loginWithEmail({required String email});

  Future<dynamic> registerUser({
    required String email,
    required String username,
    required int edad,
    required GeneroPrefEnum genero_pref,
  });

  Future<dynamic> checkUserExists({required String email});

  Future<Map<String, dynamic>> getUsuarioActual();

  Future<List<Map<String, dynamic>>> getAllUsers();

  Future<Map<String, dynamic>> getUserById({required int id});

  Future<void> editarPerfilUsuario({
    required String username,
    required int edad,
    required GeneroPrefEnum generoPref,
    File? fotoPerfil,
  });

  Future<void> seguirUsuario(int idUsuario);
  Future<void> dejarDeSeguirUsuario(int idUsuario);
  Future<List<Map<String, dynamic>>> obtenerSeguidos(int idUsuario);
  Future<List<Map<String, dynamic>>> obtenerSeguidores(int idUsuario);

  Future<void> eliminarCuenta();

  // ARTICULOS 

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
  });

  
  Future<List<dynamic>> getArticulosPropiosPorNombre({required String nombre});

  Stream<dynamic> getArticulosPropiosStream({Map<String, dynamic>? filtros});

  Future<void> deleteArticuloPropio({required int id});

  Future<File?> procesarImagen({required File imagenOriginal});

  Future<Map<String, dynamic>> generarOutfitPropio({required String titulo, String? descripcion, required List<OcasionEnum> ocasiones, List<TemporadaEnum>? temporadas, List<ColorEnum>? colores});

  Future<void> editarArticuloPropio({required int id, Image? foto, String? nombre, CategoriaEnum? categoria, SubcategoriaRopaEnum? subcategoriaRopa, SubcategoriaAccesoriosEnum? subcategoriaAccesorios, SubcategoriaCalzadoEnum? subcategoriaCalzado, List<OcasionEnum>? ocasiones, List<TemporadaEnum>? temporadas, List<ColorEnum>? colores });

  Future<void> guardarArticuloPropioDesdeArchivo({ required File imagenFile, required String nombre, required CategoriaEnum categoria, SubcategoriaRopaEnum? subcategoriaRopa, SubcategoriaAccesoriosEnum? subcategoriaAccesorios, SubcategoriaCalzadoEnum? subcategoriaCalzado, required List<OcasionEnum> ocasiones, required List<TemporadaEnum> temporadas, required List<ColorEnum> colores});


  // OUTFITS 

  Stream<dynamic> getOutfitsPropiosStream({Map<String, dynamic>? filtros});

  Future<void> deleteOutfitPropio({required int id});

  Stream<Map<String, dynamic>> getFeedOutfitsStream({int page = 0, int pageSize = 6, required String type,});

  Future<int> getNumeroOutfits({int? usuarioId});
  
  Future<int> getNumeroArticulos({int? usuarioId, String? categoria}) ;

 Future<bool> crearOutfitManual({ required String titulo,required List<OcasionEnum> ocasiones,required List<Map<String, dynamic>> items,required String imagenBase64,});

Future<bool> editarCollageOutfitPropio({required int outfitId,required List<Map<String, dynamic>> items,required String imagenBase64,});

   Future<Map<String, dynamic>> getArticuloPropioPorId({required int id,});

   Future<Map<String, dynamic>> getOutfitById({required int id});

   Future<List<Map<String, dynamic>>> getTodosLosArticulosDeBD();

   Future<void> editarOutfitPropio({required int id,String? titulo,String? descripcion,List<OcasionEnum>? ocasiones,List<TemporadaEnum>? temporadas,List<ColorEnum>? colores,});
}
