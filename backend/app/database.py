from typing import Dict, List


class Database:
    def __init__(self):
        self.active_codes: Dict[str, dict] = {}
        self.user_activity: Dict[str, dict] = {}
        self.user_messages: Dict[str, list] = {}

db = Database()