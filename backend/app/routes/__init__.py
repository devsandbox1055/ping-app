from app.routes.auth import router as auth_router
from app.routes.activity import router as activity_router
from app.routes.messages import router as messages_router

__all__ = ["auth_router", "activity_router", "messages_router"]