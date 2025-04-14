from starlette.config import Config
config = Config(".env")

GOOGLE_CLIENT_ID = config("GOOGLE_CLIENT_ID")
