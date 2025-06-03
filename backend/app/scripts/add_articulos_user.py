import os
from datetime import datetime
from typing import Dict, List, Tuple
from concurrent.futures import ThreadPoolExecutor

import requests
from dotenv import load_dotenv

# ────────────────────────────────────────────────────────────────────────────────
# CONFIGURACIÓN
# ────────────────────────────────────────────────────────────────────────────────
load_dotenv()

BASE_URL: str = os.getenv("API_URL", "http://localhost:8000")
API_TOKEN: str = os.getenv("API_TOKEN", "")

if not API_TOKEN:
    raise RuntimeError("API_TOKEN no definido; ponlo en .env o expórtalo.")

HEADERS = {"Authorization": f"Bearer {API_TOKEN}"}
ENDPOINT_ARTICULOS = f"{BASE_URL}/articulos-propios/from-key"  # ruta del router


USUARIO_ID = 7  

# ----------------------------------------------------------------------------------
# DATOS DE LOS ARTÍCULOS A IMPORTAR
# Cada entrada debe respetar el esquema que tu backend espere.
# ----------------------------------------------------------------------------------
ARTICULOS: List[Dict] = [
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Pantalones lino grises",
        "keyImagen": "articulos_propios/sin_fondo_1747844912390.png",
        "categoria": "ROPA",
        "subcategoria": "PANTALONES",
        "ocasiones": ["CASUAL", "TRABAJO_INFORMAL", "CENA"],
        "temporadas": ["VERANO"],
        "colores": ["GRIS"],
        "estilo": "boho",
        "formalidad": 4,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Pantalones lino negros",
        "keyImagen": "articulos_propios/sin_fondo_1747844972022.png",
        "categoria": "ROPA",
        "subcategoria": "PANTALONES",
        "ocasiones": ["CASUAL", "CENA", "TRABAJO_INFORMAL"],
        "temporadas": ["VERANO"],
        "colores": ["NEGRO"],
        "estilo": "boho",
        "formalidad": 4,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Adidas blancas",
        "keyImagen": "articulos_propios/sin_fondo_1747847642816.png",
        "categoria": "CALZADO",
        "subcategoria": "ZAPATILLAS",
        "ocasiones": ["CASUAL", "TRABAJO_INFORMAL"],
        "temporadas": ["VERANO", "ENTRETIEMPO", "INVIERNO"],
        "colores": ["BLANCO", "NEGRO"],
        "estilo": "punk",
        "formalidad": 2,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Adidas grises",
        "keyImagen": "articulos_propios/sin_fondo_1747847728526.png",
        "categoria": "CALZADO",
        "subcategoria": "ZAPATILLAS",
        "ocasiones": ["CASUAL", "TRABAJO_INFORMAL"],
        "temporadas": ["VERANO", "ENTRETIEMPO", "INVIERNO"],
        "colores": ["GRIS"],
        "estilo": "sporty",
        "formalidad": 3,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Addias verdes",
        "keyImagen": "articulos_propios/sin_fondo_1747849400262.png",
        "categoria": "CALZADO",
        "subcategoria": "ZAPATILLAS",
        "ocasiones": ["CASUAL", "CENA", "TRABAJO_INFORMAL"],
        "temporadas": ["VERANO", "ENTRETIEMPO", "INVIERNO"],
        "colores": ["VERDE"],
        "estilo": "sporty",
        "formalidad": 3,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Top negro",
        "keyImagen": "articulos_propios/sin_fondo_1747928265006.png",
        "categoria": "ROPA",
        "subcategoria": "CAMISETAS",
        "ocasiones": ["CASUAL", "CENA", "TRABAJO_INFORMAL"],
        "temporadas": ["VERANO", "ENTRETIEMPO"],
        "colores": ["NEGRO"],
        "estilo": "minimal",
        "formalidad": 6,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Vaqueros azules tiro alto",
        "keyImagen": "articulos_propios/sin_fondo_1747930831044.png",
        "categoria": "ROPA",
        "subcategoria": "VAQUEROS",
        "ocasiones": ["CASUAL", "TRABAJO_INFORMAL"],
        "temporadas": ["VERANO", "ENTRETIEMPO", "INVIERNO"],
        "colores": ["AZUL"],
        "estilo": "minimal",
        "formalidad": 6,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Vaqueros negros tiro alto",
        "keyImagen": "articulos_propios/sin_fondo_1747933510604.png",
        "categoria": "ROPA",
        "subcategoria": "VAQUEROS",
        "ocasiones": ["CASUAL", "CENA", "TRABAJO_INFORMAL"],
        "temporadas": ["VERANO", "ENTRETIEMPO", "INVIERNO"],
        "colores": ["NEGRO"],
        "estilo": "minimal",
        "formalidad": 6,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Vaqueros rayas verticales",
        "keyImagen": "articulos_propios/sin_fondo_1747935772260.png",
        "categoria": "ROPA",
        "subcategoria": "VAQUEROS",
        "ocasiones": ["CASUAL", "TRABAJO_INFORMAL"],
        "temporadas": ["ENTRETIEMPO", "INVIERNO"],
        "colores": ["AZUL", "BLANCO"],
        "estilo": "punk",
        "formalidad": 2,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "bermudas vaqueras",
        "keyImagen": "articulos_propios/sin_fondo_1748014156032.png",
        "categoria": "ROPA",
        "subcategoria": "BERMUDAS",
        "ocasiones": ["CASUAL"],
        "temporadas": ["VERANO", "ENTRETIEMPO"],
        "colores": ["AZUL"],
        "estilo": "punk",
        "formalidad": 2,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "bolsito marron",
        "keyImagen": "articulos_propios/sin_fondo_1748020979317.png",
        "categoria": "ACCESORIOS",
        "subcategoria": "MOCHILAS",
        "ocasiones": ["CASUAL", "CENA", "TRABAJO_INFORMAL"],
        "temporadas": ["VERANO", "ENTRETIEMPO", "INVIERNO"],
        "colores": ["MARRON"],
        "estilo": "elegant",
        "formalidad": 8,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Vestido vaquero",
        "keyImagen": "articulos_propios/sin_fondo_1748021031285.png",
        "categoria": "ROPA",
        "subcategoria": "VESTIDOS_CORTOS",
        "ocasiones": ["CASUAL"],
        "temporadas": ["VERANO", "ENTRETIEMPO"],
        "colores": ["AZUL"],
        "estilo": "casual",
        "formalidad": 5,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Adidas azules",
        "keyImagen": "articulos_propios/sin_fondo_1747847169941.png",
        "categoria": "CALZADO",
        "subcategoria": "ZAPATILLAS",
        "ocasiones": ["CASUAL", "TRABAJO_INFORMAL", "CENA"],
        "temporadas": ["VERANO", "ENTRETIEMPO", "INVIERNO"],
        "colores": ["AZUL"],
        "estilo": "punk",
        "formalidad": 2,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Adidas negras",
        "keyImagen": "articulos_propios/sin_fondo_1747849360973.png",
        "categoria": "CALZADO",
        "subcategoria": "ZAPATILLAS",
        "ocasiones": ["CASUAL", "CENA", "TRABAJO_INFORMAL"],
        "temporadas": ["ENTRETIEMPO", "VERANO", "INVIERNO"],
        "colores": ["NEGRO"],
        "estilo": "punk",
        "formalidad": 2,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Top gris",
        "keyImagen": "articulos_propios/sin_fondo_1747849477317.png",
        "categoria": "ROPA",
        "subcategoria": "CAMISETAS",
        "ocasiones": ["CASUAL"],
        "temporadas": ["VERANO", "ENTRETIEMPO"],
        "colores": ["GRIS"],
        "estilo": "minimal",
        "formalidad": 6,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Vaqueros azul clarito",
        "keyImagen": "articulos_propios/sin_fondo_1747929077251.png",
        "categoria": "ROPA",
        "subcategoria": "VAQUEROS",
        "ocasiones": ["CASUAL", "TRABAJO_INFORMAL"],
        "temporadas": ["ENTRETIEMPO", "INVIERNO", "VERANO"],
        "colores": ["AZUL"],
        "estilo": "punk",
        "formalidad": 2,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Vaqueros azul oscuro",
        "keyImagen": "articulos_propios/sin_fondo_1747930889789.png",
        "categoria": "ROPA",
        "subcategoria": "VAQUEROS",
        "ocasiones": ["CASUAL", "TRABAJO_INFORMAL", "CENA"],
        "temporadas": ["VERANO", "ENTRETIEMPO", "INVIERNO"],
        "colores": ["AZUL"],
        "estilo": "boho",
        "formalidad": 4,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Vaqueros grises tiro alto",
        "keyImagen": "articulos_propios/sin_fondo_1747933575683.png",
        "categoria": "ROPA",
        "subcategoria": "VAQUEROS",
        "ocasiones": ["CASUAL", "CENA", "TRABAJO_INFORMAL"],
        "temporadas": ["ENTRETIEMPO", "INVIERNO", "VERANO"],
        "colores": ["GRIS"],
        "estilo": "minimal",
        "formalidad": 6,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Vaqueros blancos",
        "keyImagen": "articulos_propios/sin_fondo_1747984980918.png",
        "categoria": "ROPA",
        "subcategoria": "VAQUEROS",
        "ocasiones": ["CASUAL", "TRABAJO_INFORMAL"],
        "temporadas": ["ENTRETIEMPO", "INVIERNO"],
        "colores": ["BLANCO"],
        "estilo": "elegant",
        "formalidad": 8,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Top vichi azul",
        "keyImagen": "articulos_propios/sin_fondo_1748014448278.png",
        "categoria": "ROPA",
        "subcategoria": "CAMISETAS",
        "ocasiones": ["CASUAL", "CENA", "TRABAJO_INFORMAL"],
        "temporadas": ["VERANO", "ENTRETIEMPO"],
        "colores": ["AZUL"],
        "estilo": "punk",
        "formalidad": 2,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Top vichi rojo",
        "keyImagen": "articulos_propios/sin_fondo_1748015639088.png",
        "categoria": "ROPA",
        "subcategoria": "CAMISETAS",
        "ocasiones": ["CASUAL", "TRABAJO_INFORMAL"],
        "temporadas": ["VERANO", "ENTRETIEMPO"],
        "colores": ["ROJO"],
        "estilo": "boho",
        "formalidad": 4,
    },
    {
        "usuario_id": USUARIO_ID,
        "nombre": "Adidas blancas",
        "keyImagen": "articulos_propios/sin_fondo_1748021075201.png",
        "categoria": "CALZADO",
        "subcategoria": "ZAPATILLAS",
        "ocasiones": ["CASUAL", "TRABAJO_INFORMAL"],
        "temporadas": ["VERANO", "ENTRETIEMPO", "INVIERNO"],
        "colores": ["BLANCO", "NEGRO"],
        "estilo": "punk",
        "formalidad": 2,
    },
]




# ────────────────────────────────────────────────────────────────────────────────
# HELPERS
# ────────────────────────────────────────────────────────────────────────────────

def build_form_fields(art: Dict) -> List[Tuple[str, str]]:
    """Convierte una entrada en campos para multipart/form-data."""
    data: List[Tuple[str, str]] = [
        ("keyImagen", art["keyImagen"]),
        ("usuario", str(art["usuario_id"])),
        ("nombre", art["nombre"]),
        ("categoria", art["categoria"]),
        ("estilo", art["estilo"]),
        ("formalidad", str(art["formalidad"])),
    ]

    cat = art["categoria"].upper()
    if cat == "ROPA":
        data.append(("subcategoria_ropa", art["subcategoria"]))
    elif cat == "CALZADO":
        data.append(("subcategoria_calzado", art["subcategoria"]))
    elif cat == "ACCESORIOS":
        data.append(("subcategoria_accesorios", art["subcategoria"]))

    data.extend(("ocasiones[]", o) for o in art["ocasiones"])
    data.extend(("temporadas[]", t) for t in art["temporadas"])
    data.extend(("colores[]", c) for c in art["colores"])

    return data


def procesar_articulo(art: Dict):
    nombre = art["nombre"]
    fields = build_form_fields(art)

    try:
        resp = requests.post(ENDPOINT_ARTICULOS, headers=HEADERS, data=fields, timeout=30)
    except requests.RequestException as exc:
        print(f"❌ NETWORK ▸ {nombre} :: {exc}")
        return

    if resp.status_code in (200, 201):
        print(f"✔️  {resp.json().get('articulo_id', '?')} :: {nombre}")
    else:
        print(f"❌ {resp.status_code} ▸ {nombre} :: {resp.text}")


# ────────────────────────────────────────────────────────────────────────────────
# MAIN
# ────────────────────────────────────────────────────────────────────────────────

def main():
    inicio = datetime.now()
    with ThreadPoolExecutor(max_workers=5) as pool:
        pool.map(procesar_articulo, ARTICULOS)
    print(f"\n⏱  Terminado en {(datetime.now() - inicio).total_seconds():.1f}s")


if __name__ == "__main__":
    main()
