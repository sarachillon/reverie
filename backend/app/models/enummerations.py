from enum import Enum


class OcasionEnum(str, Enum):
    CASUAL = "Casual"
    CENA = "Cena"
    FORMAL = "Formal"
    TRABAJO_INFORMAL = "Trabajo informal"
    TRABAJO_FORMAL = "Trabajo formal (traje)"
    EVENTO = "Evento"

class CategoriaEnum(str, Enum):
    ROPA = "Ropa"
    CALZADO = "Calzado"
    ACCESORIOS = "Accesorios"

class SubcategoriaRopaEnum(str, Enum):
    CAMISAS = "Camisas y blusas"
    CAMISETAS = "Camisetas y tops"
    FALDAS_CORTAS = "Faldas cortas"
    FALDAS_LARGAS = "Faldas midi y largas"
    JERSEYS = "Jerséis y sudaderas"
    MONOS = "Monos"
    PANTALONES = "Pantalones"
    BERMUDAS = "Pantalones cortos y bermudas"
    VAQUEROS = "Pantalones vaqueros"
    TRAJES = "Trajes y blazers"
    VESTIDOS_CORTOS = "Vestidos cortos"
    VESTIDOS_LARGOS = "Vestidos largos"

class SubcategoriaCalzadoEnum(str, Enum):
    ALPARGATAS = "Alpargatas"
    BAILARINAS = "Bailarinas"
    BOTAS = "Botas"
    NAUTICOS = "Náuticos y mocasines"
    SANDALIAS = "Sandalias"
    TACONES = "Tacones"
    ZAPATILLAS = "Zapatillas"
    ZAPATOS = "Zapatos de vestir"

class SubcategoriaAccesoriosEnum(str, Enum):
    BUFANDAS = "Bufandas y pañuelos"
    CINTURONES = "Cinturones"
    CORBATAS = "Corbatas y pajaritas"
    GAFAS = "Gafas de sol"
    MOCHILAS = "Bolsos y mochilas"
    RELOJES = "Relojes"
    SOMBREROS = "Sombreros, gorras y gorros"

class TemporadaEnum(str, Enum):
    VERANO = "Verano"
    ENTRETIEMPO = "Entretiempo"
    INVIERNO = "Invierno"

class ColorEnum(str, Enum):
    AMARILLO = "Amarillo"
    NARANJA = "Naranja"
    ROJO = "Rojo"
    ROSA = "Rosa"
    VIOLETA = "Violeta"
    AZUL = "Azul"
    VERDE = "Verde"
    MARRON = "Marrón"
    GRIS = "Gris"
    BLANCO = "Blanco"
    NEGRO = "Negro"

class TipoInteraccionEnum(str, Enum):
    BUSQUEDA = "Búsqueda"
    CONSULTAR = "Consultar artículo"
    GUARDAR = "Guardar en coleccion"
    ENLACE = "Enlace de compra"

class GeneroPrefEnum(str, Enum):
    HOMBRE = "Hombre"
    MUJER = "Mujer"
    AMBOS = "Ambos"