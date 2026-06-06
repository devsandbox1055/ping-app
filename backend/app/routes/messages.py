from fastapi import APIRouter
from datetime import datetime, timedelta, timezone
from app.models import UrgentMessage
from app.database import db

router = APIRouter(prefix="/api", tags=["Messages"])

@router.post("/send-urgent-message")
async def send_urgent_message(msg: UrgentMessage):
    if msg.to_user_id not in db.user_messages:
        db.user_messages[msg.to_user_id] = []
    
    db.user_messages[msg.to_user_id].append({
        "from": msg.from_user_id,
        "message": msg.message,
        "timestamp": msg.timestamp,
        "read": False
    })
    
    print(f"💌 Urgent message from {msg.from_user_id} to {msg.to_user_id}: {msg.message}")
    return {"success": True, "message": "Message sent"}

@router.get("/get-messages/{user_id}")
async def get_messages(user_id: str):
    if user_id not in db.user_messages:
        return {"messages": []}
    
    messages = db.user_messages[user_id]
    for msg in messages:
        msg["read"] = True
    
    return {"messages": messages}

@router.delete("/clear-messages/{user_id}")
async def clear_messages(user_id: str):
    if user_id in db.user_messages:
        db.user_messages[user_id] = []
    print(f"🗑️ Cleared messages for {user_id}")
    return {"success": True}

@router.delete("/delete-old-messages/{user_id}")
async def delete_old_messages(user_id: str):
    if user_id in db.user_messages:
        current_time = datetime.now(timezone.utc)
        old_count = 0
        for msg in db.user_messages[user_id][:]:
            try:
                msg_time = datetime.fromisoformat(msg['timestamp'].replace('Z', '+00:00'))
                if current_time - msg_time > timedelta(minutes=2):
                    db.user_messages[user_id].remove(msg)
                    old_count += 1
            except:
                pass
        print(f"🗑️ Deleted {old_count} old messages for {user_id}")
        return {"deleted": old_count}
    return {"deleted": 0}