import boto3
from botocore.exceptions import NoCredentialsError
import os
import uuid
from dotenv import load_dotenv

load_dotenv()

AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_REGION = os.getenv("AWS_REGION")
AWS_S3_BUCKET_NAME = os.getenv("AWS_S3_BUCKET_NAME")

# Inicialización de cliente S3
s3 = boto3.client(
    's3',
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    region_name=AWS_REGION
)

def upload_file_to_s3(file, filename: str, folder: str = "uploads/") -> str:
    key = f"{folder}{uuid.uuid4()}_{filename}"
    try:
        content_type = getattr(file, "content_type", "image/jpeg")
        
        s3.upload_fileobj(
            file.file, 
            AWS_S3_BUCKET_NAME,
            key,
            ExtraArgs={
                'ACL': 'private',
                'ContentType': content_type,
            }
        )
        return key  # Retorna la "key" de S3
    except NoCredentialsError:
        raise Exception("Credenciales de AWS no válidas.")
    except Exception as e:
        raise Exception(f"Error al subir el archivo a S3: {e}")

def get_s3_url(key):
    return f"https://{AWS_S3_BUCKET_NAME}.s3.amazonaws.com/{key}"
