import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'api_service.dart';

class MockApiService implements ApiService {
  Map<String, dynamic>? fakeUser;


  @override
  Future<dynamic> loginWithEmail({required String email}) async {
    // Simulación de respuesta de inicio de sesión
    if (email == "testing.reverie@gmail.com") {
      return {
        'access_token': 'fake_access_token_123',
        'user_id': 'fake_user_id_123',
      };
    }
    return null;
  }

  @override
  Future<dynamic> registerUser({
    required String email,
    required String username,
    required int edad,
    required String genero_pref,
  }) async {
    return {
        'access_token': 'fake_access_token_123',
        'user_id': 'fake_user_id_123',
      };
  }

  @override
  Future<dynamic> checkUserExists({required String email}) async {
    if (email == "testing.reverie@gmail.com") {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<String> ping() async {
    return 'Pong!';
  }

  @override
  Future<void> guardarArticuloPropio({
    required Image foto,
    required String nombre,
    required CategoriaEnum categoria,
    SubcategoriaRopaEnum? subcategoriaRopa,
    SubcategoriaAccesoriosEnum? subcategoriaAccesorios,
    SubcategoriaCalzadoEnum? subcategoriaCalzado,
    required List<TemporadaEnum> temporadas,
    required List<ColorEnum> colores,
  }) async {
    // Valores de prueba
    final Image fotoPrueba = Image.asset('assets/logo.png');
    final String nombrePrueba = "Camiseta de prueba";
    final CategoriaEnum categoriaPrueba = CategoriaEnum.Ropa; 
    final SubcategoriaRopaEnum subcategoriaRopaPrueba = SubcategoriaRopaEnum.Camisas;
    final List<TemporadaEnum> temporadasPrueba = [TemporadaEnum.Verano, TemporadaEnum.Entretiempo];
    final List<ColorEnum> coloresPrueba = [ColorEnum.Azul, ColorEnum.Blanco];

    // Simulación de guardar el artículo
    print("Guardando artículo con los siguientes valores de prueba:");
    print("Foto: $fotoPrueba");
    print("Nombre: $nombrePrueba");
    print("Categoría: $categoriaPrueba");
    print("Subcategoría Ropa: $subcategoriaRopaPrueba");
    print("Temporadas: $temporadasPrueba");
    print("Colores: $coloresPrueba");
  }
}
