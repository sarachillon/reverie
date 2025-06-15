from PIL import Image
import io
import random
from typing import List, Optional, Tuple, Dict, Any
from datetime import datetime
from app.models.models import ArticuloPropio, OutfitPropio, Usuario, OutfitItem
from app.models.enummerations import (
    SubcategoriaRopaEnum,
    SubcategoriaCalzadoEnum,
    SubcategoriaAccesoriosEnum,
    TemporadaEnum,
    OcasionEnum,
    ColorEnum,
)
from app.utils.s3 import get_imagen_s3, subir_imagen_s3_bytes



###############################################################################
# Constantes de categoría
###############################################################################

PARTES_ARRIBA = {
    SubcategoriaRopaEnum.CAMISAS,
    SubcategoriaRopaEnum.CAMISETAS,
    SubcategoriaRopaEnum.JERSEYS,
    SubcategoriaRopaEnum.TRAJES,
}

PARTES_ABAJO = {
    SubcategoriaRopaEnum.PANTALONES,
    SubcategoriaRopaEnum.VAQUEROS,
    SubcategoriaRopaEnum.FALDAS_CORTAS,
    SubcategoriaRopaEnum.FALDAS_LARGAS,
    SubcategoriaRopaEnum.BERMUDAS,
}

CUERPO_ENTERO = {
    SubcategoriaRopaEnum.MONOS,
    SubcategoriaRopaEnum.VESTIDOS_LARGOS,
    SubcategoriaRopaEnum.VESTIDOS_CORTOS,
}


# Orden de preferencia de accesorios + máximo global de numero de accesorios
_MAX_ACC = 3
_ACCES_PRIORIDAD: List[str] = [
    SubcategoriaAccesoriosEnum.BISUTERIA,
    SubcategoriaAccesoriosEnum.MOCHILAS,
    SubcategoriaAccesoriosEnum.GAFAS,
    SubcategoriaAccesoriosEnum.SOMBREROS,
    SubcategoriaAccesoriosEnum.CINTURONES,  
]

# Posición aproximada (en grados º) de cada color en la rueda HSV
_COLOR_HUE: dict[ColorEnum, int] = {
    ColorEnum.ROJO: 0,
    ColorEnum.NARANJA: 30,
    ColorEnum.AMARILLO: 60,
    ColorEnum.VERDE: 120,
    ColorEnum.AZUL: 165,
    ColorEnum.VIOLETA: 240,
    ColorEnum.ROSA: 275,
    ColorEnum.GRANATE: 330,
    # Los colores neutros se dejan sin ángulo
}

# Colores considerados neutros: combinan con prácticamente todo
_NEUTRAL_COLORS: set[ColorEnum] = {
    ColorEnum.BLANCO,
    ColorEnum.NEGRO,
    ColorEnum.GRIS,
    ColorEnum.MARRON,
    ColorEnum.DORADO,
    ColorEnum.PLATEADO,
}

_ANALO_DIST = 30  # ±30°
_COMP_DIST = 15   # 180±15°
_SPLIT_DIST = 15  # 150/210 ±15°


def _hue(color: ColorEnum) -> Optional[int]:
    """Devuelve el ángulo HSV (0‑359°) del color, si está definido."""
    return _COLOR_HUE.get(color)


def _delta_deg(a: int, b: int) -> int:
    """Diferencia mínima entre dos ángulos (°)."""
    d = abs(a - b) % 360
    return min(d, 360 - d)


def colores_compatibles(c1: ColorEnum, c2: ColorEnum) -> bool:
    """Evalúa si **dos colores** combinan según las normas básicas.

    Reglas aplicadas (en orden):
        1. Igualdad exacta (monocromático).
        2. Uno de los dos es neutro.
        3. Análogos (±30°).
        4. Complementarios (180°±15°).
        5. Split‑complementarios (150°/210° ±15°).
    """
    # 1. Mismo color
    if c1 == c2:
        return True

    # 2. Neutros siempre encajan
    if c1 in _NEUTRAL_COLORS or c2 in _NEUTRAL_COLORS:
        return True

    h1, h2 = _hue(c1), _hue(c2)
    if h1 is None or h2 is None:
        # Alguno no definido en la rueda ⇒ mejor declarar incompatibles
        return False

    diff = _delta_deg(h1, h2)

    # 3. Análogos
    if diff <= _ANALO_DIST:
        return True
    # 4. Complementarios
    if abs(diff - 180) <= _COMP_DIST:
        return True
    # 5. Split complementarios
    if abs(diff - 150) <= _SPLIT_DIST or abs(diff - 210) <= _SPLIT_DIST:
        return True

    return False


def prendas_compatibles(a: ArticuloPropio, b: ArticuloPropio) -> bool:
    """Comprueba si *dos prendas* (`top`, `bottom`) combinan a nivel de color.

    * Descartamos pareja si **ambas** son multicolor (demasiada complejidad).
    * Si ambas son monocromáticas ⇒ basta con comprobar `colores_compatibles`.
    * En caso de que sólo una sea multicolor, se valida que **al menos** uno de
      los colores de la prenda multicolor combine con el color de la prenda
      monocromática (regla relieve).
    """
    if len(a.colores) > 1 and len(b.colores) > 1:
        return False  # Simplificación inicial

    if len(a.colores) == 1 and len(b.colores) == 1:
        return colores_compatibles(a.colores[0], b.colores[0])

    # Una es multi, la otra mono
    mono, multi = (a, b) if len(a.colores) == 1 else (b, a)
    mono_color = mono.colores[0]
    return any(colores_compatibles(mono_color, c) for c in multi.colores)



###############################################################################
# Heurísticas de selección de accesorios y zapatos
###############################################################################

def _should_include_belt(bottom: ArticuloPropio) -> bool:
    """Incluimos cinturón con un 40% de probabilidad solo en pantalones/vaqueros."""
    if bottom.subcategoria in {
        SubcategoriaRopaEnum.PANTALONES,
        SubcategoriaRopaEnum.VAQUEROS,
    }:
        return random.random() < 0.4
    return False


def _seleccionar_accesorios(
    posibles: List[ArticuloPropio],
    bottom: ArticuloPropio,
    regla: str,
    color_top: ColorEnum,
    color_bottom: ColorEnum,
) -> List[ArticuloPropio]:
    unicos: Dict[str, ArticuloPropio] = {}
    for acc in posibles:
        if acc.subcategoria not in unicos:
            unicos[acc.subcategoria] = acc

    seleccion: List[ArticuloPropio] = []

    if regla == "MONOCROMO":
        # accesorio contraste + resto top‑color (implementado antes)
        contraste = next((a for a in unicos.values() if color_top not in a.colores), None)
        if contraste:
            seleccion.append(contraste)
            unicos.pop(contraste.subcategoria, None)
        for cat in _ACCES_PRIORIDAD:
            if cat not in unicos or len(seleccion) >= _MAX_ACC:
                continue
            acc = unicos[cat]
            if color_top in acc.colores and not (
                cat == SubcategoriaAccesoriosEnum.CINTURONES.value and not _should_include_belt(bottom)
            ):
                seleccion.append(acc)
    elif regla == "SANDWICH":
        # solo colores del top o bottom
        for cat in _ACCES_PRIORIDAD:
            if cat not in unicos:
                continue
            acc = unicos[cat]
            if not (
                color_top in acc.colores or color_bottom in acc.colores
            ):
                continue
            if cat == SubcategoriaAccesoriosEnum.CINTURONES.value and not _should_include_belt(bottom):
                continue
            seleccion.append(acc)
            if len(seleccion) >= _MAX_ACC:
                break
    else:
        # libre / 60‑30‑10
        for cat in _ACCES_PRIORIDAD:
            if cat not in unicos:
                continue
            acc = unicos[cat]
            if cat == SubcategoriaAccesoriosEnum.CINTURONES.value and not _should_include_belt(bottom):
                continue
            seleccion.append(acc)
            if len(seleccion) >= _MAX_ACC:
                break
    return seleccion


def _seleccionar_zapatos(
    zapatos: List[ArticuloPropio],
    base_color: ColorEnum,
    regla: str,
) -> Optional[ArticuloPropio]:
    if not zapatos:
        return None
    if regla == "SANDWICH":
        solo_base = [z for z in zapatos if base_color in z.colores]
        if solo_base:
            return random.choice(solo_base)
        return None  # si no hay zapato que cumpla, mejor abortar
    # regla libre / mono etc → priorizar pero no obligar
    candidatos = [
        *[z for z in zapatos if base_color in z.colores],
        *[z for z in zapatos if base_color not in z.colores],
    ]
    return random.choice(candidatos[:3])


###############################################################################
# Lógica de reglas de vestir
###############################################################################
def _elegir_regla() -> str:
    """Devuelve aleatoriamente la regla a aplicar en el outfit."""
    return random.choice(["MONOCROMO", "SANDWICH", "60-30-10", "LIBRE"])

def _es_monocromatico(top: ArticuloPropio, bottom: ArticuloPropio) -> bool:
    """True si top y bottom comparten prácticamente el mismo color."""
    if not top.colores or not bottom.colores:
        return False
    c1, c2 = top.colores[0], bottom.colores[0]
    if c1 == c2:
        return True
    # Pequeña variación de tono (±30 ° en la rueda)
    h1, h2 = _hue(c1), _hue(c2)
    return h1 is not None and h2 is not None and _delta_deg(h1, h2) <= 30




###############################################################################
# Lógica principal
###############################################################################

async def generar_outfit_propio(
    usuario: Usuario,
    titulo: str,
    descripcion_generacion: Optional[str] = None,
    temporadas: Optional[List[TemporadaEnum]] = None,
    ocasiones: Optional[List[OcasionEnum]] = None,
    colores: Optional[List[ColorEnum]] = None
) -> Optional[OutfitPropio]:
    articulos = usuario.articulos_propios

    # ---------------------------------------------------------------------
    # 1. Filtros de usuario (temporada, ocasión, colores)
    # ---------------------------------------------------------------------

    def cumple_filtros(a: ArticuloPropio) -> bool:
        if temporadas and not any(t in a.temporadas for t in temporadas): return False
        if ocasiones and not any(o in a.ocasiones for o in ocasiones): return False
        if colores and not any(c in a.colores for c in colores): return False
        return True

    tops = [a for a in articulos if a.subcategoria in PARTES_ARRIBA and cumple_filtros(a)]
    bottoms = [a for a in articulos if a.subcategoria in PARTES_ABAJO and cumple_filtros(a)]
    if not tops or not bottoms:
        return None


    # ---------------------------------------------------------------------
    # 2. Combinaciones top/bottom con criterios cromáticos
    # ---------------------------------------------------------------------

    combinaciones: list[tuple[ArticuloPropio, ArticuloPropio]] = [
        (t, b)
        for t in tops
        for b in bottoms
        if prendas_compatibles(t, b)
    ]

    #regla = _elegir_regla()
    regla = "MONOCROMO"
    if regla == "MONOCROMO":
        combinaciones = [(t, b) for t, b in combinaciones if _es_monocromatico(t, b)]
        if not combinaciones:           # si no hay, volvemos a libre
            print("No hay combinaciones monocromáticas, cambiando a libre")
            regla = "LIBRE"
    
    arriba, abajo = random.choice(combinaciones)
    seleccion: list[ArticuloPropio] = [arriba, abajo]
    print(f"Seleccionados: {arriba.nombre} y {abajo.nombre}")


    # ---------------------------------------------------------------------
    # 3. Selección de zapatos y accesorios compatibles
    # ---------------------------------------------------------------------
    zapatos = [
        a
        for a in articulos
        if a.subcategoria in [e.value for e in SubcategoriaCalzadoEnum] and cumple_filtros(a) 
    ]
    accesorios = [
        a
        for a in articulos
        if a.subcategoria in [e.value for e in SubcategoriaAccesoriosEnum] and cumple_filtros(a) 
    ]

    def filtrar_items(items: List[ArticuloPropio]) -> List[ArticuloPropio]:
        base_colors = (arriba.colores[0], abajo.colores[0])
        res = []
        for it in items:
            if any(colores_compatibles(c, base) for base in base_colors for c in it.colores):
                res.append(it)
        return res

    buenos_acc = filtrar_items(accesorios)
    buenos_zap = filtrar_items(zapatos)

    elegidos_acc = _seleccionar_accesorios(buenos_acc, abajo, regla, arriba.colores[0], abajo.colores[0])

    # ---------------------------------------------------------------------
    # 4. Collage
    # ---------------------------------------------------------------------
    imgs_bytes = [await get_imagen_s3(arriba.foto), await get_imagen_s3(abajo.foto)]
    for acc in elegidos_acc:
        imgs_bytes.append(await get_imagen_s3(acc.foto))
        seleccion.append(acc)
    if buenos_zap:
        elegido_z = random.choice(buenos_zap)
        imgs_bytes.append(await get_imagen_s3(elegido_z.foto))
        seleccion.append(elegido_z)

    # ahora creamos collage 
    collage_bytes, items_meta = _crear_collage_con_items(imgs_bytes, seleccion)


    # ---------------------------------------------------------------------
    # 5. Guardar 
    # ---------------------------------------------------------------------
    # subimos a S3
    key = await subir_imagen_s3_bytes(
        collage_bytes,
        f"collage_{usuario.id}_{datetime.utcnow().timestamp()}.png"
    )

    # persistimos OutfitPropio + OutfitItem
    outfit = OutfitPropio(
        usuario=usuario,
        titulo=titulo,
        descripcion_generacion=descripcion_generacion or "",
        fecha_creacion=datetime.now(),
        ocasiones=ocasiones or [],
        temporadas=temporadas or [],
        colores=colores or [],
        collage_key=key
    )
    # añadimos items con meta
    for meta in items_meta:
        outfit.items.append(OutfitItem(
            articulo_id=meta["articulo_id"],
            x=meta["x"],
            y=meta["y"],
            scale=meta["scale"],
            rotation=0.0,
            z_index=meta["z_index"]
        ))

    outfit.articulos_propios = seleccion

    return outfit


###############################################################################
# Utils del collage
###############################################################################

def _crear_collage_con_items(
    imagenes: List[bytes],
    articulos: List[ArticuloPropio]
) -> Tuple[bytes, List[Dict[str, Any]]]:
# ------------------------------------------------------------------
    # 1) Preprocesado imágenes -------------------------------------------------
    # ------------------------------------------------------------------
    pil_imgs: list[Image.Image] = []
    for b in imagenes:
        im = Image.open(io.BytesIO(b)).convert("RGBA")
        bbox = im.getbbox()
        pil_imgs.append(im.crop(bbox) if bbox else im)

    top, bot, *items = pil_imgs

    # ------------------------------------------------------------------
    # 2) Escalados top & bottom -----------------------------------------
    # ------------------------------------------------------------------
    

    fixed_bot_w = 300
    ratio_bot = fixed_bot_w / bot.width
    bot_r = bot.resize(
        (int(bot.width * ratio_bot), int(bot.height * ratio_bot)),
        Image.Resampling.LANCZOS,
    )

    def _row_widths(alpha, w: int, y0: int, y1: int) -> List[int]:
        widths: list[int] = []
        for y in range(y0, y1):
            row = alpha.crop((0, y, w, y + 1)).getdata()
            nz = [i for i, a in enumerate(row) if a > 0]
            if nz:
                widths.append(nz[-1] - nz[0] + 1)
        return widths

    def _top_width(im: Image.Image, subcat) -> int:
 
        alpha = im.split()[-1]
        w, h = im.size
        if subcat == SubcategoriaRopaEnum.JERSEYS:
            widths = _row_widths(alpha, w, int(h * 0.05), int(h * 0.15))
            neck = int(sum(widths) / len(widths)) if widths else w // 2
            return min(int(neck * 1.3), w)
        elif subcat in {SubcategoriaRopaEnum.CAMISETAS, getattr(SubcategoriaRopaEnum, "TOPS", None)}:
            widths = _row_widths(alpha, w, int(h * 0.85), h)
            return int(sum(widths) / len(widths)) if widths else w
        else:
            widths = _row_widths(alpha, w, int(h * 0.25), int(h * 0.55))
            if not widths:
                return w
            median_w = sorted(widths)[len(widths) // 2]
            return median_w if median_w > 0.35 * w else int(0.5 * w)

    top_effective_w = _top_width(top, articulos[0].subcategoria)
    target_scale = bot_r.width / top_effective_w
    scale_top = max(0.8, min(target_scale, 1.2))
    top_r = top.resize(
        (int(top.width * scale_top), int(top.height * scale_top)),
        Image.Resampling.LANCZOS,
    )



    # ------------------------------------------------------------------
    # 3) Escalar accesorios / zapato ------------------------------------
    # ------------------------------------------------------------------
    item_target_w = bot_r.width // 2
    items_r = [
        itm.resize(
            (
                int(itm.width * max(0.6, min(item_target_w / itm.width, 1.0))),
                int(itm.height * max(0.6, min(item_target_w / itm.width, 1.0))),
            ),
            Image.Resampling.LANCZOS,
        )
        for itm in items
    ]

    # ------------------------------------------------------------------
    # 4) Canvas y coordenadas -------------------------------------------
    # ------------------------------------------------------------------
    space = 10
    left_w = max(top_r.width, bot_r.width)
    left_h = top_r.height + bot_r.height + space
    right_w = max((i.width for i in items_r), default=0)
    right_h = sum(i.height for i in items_r) + space * max(0, len(items_r) - 1)

    W = left_w + right_w + space * 3
    H = max(left_h, right_h) + space * 2
    canvas = Image.new("RGBA", (W, H), (255, 255, 255, 0))

    meta: List[Dict[str, Any]] = []

    # ------------------------------------------------------------------
    # 5) Pegar top & bottom --------------------------------------------
    # ------------------------------------------------------------------
    x_top = space + (left_w - top_r.width) // 2
    y_top = space
    canvas.paste(top_r, (x_top, y_top), top_r)
    meta.append({"articulo_id": articulos[0].id, "x": x_top, "y": y_top, "scale": scale_top, "z_index": 0})

    x_bot = space + (left_w - bot_r.width) // 2
    y_bot = y_top + top_r.height + space
    canvas.paste(bot_r, (x_bot, y_bot), bot_r)
    meta.append({"articulo_id": articulos[1].id, "x": x_bot, "y": y_bot, "scale": ratio_bot, "z_index": 1})

    # ------------------------------------------------------------------
    # 6) Columna derecha: accesorios y zapato ---------------------------
    # ------------------------------------------------------------------
    if not items_r:
        buf = io.BytesIO()
        canvas.save(buf, format="PNG")
        return buf.getvalue(), meta

    # Separamos (si existe) zapato = último elemento
    shoe_r = items_r[-1]
    acc_r = items_r[:-1]

    xr = left_w + space * 2

    # 6.1 Zapato al fondo
    y_shoe = H - space - shoe_r.height
    canvas.paste(shoe_r, (xr, y_shoe), shoe_r)
    meta.append({
        "articulo_id": articulos[len(articulos) - 1].id,
        "x": xr,
        "y": y_shoe,
        "scale": shoe_r.width / item_target_w,
        "z_index": len(articulos) - 1,
    })

    # 6.2 Accesorios (máx. 3) – centrado vertical
    if acc_r:
        avail_top = space
        avail_bottom = y_shoe - space
        avail_height = avail_bottom - avail_top

        # Accesorio 0 ⇒ centro
        acc0 = acc_r[0]
        y_center = avail_top + (avail_height - acc0.height) // 2
        canvas.paste(acc0, (xr, y_center), acc0)
        meta.append({
            "articulo_id": articulos[2].id,
            "x": xr,
            "y": y_center,
            "scale": acc0.width / item_target_w,
            "z_index": 2,
        })

        if len(acc_r) > 1:
            acc1 = acc_r[1]
            y_top_acc = y_center - acc1.height - space
            canvas.paste(acc1, (xr, y_top_acc), acc1)
            meta.append({
                "articulo_id": articulos[3].id,
                "x": xr,
                "y": y_top_acc,
                "scale": acc1.width / item_target_w,
                "z_index": 3,
            })
        if len(acc_r) > 2:
            acc2 = acc_r[2]
            y_bottom_acc = y_center + acc0.height + space
            # Aseguramos que no pisa el zapato
            y_bottom_acc = min(y_bottom_acc, y_shoe - acc2.height - space)
            canvas.paste(acc2, (xr, y_bottom_acc), acc2)
            meta.append({
                "articulo_id": articulos[4].id,
                "x": xr,
                "y": y_bottom_acc,
                "scale": acc2.width / item_target_w,
                "z_index": 4,
            })

    # ------------------------------------------------------------------
    # 7) Salida ----------------------------------------------------------
    # ------------------------------------------------------------------
    buf = io.BytesIO()
    canvas.save(buf, format="PNG")
    return buf.getvalue(), meta
