from enum import Enum


class OcasionEnum(str, Enum):
    CASUAL = "CASUAL"
    CENA = "CENA"
    FORMAL = "FORMAL"
    TRABAJO_INFORMAL = "TRABAJO_INFORMAL"
    TRABAJO_FORMAL = "TRABAJO_FORMAL"
    EVENTO = "EVENTO"

class CategoriaEnum(str, Enum):
    ROPA = "ROPA"
    CALZADO = "CALZADO"
    ACCESORIOS = "ACCESORIOS"

class SubcategoriaRopaEnum(str, Enum):
    CAMISAS = "CAMISAS"
    CAMISETAS = "CAMISETAS"
    FALDAS_CORTAS = "FALDAS_CORTAS"
    FALDAS_LARGAS = "FALDAS_LARGAS"
    JERSEYS = "JERSEYS"
    MONOS = "MONOS"
    PANTALONES = "PANTALONES"
    BERMUDAS = "BERMUDAS"
    VAQUEROS = "VAQUEROS"
    TRAJES = "TRAJES"
    VESTIDOS_CORTOS = "VESTIDOS_CORTOS"
    VESTIDOS_LARGOS = "VESTIDOS_LARGOS"

class SubcategoriaCalzadoEnum(str, Enum):
    ALPARGATAS = "ALPARGATAS"
    BAILARINAS = "BAILARINAS"
    BOTAS = "BOTAS"
    NAUTICOS = "NAUTICOS"
    SANDALIAS = "SANDALIAS"
    TACONES = "TACONES"
    ZAPATILLAS = "ZAPATILLAS"
    ZAPATOS = "ZAPATOS"

class SubcategoriaAccesoriosEnum(str, Enum):
    BISUTERIA = "BISUTERIA"
    BUFANDAS = "BUFANDAS"
    CINTURONES = "CINTURONES"
    CORBATAS = "CORBATAS"
    GAFAS = "GAFAS"
    MOCHILAS = "MOCHILAS"
    RELOJES = "RELOJES"
    SOMBREROS = "SOMBREROS"

class TemporadaEnum(str, Enum):
    VERANO = "VERANO"
    ENTRETIEMPO = "ENTRETIEMPO"
    INVIERNO = "INVIERNO"

class ColorEnum(str, Enum):
    AMARILLO = "AMARILLO"
    NARANJA = "NARANJA"
    ROJO = "ROJO"
    ROSA = "ROSA"
    VIOLETA = "VIOLETA"
    GRANATE = "GRANATE"
    AZUL = "AZUL"
    VERDE = "VERDE"
    MARRON = "MARRON"
    GRIS = "GRIS"
    BLANCO = "BLANCO"
    NEGRO = "NEGRO"
    DORADO = "DORADO"
    PLATEADO = "PLATEADO"

class GeneroPrefEnum(str, Enum):
    HOMBRE = "HOMBRE"
    MUJER = "MUJER"
    AMBOS = "AMBOS"

class EstiloEnum(str, Enum):
    BOHO = "boho"
    STREET = "street"
    MINIMAL = "minimal"
    ELEGANT = "elegant"
    SPORTY = "sporty"
    PUNK = "punk"
    FORMAL = "formal"
    CASUAL = "casual"
    BEACH = "beach"
