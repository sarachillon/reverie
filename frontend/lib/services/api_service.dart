// frontend/lib/services/api_service.dart

import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';

abstract class ApiService {
  Future<String> ping();

  Future<dynamic> loginWithEmail({required String email});

  Future<dynamic> registerUser({
    required String email,
    required String username,
    required int edad,
    required String genero_pref,
  });

  Future<dynamic> checkUserExists({required String email});
  
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

  Future<List<dynamic>> getArticulosPropios({Map<String, dynamic>? filtros});
  
  Future<List<dynamic>> getArticulosPropiosPorNombre({required String nombre});

  Stream<dynamic> getArticulosPropiosStream({Map<String, dynamic>? filtros});
}
