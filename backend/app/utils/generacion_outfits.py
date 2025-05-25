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

    # (filtrado simples de accesorios/zapatos según colores)
    def filtrar_items(items):
        ca, cb = arriba.colores[0], abajo.colores[0]
        res = []
        for it in items:
            if any((c == ca and ca != cb) or (ca == cb and c != ca) for c in it.colores):
                res.append(it)
        return res

    buenos_acc = filtrar_items(accesorios)
    buenos_zap = filtrar_items(zapatos)

    imgs_bytes = [await get_imagen_s3(arriba.foto), await get_imagen_s3(abajo.foto)]
    for acc in buenos_acc:
        imgs_bytes.append(await get_imagen_s3(acc.foto))
        seleccion.append(acc)
    if buenos_zap:
        elegido_z = random.choice(buenos_zap)
        imgs_bytes.append(await get_imagen_s3(elegido_z.foto))
        seleccion.append(elegido_z)

    # ahora creamos collage + metadatos
    collage_bytes, items_meta = _crear_collage_con_items(imgs_bytes, seleccion)

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

    return outfit


def _crear_collage_con_items(
    imagenes: List[bytes],
    articulos: List[ArticuloPropio]
) -> Tuple[bytes, List[Dict[str, Any]]]:
    """
    Igual que crear_collage_outfit_v2 pero devuelve también
    para cada imagen/metadato: artículo, x, y, scale, rotation, z_index
    """
    pil_imgs = []
    for b in imagenes:
        im = Image.open(io.BytesIO(b)).convert("RGBA")
        bbox = im.getbbox()
        pil_imgs.append(im.crop(bbox) if bbox else im)

    top, bot, *items = pil_imgs

    # 1) escalar bottom
    fixed_bot_w = 300
    ratio_bot = fixed_bot_w / bot.width
    bot_r = bot.resize(
        (int(bot.width * ratio_bot), int(bot.height * ratio_bot)),
        Image.Resampling.LANCZOS
    )

    # 2) medir hombros en top y escalarlo
    def measure_shoulder_width(im, y0_ratio=0.15, y1_ratio=0.25):
        alpha = im.split()[-1]
        w, h = im.size
        y0, y1 = int(h*y0_ratio), min(int(h*y1_ratio), h)
        widths = []
        for y in range(y0, y1):
            row = alpha.crop((0, y, w, y+1)).getdata()
            nz = [i for i,a in enumerate(row) if a>0]
            if nz:
                widths.append(nz[-1] - nz[0] + 1)
        return int(sum(widths)/len(widths)) if widths else w

    shoulder_w = measure_shoulder_width(top)
    target_scale = bot_r.width / shoulder_w
    scale_top = max(0.8, min(target_scale, 1.2))
    top_r = top.resize(
        (int(top.width*scale_top), int(top.height*scale_top)),
        Image.Resampling.LANCZOS
    )

    # 3) escalar cada accesorio/calzado
    item_target_w = bot_r.width // 2
    items_r = []
    for itm in items:
        ratio = item_target_w/itm.width
        ratio = max(0.5, min(ratio,1.0))
        items_r.append(itm.resize(
            (int(itm.width*ratio), int(itm.height*ratio)),
            Image.Resampling.LANCZOS
        ))

    # 4) construimos canvas
    space = 10
    left_w = max(top_r.width, bot_r.width)
    left_h = top_r.height + bot_r.height + space
    right_w = max((i.width for i in items_r), default=0)
    right_h = sum(i.height for i in items_r) + space*(max(0,len(items_r)-1))

    W = left_w + space + right_w + space*2
    H = max(left_h, right_h) + space*2
    canvas = Image.new("RGBA", (W,H), (255,255,255,0))

    meta: List[Dict[str, Any]] = []

    # pegar top
    x = space + (left_w - top_r.width)//2
    y = space
    canvas.paste(top_r, (x,y), top_r)
    meta.append({
        "articulo_id": articulos[0].id,
        "x": float(x),
        "y": float(y),
        "scale": float(scale_top),
        "z_index": 0
    })

    # pegar bottom
    y2 = y + top_r.height + space
    x2 = space + (left_w - bot_r.width)//2
    canvas.paste(bot_r, (x2,y2), bot_r)
    meta.append({
        "articulo_id": articulos[1].id,
        "x": float(x2),
        "y": float(y2),
        "scale": float(ratio_bot),
        "z_index": 1
    })

    # pegar accesorios y calzado en columna derecha
    x_r = left_w + space*2
    y_base = H - space - (items_r[-1].height if items_r else 0) - 20
    y_cursor = y_base
    for idx, itm in enumerate(reversed(items_r), start=2):
        canvas.paste(itm, (x_r, y_cursor), itm)
        meta.append({
            "articulo_id": articulos[idx].id,
            "x": float(x_r),
            "y": float(y_cursor),
            "scale": float(itm.width / item_target_w),
            "z_index": idx
        })
        y_cursor -= itm.height + space

    # salida
    buf = io.BytesIO()
    canvas.save(buf, format="PNG")
    return buf.getvalue(), meta
