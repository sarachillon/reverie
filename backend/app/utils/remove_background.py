from rembg import remove
from PIL import Image
import io

def quitar_fondo_imagen(image_bytes: bytes) -> bytes:
    input_image = Image.open(io.BytesIO(image_bytes)).convert("RGBA")
    output_image = remove(input_image)

    # Recortar los bordes transparentes
    bbox = output_image.getbbox()
    if bbox:
        output_image = output_image.crop(bbox)

    output_io = io.BytesIO()
    output_image.save(output_io, format="PNG")
    return output_io.getvalue()
