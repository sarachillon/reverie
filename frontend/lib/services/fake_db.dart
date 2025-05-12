import 'package:frontend/enums/enums.dart';
import 'package:flutter/services.dart' show rootBundle;

late final String fake_articulo;
late final String fake_outfit;

Future<void> cargarBase64() async {
  fake_articulo = (await rootBundle.loadString('assets/mock/fake_articulo.txt')).replaceAll('\n', '').replaceAll('\r', '');
  fake_outfit = (await rootBundle.loadString('assets/mock/fake_outfit.txt')).replaceAll('\n', '').replaceAll('\r', '');
}



final List<Map<String, dynamic>> fakeUsuarios = List.generate(5, (i) => {
  'id': i + 1,
  'username': 'user${i + 1}',
  'email': 'user${i + 1}@example.com',
  'edad': 20 + i,
  'genero_pref': GeneroPrefEnum.values[i % GeneroPrefEnum.values.length].name,
});

final List<Map<String, dynamic>> fakeArticulos = List.generate(15, (i) => {
  'id': i + 1,
  'nombre': 'Artículo ${i + 1}',
  'foto_url': 'https://example.com/articulo${i + 1}.png',
  'imagen': fake_articulo,
  'categoria': CategoriaEnum.ROPA.name,
  'subcategoriaRopa': SubcategoriaRopaEnum.values[i % SubcategoriaRopaEnum.values.length].name,
  'colores': [ColorEnum.values[i % ColorEnum.values.length].name],
  'temporadas': [TemporadaEnum.values[i % TemporadaEnum.values.length].name],
  'ocasiones': [OcasionEnum.values[i % OcasionEnum.values.length].name],
  'usuario_id': (i % 5) + 1,
});

final List<Map<String, dynamic>> fakeOutfits = [
  {
    'id': 1,
    'titulo': 'Casual Azul',
    'descripcion': 'Ideal para días normales',
    'imagen': fake_outfit,
    'ocasiones': [OcasionEnum.CASUAL.name],
    'temporadas': [TemporadaEnum.VERANO.name],
    'colores': [ColorEnum.AZUL.name],
    'articulos_propios': fakeArticulos.where((a) => [1, 2, 3].contains(a['id'])).toList(),
  },
  {
    'id': 2,
    'titulo': 'Formal Invierno',
    'descripcion': 'Perfecto para el trabajo',
    'imagen': fake_outfit,
    'ocasiones': [OcasionEnum.TRABAJO_FORMAL.name],
    'temporadas': [TemporadaEnum.INVIERNO.name],
    'colores': [ColorEnum.NEGRO.name],
    'articulos_propios': fakeArticulos.where((a) => [4, 5, 6].contains(a['id'])).toList(),
  },
  {
    'id': 3,
    'titulo': 'Relax Otoño',
    'descripcion': 'Para salir a pasear',
    'imagen': fake_outfit,
    'ocasiones': [OcasionEnum.CASUAL.name],
    'temporadas': [TemporadaEnum.VERANO.name],
    'colores': [ColorEnum.MARRON.name],
    'articulos_propios': fakeArticulos.where((a) => [7, 8, 9].contains(a['id'])).toList(),
  },
];
