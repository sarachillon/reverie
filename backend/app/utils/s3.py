# backend/app/utils/s3.py

import io
import boto3
from fastapi import UploadFile
from decouple import config
from datetime import datetime

AWS_ACCESS_KEY_ID = config("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = config("AWS_SECRET_ACCESS_KEY")
AWS_S3_BUCKET_NAME = config("AWS_S3_BUCKET_NAME")
AWS_REGION = config("AWS_REGION")

async def subir_imagen_s3(file: UploadFile, filename: str) -> str:
    s3 = boto3.client("s3",
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
        region_name=AWS_REGION
    )

    # Generar un nombre único para el archivo
    filename = generar_nombre_unico(filename)

    contenido = await file.read()
    s3.put_object(
        Bucket=AWS_S3_BUCKET_NAME,
        Key=filename,
        Body=contenido,
        ContentType=file.content_type,
    )

    return f"{filename}"


async def subir_imagen_s3_bytes(image_bytes: bytes, filename: str) -> str:
    s3 = boto3.client("s3")
    bucket = AWS_S3_BUCKET_NAME
    key = f"articulos_propios/{filename}"

    s3.upload_fileobj(io.BytesIO(image_bytes), bucket, key, ExtraArgs={"ContentType": "image/png"})
    return key


async def get_imagen_s3(filename: str) -> bytes:
    s3 = boto3.client("s3",
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
        region_name=AWS_REGION
    )

    response = s3.get_object(Bucket=AWS_S3_BUCKET_NAME, Key=filename)
    return response['Body'].read()


async def delete_imagen_s3(filename: str) -> None:
    s3 = boto3.client("s3",
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
        region_name=AWS_REGION
    )

    s3.delete_object(Bucket=AWS_S3_BUCKET_NAME, Key=filename)



# Utils
def generar_nombre_unico(nombre_original):
    nombre, extension = nombre_original.rsplit('.', 1)
    timestamp = datetime.utcnow().strftime("%Y%m%d%H%M%S")
    nuevo_nombre = f"{nombre}_{timestamp}.{extension}"
    return nuevo_nombre



def generar_url_firmada(key: str, expiration: int = 3600) -> str:
    s3 = boto3.client("s3",
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
        region_name=AWS_REGION
    )
    return s3.generate_presigned_url(
        ClientMethod="get_object",
        Params={"Bucket": AWS_S3_BUCKET_NAME, "Key": key},
        ExpiresIn=expiration,
    )

