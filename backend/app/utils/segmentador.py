import cv2
import numpy as np
from PIL import Image
import io
from ultralytics import YOLO

modelo = YOLO('yolov8n-seg.pt')  # Puedes cambiar esto por tu modelo custom

def extraer_prenda_por_clase(image_bytes: bytes, clase_deseada: str) -> bytes:
    # Leer imagen
    np_img = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(np_img, cv2.IMREAD_COLOR)

    # Realizar predicción
    resultados = modelo(img)[0]

    # Buscar la máscara de la clase deseada
    for i, cls in enumerate(resultados.names):
        if cls.lower() == clase_deseada.lower():
            for j, pred_class in enumerate(resultados.boxes.cls.cpu().numpy()):
                if resultados.names[int(pred_class)].lower() == clase_deseada.lower():
                    mask = resultados.masks.data[j].cpu().numpy()
                    mask = (mask * 255).astype(np.uint8)
                    img_masked = cv2.bitwise_and(img, img, mask=mask)

                    # Convertir a PNG y devolver
                    _, buffer = cv2.imencode(".png", img_masked)
                    return buffer.tobytes()

    raise ValueError("No se detectó la prenda deseada en la imagen.")
