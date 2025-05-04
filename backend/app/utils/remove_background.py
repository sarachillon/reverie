from rembg import remove
from PIL import Image
import io

def quitar_fondo_imagen(image_bytes: bytes) -> bytes:
    input_image = Image.open(io.BytesIO(image_bytes)).convert("RGBA")
    output_image = remove(input_image)
    output_io = io.BytesIO()
    output_image.save(output_io, format="PNG")
    return output_io.getvalue()
