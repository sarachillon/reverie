import torch
from PIL import Image
from transformers import CLIPProcessor, CLIPModel

# Cargar modelo CLIP
model = CLIPModel.from_pretrained("openai/clip-vit-base-patch32")
processor = CLIPProcessor.from_pretrained("openai/clip-vit-base-patch32")

# Lista de estilos posibles
estilos = ["boho", "beach", "street", "minimal", "elegant", "sporty", "punk", "formal", "casual"]

def inferir_estilo_desde_imagen(image: Image.Image) -> str:
    inputs = processor(text=estilos, images=image, return_tensors="pt", padding=True)
    
    with torch.no_grad():
        outputs = model(**inputs)
        logits_per_image = outputs.logits_per_image  # [1, num_estilos]
        probs = logits_per_image.softmax(dim=1)

    estilo_index = probs.argmax().item()
    estilo_predicho = estilos[estilo_index]
    return estilo_predicho


def inferir_formalidad_desde_estilo(estilo: str) -> int:
    formalidad_por_estilo = {
        "FORMAL": 9,
        "ELEGANT": 8,
        "MINIMAL": 6,
        "CASUAL": 5,
        "STREET": 4,
        "SPORTY": 3,
        "BOHO": 4,
        "PUNK": 2,
        "BEACH": 2,
    }
    return formalidad_por_estilo.get(estilo.upper(), 5)
