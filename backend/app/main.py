from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import Config
from app.routes import auth_router, activity_router, messages_router

def create_app() -> FastAPI:
    app = FastAPI(
        title=Config.APP_NAME,
        version=Config.VERSION,
        docs_url="/docs",
        redoc_url="/redoc"
    )
    
    # CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    # Include routers
    app.include_router(auth_router)
    app.include_router(activity_router)
    app.include_router(messages_router)
    
    @app.get("/")
    async def root():
        return {
            "message": f"{Config.APP_NAME} Running!",
            "version": Config.VERSION,
            "status": "active"
        }
    
    return app

app = create_app()