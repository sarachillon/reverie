// frontend/lib/enums/enums.dart
enum OcasionEnum {
  CASUAL,
  CENA,
  EVENTO,
  FORMAL, 
  TRABAJO_FORMAL,
  TRABAJO_INFORMAL,
}

extension OcasionEnumExtension on OcasionEnum {
  String get value {
    switch (this) {
      case OcasionEnum.CASUAL:
        return 'Casual';
      case OcasionEnum.CENA:
        return 'Cena';
      case OcasionEnum.EVENTO:
        return 'Evento';
      case OcasionEnum.FORMAL:
        return 'Formal';
      case OcasionEnum.TRABAJO_FORMAL:
        return 'Trabajo formal (traje)';
      case OcasionEnum.TRABAJO_INFORMAL:
        return 'Trabajo informal';
    }
  }
}

enum GeneroPrefEnum {
  HOMBRE,
  MUJER,
  AMBOS,
}

extension GeneroPrefEnumExtension on GeneroPrefEnum {
  String get value {
    switch (this) {
      case GeneroPrefEnum.HOMBRE:
        return 'Hombre';
      case GeneroPrefEnum.MUJER:
        return 'Mujer';
      case GeneroPrefEnum.AMBOS:
        return 'Ambos';
    }
  }
}

enum CategoriaEnum {
  ROPA,
  CALZADO,
  ACCESORIOS,
}

extension CategoriaEnumExtension on CategoriaEnum {
  String get value {
    switch (this) {
      case CategoriaEnum.ROPA:
        return 'Ropa';
      case CategoriaEnum.CALZADO:
        return 'Calzado';
      case CategoriaEnum.ACCESORIOS:
        return 'Accesorios';
    }
  }
}

enum SubcategoriaRopaEnum {
  CAMISAS,
  CAMISETAS,
  FALDAS_CORTAS,
  FALDAS_LARGAS,
  JERSEYS,
  MONOS,
  PANTALONES,
  BERMUDAS,
  VAQUEROS,
  TRAJES,
  VESTIDOS_CORTOS,
  VESTIDOS_LARGOS,
}

extension SubcategoriaRopaEnumExtension on SubcategoriaRopaEnum {
  String get value {
    switch (this) {
      case SubcategoriaRopaEnum.CAMISAS:
        return 'Camisas y blusas';
      case SubcategoriaRopaEnum.CAMISETAS:
        return 'Camisetas y tops';
      case SubcategoriaRopaEnum.FALDAS_CORTAS:
        return 'Faldas cortas';
      case SubcategoriaRopaEnum.FALDAS_LARGAS:
        return 'Faldas midi y largas';
      case SubcategoriaRopaEnum.JERSEYS:
        return 'Jerséis y sudaderas';
      case SubcategoriaRopaEnum.MONOS:
        return 'Monos';
      case SubcategoriaRopaEnum.PANTALONES:
        return 'Pantalones';
      case SubcategoriaRopaEnum.BERMUDAS:
        return 'Pantalones cortos y bermudas';
      case SubcategoriaRopaEnum.VAQUEROS:
        return 'Pantalones vaqueros';
      case SubcategoriaRopaEnum.TRAJES:
        return 'Trajes y blazers';
      case SubcategoriaRopaEnum.VESTIDOS_CORTOS:
        return 'Vestidos cortos';
      case SubcategoriaRopaEnum.VESTIDOS_LARGOS:
        return 'Vestidos largos';
    }
  }
}

enum SubcategoriaCalzadoEnum {
  ALPARGATAS,
  BAILARINAS,  
  BOTAS,
  NAUTICOS,
  SANDALIAS,
  TACONES,
  ZAPATILLAS,
  ZAPATOS,
}

extension SubcategoriaCalzadoEnumExtension on SubcategoriaCalzadoEnum {
  String get value {
    switch (this) {
      case SubcategoriaCalzadoEnum.ALPARGATAS:
        return 'Alpargatas';
      case SubcategoriaCalzadoEnum.BAILARINAS:
        return 'Bailarinas';
      case SubcategoriaCalzadoEnum.BOTAS:
        return 'Botas';
      case SubcategoriaCalzadoEnum.NAUTICOS:
        return 'Náuticos y mocasines';
      case SubcategoriaCalzadoEnum.SANDALIAS:
        return 'Sandalias';
      case SubcategoriaCalzadoEnum.TACONES:
        return 'Tacones';
      case SubcategoriaCalzadoEnum.ZAPATILLAS:
        return 'Zapatillas';
      case SubcategoriaCalzadoEnum.ZAPATOS:
        return 'Zapatos de vestir';
    }
  }
}

enum SubcategoriaAccesoriosEnum {
  BUFANDAS,
  CINTURONES,
  CORBATAS,
  GAFAS,
  MOCHILAS,
  RELOJES,
  SOMBREROS,
}

extension SubcategoriaAccesoriosEnumExtension on SubcategoriaAccesoriosEnum {
  String get value {
    switch (this) {
      case SubcategoriaAccesoriosEnum.BUFANDAS:
        return 'Bufandas y pañuelos';
      case SubcategoriaAccesoriosEnum.MOCHILAS:
        return 'Bolsos y mochilas';
      case SubcategoriaAccesoriosEnum.CINTURONES:
        return 'Cinturones';
      case SubcategoriaAccesoriosEnum.CORBATAS:
        return 'Corbatas y pajaritas';
      case SubcategoriaAccesoriosEnum.GAFAS:
        return 'Gafas de sol';
      case SubcategoriaAccesoriosEnum.RELOJES:
        return 'Relojes';
      case SubcategoriaAccesoriosEnum.SOMBREROS:
        return 'Sombreros, gorras y gorros';
    }
  }
}

enum TemporadaEnum {
  VERANO,
  ENTRETIEMPO,
  INVIERNO,
}

extension TemporadaEnumExtension on TemporadaEnum {
  String get value {
    switch (this) {
      case TemporadaEnum.VERANO:
        return 'Verano';
      case TemporadaEnum.ENTRETIEMPO:
        return 'Entretiempo';
      case TemporadaEnum.INVIERNO:
        return 'Invierno';
    }
  }
}

enum ColorEnum {
  AMARILLO,
  NARANJA,
  ROJO,
  ROSA,
  VIOLETA,
  AZUL,
  VERDE,
  MARRON,
  GRIS,
  BLANCO,
  NEGRO,
}

extension ColorEnumExtension on ColorEnum {
  String get value {
    switch (this) {
      case ColorEnum.AMARILLO:
        return 'Amarillo';
      case ColorEnum.NARANJA:
        return 'Naranja';
      case ColorEnum.ROJO:
        return 'Rojo';
      case ColorEnum.ROSA:
        return 'Rosa';
      case ColorEnum.VIOLETA:
        return 'Violeta';
      case ColorEnum.AZUL:
        return 'Azul';
      case ColorEnum.VERDE:
        return 'Verde';
      case ColorEnum.MARRON:
        return 'Marrón';
      case ColorEnum.GRIS:
        return 'Gris';
      case ColorEnum.BLANCO:
        return 'Blanco';
      case ColorEnum.NEGRO:
        return 'Negro';
    }
  }
}

final Map<CategoriaEnum, List<dynamic>> subcategoriasPorCategoria = {
  CategoriaEnum.ROPA: SubcategoriaRopaEnum.values,
  CategoriaEnum.CALZADO: SubcategoriaCalzadoEnum.values,
  CategoriaEnum.ACCESORIOS: SubcategoriaAccesoriosEnum.values,
};