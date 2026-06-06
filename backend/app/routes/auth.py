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
        "pc_connected": True
    }
    print(f"Code generated: {code}")
    return {"code": code, "message": "Code generated successfully"}

@router.post("/verify-code", response_model=VerifyResponse)
async def verify_code(request: VerifyCodeRequest):
    code = request.code.upper()
    print(f"Verifying code: {code}")
    
    if code not in db.active_codes:
        return {"valid": False, "message": "Invalid code"}
    
    if db.active_codes[code]["is_authenticated"]:
        return {"valid": False, "message": "Code already used"}
    
    db.active_codes[code]["is_authenticated"] = True
    db.active_codes[code]["verified_at"] = datetime.now(timezone.utc).isoformat()
    
    print(f"Code verified: {code}")
    
    return {
        "valid": True, 
        "message": "Authentication successful!",
        "session_id": secrets.token_hex(16)
    }

@router.post("/pc-connect/{code}")
async def pc_connect(code: str):
    code = code.upper()
    if code not in db.active_codes:
        db.active_codes[code] = {
            "created_at": datetime.now(timezone.utc).isoformat(),
            "is_authenticated": False,
            "pc_connected": True
        }
    else:
        db.active_codes[code]["pc_connected"] = True
    
    print(f"PC connected: {code}")
    return {"success": True, "message": "PC connected"}

@router.get("/check-auth/{code}")
async def check_authentication(code: str):
    code = code.upper()
    if code not in db.active_codes:
        return {"authenticated": False, "message": "Code not found"}
    
    return {
        "authenticated": db.active_codes[code]["is_authenticated"],
        "message": "Connected!" if db.active_codes[code]["is_authenticated"] else "Waiting..."
    }