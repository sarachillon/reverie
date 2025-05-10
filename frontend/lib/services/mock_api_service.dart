import 'dart:io';

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
    required List<OcasionEnum> ocasiones,
    required List<TemporadaEnum> temporadas,
    required List<ColorEnum> colores,
  }) async {
    // Valores de prueba
    final Image fotoPrueba = Image.asset('assets/logo.png');
    final String nombrePrueba = "Camiseta de prueba";
    final CategoriaEnum categoriaPrueba = CategoriaEnum.ROPA; 
    final SubcategoriaRopaEnum subcategoriaRopaPrueba = SubcategoriaRopaEnum.CAMISAS;
    final List<TemporadaEnum> temporadasPrueba = [TemporadaEnum.VERANO, TemporadaEnum.ENTRETIEMPO];
    final List<ColorEnum> coloresPrueba = [ColorEnum.AZUL, ColorEnum.BLANCO];

    // Simulación de guardar el artículo
    print("Guardando artículo con los siguientes valores de prueba:");
    print("Foto: $fotoPrueba");
    print("Nombre: $nombrePrueba");
    print("Categoría: $categoriaPrueba");
    print("Subcategoría Ropa: $subcategoriaRopaPrueba");
    print("Temporadas: $temporadasPrueba");
    print("Colores: $coloresPrueba");
  }


  @override
  Future<List<dynamic>> getArticulosPropios({Map<String, dynamic>? filtros}) async {
    // Simulación de respuesta de artículos propios
    return [
      {
        'nombre': 'Camiseta de prueba',
        'fotoUrl': 'iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAIAAAD/gAIDAAB1n0lEQVR4nAGUdWuKAU9t0COB8wRjXneXlWJc3/ici+6eC4qBBsud9x6GzNrA/EYBOQffXkcSNssH7AIUeTstAqsDeuFYWV6ozxvLtKUj7cbxw7TIh8LzsKUEuUdbInd0UhiHwFVwSJOIDzEIC7FlD/5v+MZ8CykBX2v+VSy84s0R8lPQkX8jL70Xey9RNP2984l4Yzuc/aFfKuZ3I2Y9ufm5YDmreejP7Cej+B4RUDgVTReQw9uKV93T+92k',
        'categoria': CategoriaEnum.ROPA.name,
        'subcategoriaRopa': SubcategoriaRopaEnum.CAMISAS.name,
        'ocasiones': [OcasionEnum.CASUAL.name],
        'temporadas': [TemporadaEnum.VERANO.name],
        'colores': [ColorEnum.AZUL.name],

      },
      {
        'nombre': 'Pantalones de prueba',
        'fotoUrl': 'iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAIAAAD/gAIDAAB1n0lEQVR4nAGUdWuKAU9t0COB8wRjXneXlWJc3/ici+6eC4qBBsud9x6GzNrA/EYBOQffXkcSNssH7AIUeTstAqsDeuFYWV6ozxvLtKUj7cbxw7TIh8LzsKUEuUdbInd0UhiHwFVwSJOIDzEIC7FlD/5v+MZ8CykBX2v+VSy84s0R8lPQkX8jL70Xey9RNP2984l4Yzuc/aFfKuZ3I2Y9ufm5YDmreejP7Cej+B4RUDgVTReQw9uKV93T+92k',
        'categoria': CategoriaEnum.ROPA.name,
        'subcategoriaRopa': SubcategoriaRopaEnum.PANTALONES.name,
        'ocasiones': [OcasionEnum.TRABAJO_FORMAL.name],
        'temporadas': [TemporadaEnum.INVIERNO.name],
        'colores': [ColorEnum.ROJO.name],
      },
    ];
  }

  @override
  Future<List<dynamic>> getArticulosPropiosPorNombre({required String nombre}) async {
    // Simulación de respuesta de artículos propios por nombre
    return [
      {
        'nombre': 'Camiseta de prueba',
        'fotoUrl': 'iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAIAAAD/gAIDAAB1n0lEQVR4nAGUdWuKAU9t0COB8wRjXneXlWJc3/ici+6eC4qBBsud9x6GzNrA/EYBOQffXkcSNssH7AIUeTstAqsDeuFYWV6ozxvLtKUj7cbxw7TIh8LzsKUEuUdbInd0UhiHwFVwSJOIDzEIC7FlD/5v+MZ8CykBX2v+VSy84s0R8lPQkX8jL70Xey9RNP2984l4Yzuc/aFfKuZ3I2Y9ufm5YDmreejP7Cej+B4RUDgVTReQw9uKV93T+92k',
        'categoria': CategoriaEnum.ROPA.name,
        'subcategoriaRopa': SubcategoriaRopaEnum.CAMISAS.name,
        'ocasiones': [OcasionEnum.CASUAL.name],
        'temporadas': [TemporadaEnum.VERANO.name],
        'colores': [ColorEnum.AZUL.name],

      },
    ];
  }



  @override
  Stream<dynamic> getArticulosPropiosStream({Map<String, dynamic>? filtros}) async* {
    final articulos = [
        {
          'nombre': 'Camiseta de prueba',
          'fotoUrl': 'iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAIAAAD/gAIDAAB1n0lEQVR4nAGUdWuKAU9t0COB8wRjXneXlWJc3/ici+6eC4qBBsud9x6GzNrA/EYBOQffXkcSNssH7AIUeTstAqsDeuFYWV6ozxvLtKUj7cbxw7TIh8LzsKUEuUdbInd0UhiHwFVwSJOIDzEIC7FlD/5v+MZ8CykBX2v+VSy84s0R8lPQkX8jL70Xey9RNP2984l4Yzuc/aFfKuZ3I2Y9ufm5YDmreejP7Cej+B4RUDgVTReQw9uKV93T+92k',
          'categoria': CategoriaEnum.ROPA.name,
          'subcategoriaRopa': SubcategoriaRopaEnum.CAMISAS.name,
          'ocasiones': [OcasionEnum.CASUAL.name],
          'temporadas': [TemporadaEnum.VERANO.name],
          'colores': [ColorEnum.AZUL.name],
        },
        {
          'nombre': 'Pantalones de prueba',
          'fotoUrl': 'iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAIAAAD/gAIDAAB1n0lEQVR4nAGUdWuKAU9t0COB8wRjXneXlWJc3/ici+6eC4qBBsud9x6GzNrA/EYBOQffXkcSNssH7AIUeTstAqsDeuFYWV6ozxvLtKUj7cbxw7TIh8LzsKUEuUdbInd0UhiHwFVwSJOIDzEIC7FlD/5v+MZ8CykBX2v+VSy84s0R8lPQkX8jL70Xey9RNP2984l4Yzuc/aFfKuZ3I2Y9ufm5YDmreejP7Cej+B4RUDgVTReQw9uKV93T+92k',
          'categoria': CategoriaEnum.ROPA.name,
          'subcategoriaRopa': SubcategoriaRopaEnum.PANTALONES.name,
          'ocasiones': [OcasionEnum.TRABAJO_FORMAL.name],
          'temporadas': [TemporadaEnum.INVIERNO.name],
          'colores': [ColorEnum.ROJO.name],
        },
    ];
    
    for (final articulo in articulos) {
      yield articulo;
    }
  }

  @override
  Future<void> deleteArticuloPropio({required int id}) async {
    // Simulación de eliminación de un artículo propio
    print("Artículo con ID $id eliminado.");
  }

  @override
  Future<Map<String, dynamic>> generarOutfitPropio({
    required String titulo,
    String? descripcion,
    required List<OcasionEnum> ocasiones,
    List<TemporadaEnum>? temporadas,
    List<ColorEnum>? colores,
  }) async {

    return {
      "id": 999,
      "titulo": titulo,
      "descripcion": descripcion ?? "Outfit generado automáticamente",
      "articulos": [
        {
          "id": 1,
          "nombre": "Camiseta blanca",
          "foto_url": "https://example.com/mock/camiseta.png",
          "categoria": CategoriaEnum.ROPA,
          "subcategoria_ropa": SubcategoriaRopaEnum.CAMISETAS,
          "colores": [ColorEnum.AZUL],
          "temporadas": [TemporadaEnum.ENTRETIEMPO],
          "ocasiones": [OcasionEnum.CASUAL],
        },
        {
          "id": 2,
          "nombre": "Pantalón negro",
          "foto_url": "https://example.com/mock/pantalon.png",
          "categoria": CategoriaEnum.ROPA,
          "subcategoria_ropa": SubcategoriaRopaEnum.PANTALONES,
          "colores": [ColorEnum.GRIS],
          "temporadas": [TemporadaEnum.ENTRETIEMPO],
          "ocasiones": [OcasionEnum.CASUAL],
        }
      ]
    };
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
    final Image fotoPrueba = Image.asset('assets/logo.png');
    final String nombrePrueba = "Camiseta de prueba";
    final CategoriaEnum categoriaPrueba = CategoriaEnum.ROPA; 
    final SubcategoriaRopaEnum subcategoriaRopaPrueba = SubcategoriaRopaEnum.CAMISAS;
    final List<TemporadaEnum> temporadasPrueba = [TemporadaEnum.VERANO, TemporadaEnum.ENTRETIEMPO];
    final List<ColorEnum> coloresPrueba = [ColorEnum.AZUL, ColorEnum.BLANCO];

    // Simulación de guardar el artículo
    print("Guardando artículo con los siguientes valores de prueba:");
    print("Foto: $fotoPrueba");
    print("Nombre: $nombrePrueba");
    print("Categoría: $categoriaPrueba");
    print("Subcategoría Ropa: $subcategoriaRopaPrueba");
    print("Temporadas: $temporadasPrueba");
    print("Colores: $coloresPrueba");
  }



  @override
  Stream<dynamic> getOutfitsPropiosStream({Map<String, dynamic>? filtros}) async* {
    final outfits = [
      {
        'titulo': 'Outfit Casual Verano',
        'descripcion': 'Ideal para días soleados',
        'imagen': 'iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAIAAAD/gAIDAAB1n0lEQVR4nAGUdWuKAU9t0COB8wRjXneXlWJc3/ici+6eC4qBBsud9x6GzNrA/EYBOQffXkcSNssH7AIUeTstAqsDeuFYWV6ozxvLtKUj7cbxw7TIh8LzsKUEuUdbInd0UhiHwFVwSJOIDzEIC7FlD/5v+MZ8CykBX2v+VSy84s0R8lPQkX8jL70Xey9RNP2984l4Yzuc/aFfKuZ3I2Y9ufm5YDmreejP7Cej+B4RUDgVTReQw9uKV93T+92k',
        'ocasiones': [OcasionEnum.CASUAL.name],
        'temporadas': [TemporadaEnum.VERANO.name],
        'colores': [ColorEnum.AZUL.name],
        'articulos_propios': [
          {
            'nombre': 'Camiseta Azul',
            'imagen': 'iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAIAAAD/gAIDAAB1n0lEQVR4nAGUdWuKAU9t0COB8wRjXneXlWJc3/ici+6eC4qBBsud9x6GzNrA/EYBOQffXkcSNssH7AIUeTstAqsDeuFYWV6ozxvLtKUj7cbxw7TIh8LzsKUEuUdbInd0UhiHwFVwSJOIDzEIC7FlD/5v+MZ8CykBX2v+VSy84s0R8lPQkX8jL70Xey9RNP2984l4Yzuc/aFfKuZ3I2Y9ufm5YDmreejP7Cej+B4RUDgVTReQw9uKV93T+92k',
            'subcategoria': SubcategoriaRopaEnum.CAMISETAS.name,
          },
          {
            'nombre': 'Pantalón Rojo',
            'imagen': 'iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAIAAAD/gAIDAAB1n0lEQVR4nAGUdWuKAU9t0COB8wRjXneXlWJc3/ici+6eC4qBBsud9x6GzNrA/EYBOQffXkcSNssH7AIUeTstAqsDeuFYWV6ozxvLtKUj7cbxw7TIh8LzsKUEuUdbInd0UhiHwFVwSJOIDzEIC7FlD/5v+MZ8CykBX2v+VSy84s0R8lPQkX8jL70Xey9RNP2984l4Yzuc/aFfKuZ3I2Y9ufm5YDmreejP7Cej+B4RUDgVTReQw9uKV93T+92k',
            'subcategoria': SubcategoriaRopaEnum.PANTALONES.name,
          },
        ],
      },
      {
        'titulo': 'Outfit Formal Invierno',
        'descripcion': 'Perfecto para reuniones de trabajo',
        'imagen': 'iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAIAAAD/gAIDAAB1n0lEQVR4nAGUdWuKAU9t0COB8wRjXneXlWJc3/ici+6eC4qBBsud9x6GzNrA/EYBOQffXkcSNssH7AIUeTstAqsDeuFYWV6ozxvLtKUj7cbxw7TIh8LzsKUEuUdbInd0UhiHwFVwSJOIDzEIC7FlD/5v+MZ8CykBX2v+VSy84s0R8lPQkX8jL70Xey9RNP2984l4Yzuc/aFfKuZ3I2Y9ufm5YDmreejP7Cej+B4RUDgVTReQw9uKV93T+92k',
        'ocasiones': [OcasionEnum.TRABAJO_FORMAL.name],
        'temporadas': [TemporadaEnum.INVIERNO.name],
        'colores': [ColorEnum.ROJO.name],
        'articulos_propios': [],
      },
    ];

    for (final outfit in outfits) {
      yield outfit;
    }
  }


  Future<File?> procesarImagen({required File imagenOriginal}) async {
    return File('assets/logo.png');
  }

}
