# backend/app/utils/s3.py

import boto3
from fastapi import UploadFile
from decouple import config

AWS_ACCESS_KEY_ID = config("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = config("AWS_SECRET_ACCESS_KEY")
AWS_S3_BUCKET_NAME = config("AWS_S3_BUCKET_NAME")
AWS_REGION = config("AWS_REGION", default="eu-north-1")

async def subir_imagen_s3(file: UploadFile, filename: str) -> str:
    s3 = boto3.client("s3",
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
        region_name=AWS_REGION
    )

    contenido = await file.read()
    s3.put_object(
        Bucket=AWS_S3_BUCKET_NAME,
        Key=filename,
        Body=contenido,
        ContentType=file.content_type,
    )

    return f"{filename}"

async def get_imagen_s3(filename: str) -> bytes:
    s3 = boto3.client("s3",
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
        region_name=AWS_REGION
    )

    response = s3.get_object(Bucket=AWS_S3_BUCKET_NAME, Key=filename)
    return response['Body'].read()
