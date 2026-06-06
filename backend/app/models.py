from pydantic import BaseModel
from typing import Optional

class VerifyCodeRequest(BaseModel):
    code: str

class ActivityStatus(BaseModel):
    user_id: str
    status: str
    game: Optional[str] = None
    is_streaming: bool = False
    stream_software: Optional[str] = None
    timestamp: str

class UrgentMessage(BaseModel):
    to_user_id: str
    from_user_id: str
    message: str
    timestamp: str

class CodeResponse(BaseModel):
    code: str
    message: str

class VerifyResponse(BaseModel):
    valid: bool
    message: str
    session_id: Optional[str] = None

class ActivityResponse(BaseModel):
    status: str
    game: Optional[str] = None
    is_streaming: bool = False
    stream_software: Optional[str] = None
    last_updated: str
    message: str