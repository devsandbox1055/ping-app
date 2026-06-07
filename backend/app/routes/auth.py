from fastapi import APIRouter
from datetime import datetime, timezone
import secrets
from app.models import VerifyCodeRequest, CodeResponse, VerifyResponse
from app.database import db

router = APIRouter(prefix="/api", tags=["Authentication"])

@router.post("/generate-code", response_model=CodeResponse)
async def generate_code():
    code = secrets.token_hex(4).upper()
    db.active_codes[code] = {
        "created_at": datetime.now(timezone.utc).isoformat(),
        "is_authenticated": False,
        "pc_connected": True,
        "sessions": []  # ✅ Track multiple sessions
    }
    print(f"✅ Code generated: {code}")
    return {"code": code, "message": "Code generated successfully"}

@router.post("/verify-code", response_model=VerifyResponse)
async def verify_code(request: VerifyCodeRequest):
    code = request.code.upper()
    print(f"🔍 Verifying code: {code}")
    
    if code not in db.active_codes:
        return {"valid": False, "message": "Invalid code"}
    
    # ✅ REMOVED the "code already used" block
    # Now same code can be used multiple times
    
    # Update authentication status (allow re-auth)
    db.active_codes[code]["is_authenticated"] = True
    db.active_codes[code]["verified_at"] = datetime.now(timezone.utc).isoformat()
    
    # ✅ Track session for multiple devices
    session_id = secrets.token_hex(16)
    if "sessions" not in db.active_codes[code]:
        db.active_codes[code]["sessions"] = []
    
    db.active_codes[code]["sessions"].append({
        "session_id": session_id,
        "verified_at": datetime.now(timezone.utc).isoformat(),
        "is_active": True
    })
    
    print(f"✅ Code verified: {code} (Session: {session_id[:8]}...)")
    
    return {
        "valid": True, 
        "message": "Authentication successful!",
        "session_id": session_id
    }

@router.post("/pc-connect/{code}")
async def pc_connect(code: str):
    code = code.upper()
    if code not in db.active_codes:
        db.active_codes[code] = {
            "created_at": datetime.now(timezone.utc).isoformat(),
            "is_authenticated": False,
            "pc_connected": True,
            "sessions": []
        }
    else:
        db.active_codes[code]["pc_connected"] = True
    
    print(f"💻 PC connected: {code}")
    return {"success": True, "message": "PC connected"}

@router.get("/check-auth/{code}")
async def check_authentication(code: str):
    code = code.upper()
    if code not in db.active_codes:
        return {"authenticated": False, "message": "Code not found"}
    
    # ✅ Always return authenticated if code exists (PC will keep checking)
    # This allows GF to reconnect anytime
    return {
        "authenticated": True,  # Changed from db.active_codes[code]["is_authenticated"]
        "message": "Connected! Your partner can see your status",
        "sessions_count": len(db.active_codes[code].get("sessions", []))
    }
