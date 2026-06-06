import uvicorn
from app.config import Config

if __name__ == "__main__":
    print("=" * 50)
    print(f"🚀 Starting {Config.APP_NAME}")
    print(f"📍 Server: http://{Config.HOST}:{Config.PORT}")
    print(f"📚 Docs: http://{Config.HOST}:{Config.PORT}/docs")
    print("=" * 50)
    
    uvicorn.run(
        "app.main:app",
        host=Config.HOST,
        port=Config.PORT,
        reload=Config.DEBUG
    )