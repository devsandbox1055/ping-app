from fastapi import APIRouter
from datetime import datetime, timezone
from app.models import ActivityStatus, ActivityResponse
from app.database import db

router = APIRouter(prefix="/api", tags=["Activity"])

@router.post("/activity-status")
async def update_activity_status(status: ActivityStatus):
    db.user_activity[status.user_id] = {
        "status": status.status,
        "game": status.game,
        "is_streaming": status.is_streaming,
        "stream_software": status.stream_software,
        "last_updated": status.timestamp,
        "is_active": True
    }
    print(f"📊 Activity - User {status.user_id}: {status.status} - Game: {status.game}, Streaming: {status.is_streaming}")
    return {"success": True}

@router.get("/get-activity/{user_id}", response_model=ActivityResponse)
async def get_activity_status(user_id: str):
    if user_id not in db.user_activity:
        return ActivityResponse(
            status="available",
            game=None,
            is_streaming=False,
            stream_software=None,
            last_updated=datetime.now(timezone.utc).isoformat(),
            message="User is available"
        )
    
    activity = db.user_activity[user_id]
    return ActivityResponse(
        status=activity["status"],
        game=activity["game"],
        is_streaming=activity.get("is_streaming", False),
        stream_software=activity.get("stream_software"),
        last_updated=activity["last_updated"],
        message=_get_status_message(
            activity["status"], 
            activity["game"], 
            activity.get("is_streaming", False)
        )
    )

def _get_status_message(status: str, game: str = None, is_streaming: bool = False):
    if status == "streaming_only":
        return "🔴 LIVE - Streaming now"
    elif is_streaming and game:
        return f"🔴 LIVE - Playing {game}"
    elif is_streaming:
        return f"🔴 LIVE - Streaming now"
    elif status == "actively_playing" and game:
        return f"🎮 Playing {game}"
    elif status == "actively_playing":
        return f"🎮 Playing game"
    elif status == "game_running" and game:
        return f"🟡 {game} is running"
    else:
        return "🟢 Available"