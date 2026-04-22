import os
from pydantic_settings import BaseSettings
from pydantic import ConfigDict

class Settings(BaseSettings):
    database_url: str = "postgresql://localhost/kairos_db"
    gemini_api_key: str
    jwt_secret: str = "dev-secret-key"
    api_host: str = "0.0.0.0"
    api_port: int = 8000
    env_name: str = "development"
    
    model_config = ConfigDict(env_file=".env")

settings = Settings()