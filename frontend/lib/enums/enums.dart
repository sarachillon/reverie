enum OcasionEnum {
  Casual,
  Cena,
  Evento,
  Formal, 
  Trabajo_formal,
  Trabajo_informal,
}

extension OcasionEnumExtension on OcasionEnum {
  String get value {
    switch (this) {
      case OcasionEnum.Casual:
        return 'Casual';
      case OcasionEnum.Cena:
        return 'Cena';
      case OcasionEnum.Evento:
        return 'Evento';
      case OcasionEnum.Formal:
        return 'Formal';
      case OcasionEnum.Trabajo_formal:
        return 'Trabajo formal';
      case OcasionEnum.Trabajo_informal:
        return 'Trabajo informal';
    }
  }
}

enum CategoriaEnum {
  Ropa,
  Calzado,
  Accesorios,
}

extension CategoriaEnumExtension on CategoriaEnum {
  String get value {
    switch (this) {
      case CategoriaEnum.Ropa:
        return 'Ropa';
      case CategoriaEnum.Calzado:
        return 'Calzado';
      case CategoriaEnum.Accesorios:
        return 'Accesorios';
    }
  }
}

enum SubcategoriaRopaEnum {
  Camisas,
  Camisetas,
  FaldasCortas,
  FaldasLargas,
  Jerseis,
  Monos,
  Pantalones,
  Bermudas,
  Vaqueros,
  Trajes,
  VestidosCortos,
  VestidosLargos,
}

extension SubcategoriaRopaEnumExtension on SubcategoriaRopaEnum {
  String get value {
    switch (this) {
      case SubcategoriaRopaEnum.Camisas:
        return 'Camisas y blusas';
      case SubcategoriaRopaEnum.Camisetas:
        return 'Camisetas y tops';
      case SubcategoriaRopaEnum.FaldasCortas:
        return 'Faldas Cortas';
      case SubcategoriaRopaEnum.FaldasLargas:
        return 'Faldas Largas';
      case SubcategoriaRopaEnum.Jerseis:
        return 'Jerséis y sudaderas';
      case SubcategoriaRopaEnum.Monos:
        return 'Monos';
      case SubcategoriaRopaEnum.Pantalones:
        return 'Pantalones';
      case SubcategoriaRopaEnum.Bermudas:
        return 'Bermudas';
      case SubcategoriaRopaEnum.Vaqueros:
        return 'Vaqueros';
      case SubcategoriaRopaEnum.Trajes:
        return 'Trajes';
      case SubcategoriaRopaEnum.VestidosCortos:
        return 'Vestidos Cortos';
      case SubcategoriaRopaEnum.VestidosLargos:
        return 'Vestidos Largos';
    }
  }
}

enum SubcategoriaCalzadoEnum {
  Alpargatas,
  Bailarinas,
  Botas,
  Nauticos,
  Sandalias,
  Tacones,
  Zapatillas,
  Zapatos,
}

extension SubcategoriaCalzadoEnumExtension on SubcategoriaCalzadoEnum {
  String get value {
    switch (this) {
      case SubcategoriaCalzadoEnum.Alpargatas:
        return 'Alpargatas';
      case SubcategoriaCalzadoEnum.Bailarinas:
        return 'Bailarinas';
      case SubcategoriaCalzadoEnum.Botas:
        return 'Botas';
      case SubcategoriaCalzadoEnum.Nauticos:
        return 'Náuticos';
      case SubcategoriaCalzadoEnum.Sandalias:
        return 'Sandalias';
      case SubcategoriaCalzadoEnum.Tacones:
        return 'Tacones';
      case SubcategoriaCalzadoEnum.Zapatillas:
        return 'Zapatillas';
      case SubcategoriaCalzadoEnum.Zapatos:
        return 'Zapatos';
    }
  }
}

enum SubcategoriaAccesoriosEnum {
  Bufandas,
  Bolsos,
  Cinturones,
  Corbatas,
  Gafas,
  Mochilas,
  Relojes,
  Sombreros,
}

extension SubcategoriaAccesoriosEnumExtension on SubcategoriaAccesoriosEnum {
  String get value {
    switch (this) {
      case SubcategoriaAccesoriosEnum.Bufandas:
        return 'Bufandas';
      case SubcategoriaAccesoriosEnum.Bolsos:
        return 'Bolsos';
      case SubcategoriaAccesoriosEnum.Cinturones:
        return 'Cinturones';
      case SubcategoriaAccesoriosEnum.Corbatas:
        return 'Corbatas';
      case SubcategoriaAccesoriosEnum.Gafas:
        return 'Gafas';
      case SubcategoriaAccesoriosEnum.Mochilas:
        return 'Mochilas';
      case SubcategoriaAccesoriosEnum.Relojes:
        return 'Relojes';
      case SubcategoriaAccesoriosEnum.Sombreros:
        return 'Sombreros';
    }
  }
}

enum TemporadaEnum {
  Verano,
  Entretiempo,
  Invierno,
}

extension TemporadaEnumExtension on TemporadaEnum {
  String get value {
    switch (this) {
      case TemporadaEnum.Verano:
        return 'Verano';
      case TemporadaEnum.Entretiempo:
        return 'Entretiempo';
      case TemporadaEnum.Invierno:
        return 'Invierno';
    }
  }
}

enum ColorEnum {
  Amarillo,
  Naranja,
  Rojo,
  Rosa,
  Violeta,
  Azul,
  Verde,
  Marron,
  Gris,
  Blanco,
  Negro,
}

extension ColorEnumExtension on ColorEnum {
  String get value {
    switch (this) {
      case ColorEnum.Amarillo:
        return 'Amarillo';
      case ColorEnum.Naranja:
        return 'Naranja';
      case ColorEnum.Rojo:
        return 'Rojo';
      case ColorEnum.Rosa:
        return 'Rosa';
      case ColorEnum.Violeta:
        return 'Violeta';
      case ColorEnum.Azul:
        return 'Azul';
      case ColorEnum.Verde:
        return 'Verde';
      case ColorEnum.Marron:
        return 'Marrón';
      case ColorEnum.Gris:
        return 'Gris';
      case ColorEnum.Blanco:
        return 'Blanco';
      case ColorEnum.Negro:
        return 'Negro';
    }
  }
}

final Map<CategoriaEnum, List<dynamic>> subcategoriasPorCategoria = {
  CategoriaEnum.Ropa: SubcategoriaRopaEnum.values,
  CategoriaEnum.Calzado: SubcategoriaCalzadoEnum.values,
  CategoriaEnum.Accesorios: SubcategoriaAccesoriosEnum.values,
};