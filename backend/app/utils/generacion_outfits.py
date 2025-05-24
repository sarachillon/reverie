from PIL import Image
import io
import random
from typing import List, Optional
from datetime import datetime
from app.models.models import ArticuloPropio, OutfitPropio, Usuario
from app.models.enummerations import SubcategoriaRopaEnum, SubcategoriaCalzadoEnum, SubcategoriaAccesoriosEnum, TemporadaEnum, OcasionEnum, ColorEnum
from app.utils.s3 import get_imagen_s3, subir_imagen_s3_bytes

PARTES_ARRIBA = {
    SubcategoriaRopaEnum.CAMISAS,
    SubcategoriaRopaEnum.CAMISETAS,
    SubcategoriaRopaEnum.JERSEYS,
    SubcategoriaRopaEnum.MONOS,
    SubcategoriaRopaEnum.TRAJES,
}

PARTES_ABAJO = {
    SubcategoriaRopaEnum.PANTALONES,
    SubcategoriaRopaEnum.VAQUEROS,
    SubcategoriaRopaEnum.FALDAS_CORTAS,
    SubcategoriaRopaEnum.FALDAS_LARGAS,
    SubcategoriaRopaEnum.BERMUDAS,
}

async def generar_outfit_propio(
    usuario: Usuario,
    titulo: str,
    descripcion_generacion: Optional[str] = None,
    temporadas: Optional[List[TemporadaEnum]] = None,
    ocasiones: Optional[List[OcasionEnum]] = None,
    colores: Optional[List[ColorEnum]] = None
) -> Optional[OutfitPropio]:
    articulos = usuario.articulos_propios

    def cumple_filtros(a: ArticuloPropio) -> bool:
        if temporadas and not any(t in a.temporadas for t in temporadas): return False
        if ocasiones and not any(o in a.ocasiones for o in ocasiones): return False
        if colores and not any(c in a.colores for c in colores): return False
        return True

    tops = [a for a in articulos if a.subcategoria in PARTES_ARRIBA and cumple_filtros(a)]
    bottoms = [a for a in articulos if a.subcategoria in PARTES_ABAJO and cumple_filtros(a)]
    if not tops or not bottoms:
        return None

    combinaciones = [(t, b) for t in tops for b in bottoms
                     if (len(t.colores) <= 1 or len(b.colores) <= 1)
                     and not (len(t.colores) > 1 and len(b.colores) > 1)]
    if not combinaciones:
        return None

    arriba, abajo = random.choice(combinaciones)
    seleccion = [arriba, abajo]

    zapatos = [a for a in articulos if a.subcategoria in SubcategoriaCalzadoEnum and cumple_filtros(a)]
    accesorios = [a for a in articulos if a.subcategoria in SubcategoriaAccesoriosEnum and cumple_filtros(a)]

    def filtrar_items(items):
        resultado = []
        ca, cb = arriba.colores[0], abajo.colores[0]
        for it in items:
            for c in it.colores:
                if (c == ca and ca != cb) or (ca == cb and c != ca):
                    resultado.append(it)
                    break
        return resultado

    buenos_acc = filtrar_items(accesorios)
    buenos_zap = filtrar_items(zapatos)

    imgs_bytes = [await get_imagen_s3(arriba.foto), await get_imagen_s3(abajo.foto)]
    for acc in buenos_acc:
        imgs_bytes.append(await get_imagen_s3(acc.foto)); seleccion.append(acc)
    if buenos_zap:
        elegido_z = random.choice(buenos_zap)
        imgs_bytes.append(await get_imagen_s3(elegido_z.foto)); seleccion.append(elegido_z)

    collage = crear_collage_outfit_v2(imgs_bytes)
    key = await subir_imagen_s3_bytes(collage, f"collage_{usuario.id}_{datetime.utcnow().timestamp()}.png")

    return OutfitPropio(
        usuario=usuario,
        titulo=titulo,
        descripcion_generacion=descripcion_generacion or "",
        fecha_creacion=datetime.now(),
        ocasiones=ocasiones or [],
        temporadas=temporadas or [],
        colores=colores or [],
        articulos_propios=seleccion,
        collage_key=key
    )


def crear_collage_outfit_v2(imagenes: List[bytes]) -> bytes:
    """
    Crea un collage de dos columnas:
      - Izquierda: top y bottom, alineados según anchura de hombros muestreada
      - Derecha: accesorios encima, calzado abajo (elevado)
    """
    # Carga y recorta transparencias
    pil_imgs = []
    for b in imagenes:
        im = Image.open(io.BytesIO(b)).convert("RGBA")
        bbox = im.getbbox()
        pil_imgs.append(im.crop(bbox) if bbox else im)

    top, bot, *items = pil_imgs

    # Medición de ancho de hombros muestreando la banda entre 15% y 25% de altura
    def measure_shoulder_width(im: Image.Image, y0_ratio=0.15, y1_ratio=0.25) -> int:
        alpha = im.split()[-1]
        w, h = im.size
        y0 = int(h * y0_ratio)
        y1 = min(int(h * y1_ratio), h)
        widths = []
        for y in range(y0, y1):
            row = alpha.crop((0, y, w, y+1)).getdata()
            nonzero = [i for i, a in enumerate(row) if a > 0]
            if nonzero:
                widths.append(nonzero[-1] - nonzero[0] + 1)
        return int(sum(widths) / len(widths)) if widths else w

    # Escalado bottom
    fixed_bot_w = 300
    ratio_bot = fixed_bot_w / bot.width
    bot_r = bot.resize((int(bot.width * ratio_bot), int(bot.height * ratio_bot)), Image.Resampling.LANCZOS)

    # Escalado top usando ancho de hombros + clamp 0.8–1.2
    shoulder_w = measure_shoulder_width(top)
    target_scale = bot_r.width / shoulder_w
    scale = max(0.8, min(target_scale, 1.2))
    top_r = top.resize((int(top.width * scale), int(top.height * scale)), Image.Resampling.LANCZOS)

    # Escalar accesorios/calzado a mitad de ancho de bottom (clamp 0.5–1.0)
    item_target_w = bot_r.width // 2
    items_r = []
    for itm in items:
        iw, ih = itm.size
        ratio = item_target_w / iw
        ratio = max(0.5, min(ratio, 1.0))
        items_r.append(itm.resize((int(iw * ratio), int(ih * ratio)), Image.Resampling.LANCZOS))

    # Construir canvas
    space = 10
    left_w = max(top_r.width, bot_r.width)
    left_h = top_r.height + bot_r.height + space
    right_w = max((i.width for i in items_r), default=0)
    right_h = sum(i.height for i in items_r) + space * max(0, len(items_r)-1)

    W = left_w + space + right_w + space * 2
    H = max(left_h, right_h) + space * 2
    canvas = Image.new("RGBA", (W, H), (255,255,255,0))

    # Pegar columna izquierda centrada
    x_l = space + (left_w - top_r.width)//2
    y = space
    canvas.paste(top_r, (x_l, y), top_r)
    y += top_r.height + space
    x_l2 = space + (left_w - bot_r.width)//2
    canvas.paste(bot_r, (x_l2, y), bot_r)

    # Pegar columna derecha: calzado último, elevado
    x_r = left_w + space * 2
    lift = 20
    y_base = H - space - (items_r[-1].height if items_r else 0) - lift
    y_cursor = y_base
    for itm in reversed(items_r):
        canvas.paste(itm, (x_r, y_cursor), itm)
        y_cursor -= itm.height + space

    buf = io.BytesIO()
    canvas.save(buf, format="PNG")
    return buf.getvalue()
