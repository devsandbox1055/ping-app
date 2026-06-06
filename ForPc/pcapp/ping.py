import tkinter as tk
from tkinter import messagebox
import requests
import threading
import time
import os
from datetime import datetime
import psutil
import win32gui
import win32process

BACKEND_URL = "put your backend url here"



BG       = "#0f0f12"
CARD     = "#1a1a22"
CARD_IN  = "#0a0a0d"   # darker inset (code box, listbox)
ACCENT   = "#e94560"
ACCENT2  = "#ff6b7a"   # hover
DIM      = "#888899"
WHITE    = "#ffffff"
GREEN    = "#23a55a"
ORANGE   = "#faa81a"
RED      = "#ed4245"


class CoupleSoftware:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Ping")
        self.root.geometry("460x680")
        self.root.resizable(False, False)
        self.root.configure(bg=BG)

        try:
            self.root.iconbitmap("icon.ico")
        except:
            pass

        self._center()

        self.user_code           = None
        self.is_authenticated    = False
        self.is_running          = True
        self.game_detection      = False
        self.detector_thread     = None
        self.msg_poller_running  = False
        self.auth_checker_running= False

        self._load_code()
        self._build_ui()

        if self.user_code:
            self.start_background_services()

        self.root.protocol("WM_DELETE_WINDOW", self._on_close)
        self.root.mainloop()

    

    def _center(self):
        w, h = 460, 680
        x = (self.root.winfo_screenwidth()  - w) // 2
        y = (self.root.winfo_screenheight() - h) // 2
        self.root.geometry(f"{w}x{h}+{x}+{y}")

    def _load_code(self):
        try:
            if os.path.exists("code.txt"):
                self.user_code = open("code.txt").read().strip()
        except:
            pass

    def _save_code(self, code):
        try:
            open("code.txt", "w").write(code)
            self.user_code = code
        except:
            pass

    

    def _build_ui(self):
        root = self.root

        
        hdr = tk.Frame(root, bg=ACCENT, height=90)
        hdr.pack(fill=tk.X, side=tk.TOP)
        hdr.pack_propagate(False)

        tk.Label(hdr, text="💕", font=("Segoe UI", 22),
                 bg=ACCENT, fg=WHITE).place(relx=.5, rely=.28, anchor="center")
        tk.Label(hdr, text="PING", font=("Segoe UI", 20, "bold"),
                 bg=ACCENT, fg=WHITE).place(relx=.5, rely=.57, anchor="center")
        tk.Label(hdr, text="Stay connected", font=("Segoe UI", 8),
                 bg=ACCENT, fg="#ffe0e5").place(relx=.5, rely=.80, anchor="center")

        
        self.status_bar = tk.Label(root, text="● Ready",
            font=("Segoe UI", 8), bg=CARD_IN, fg=DIM, anchor="w", padx=14, pady=5)
        self.status_bar.pack(fill=tk.X, side=tk.BOTTOM)

        footer = tk.Label(root, text="❤️Made For Her",
            font=("Segoe UI", 8), bg=CARD_IN, fg=ACCENT, pady=4)
        footer.pack(fill=tk.X, side=tk.BOTTOM)

        
        body = tk.Frame(root, bg=BG)
        body.pack(fill=tk.BOTH, expand=True, side=tk.TOP)

        P = 12   # outer padding
        G = 8    # gap between cards

        
        code_card = self._card(body)
        code_card.pack(fill=tk.X, padx=P, pady=(P, G))

        self._card_title(code_card, "🔑  CONNECTION CODE")

        
        box = tk.Frame(code_card, bg=CARD_IN)
        box.pack(fill=tk.X, padx=12, pady=(0, 10))

        self.code_label = tk.Label(box,
            text=self.user_code or "── NOT GENERATED ──",
            font=("Courier New", 22, "bold"),
            bg=CARD_IN, fg=ACCENT, pady=10)
        self.code_label.pack(fill=tk.X)

        
        btn_row = tk.Frame(code_card, bg=CARD)
        btn_row.pack(fill=tk.X, padx=12, pady=(0, 12))

        self.gen_btn = self._btn(btn_row, "✨  Generate Code",
                                 self.generate_code, primary=True)
        self.gen_btn.pack(side=tk.LEFT, padx=(0, 8))

        self.copy_btn = self._btn(btn_row, "📋  Copy",
                                  self.copy_code, primary=False)
        self.copy_btn.pack(side=tk.LEFT)

        
        st_card = self._card(body)
        st_card.pack(fill=tk.X, padx=P, pady=(0, G))

        self._card_title(st_card, "📡  CONNECTION STATUS")

        row = tk.Frame(st_card, bg=CARD_IN)
        row.pack(fill=tk.X, padx=12, pady=(0, 12))

        self.status_icon = tk.Label(row, text="⚪",
            font=("Segoe UI", 13), bg=CARD_IN, width=2)
        self.status_icon.pack(side=tk.LEFT, padx=(10, 8), pady=8)

        self.status_label = tk.Label(row,
            text="Waiting for partner connection…",
            font=("Segoe UI", 9), bg=CARD_IN, fg=DIM,
            anchor="w", wraplength=330, justify=tk.LEFT)
        self.status_label.pack(side=tk.LEFT, fill=tk.X, expand=True, pady=8)

        
        gm_card = self._card(body)
        gm_card.pack(fill=tk.X, padx=P, pady=(0, G))

        self._card_title(gm_card, "🎮  GAME DETECTION")

        gm_inner = tk.Frame(gm_card, bg=CARD_IN)
        gm_inner.pack(fill=tk.X, padx=12, pady=(0, 12))

        self.game_var = tk.BooleanVar(value=False)
        tk.Checkbutton(gm_inner, text=" Enable Activity Detection",
            variable=self.game_var, command=self.toggle_game_detection,
            font=("Segoe UI", 9), bg=CARD_IN, fg=WHITE,
            selectcolor=CARD_IN, activebackground=CARD_IN,
            activeforeground=ACCENT, cursor="hand2"
        ).pack(anchor="w", padx=10, pady=(8, 2))

        self.game_status = tk.Label(gm_inner,
            text="Detection disabled",
            font=("Segoe UI", 8), bg=CARD_IN, fg=DIM)
        self.game_status.pack(anchor="w", padx=32, pady=(0, 8))

        
        msg_card = self._card(body)
        msg_card.pack(fill=tk.BOTH, expand=True, padx=P, pady=(0, P))

        self._card_title(msg_card, "💬  MESSAGES")

        msg_inner = tk.Frame(msg_card, bg=CARD_IN)
        msg_inner.pack(fill=tk.BOTH, expand=True, padx=12, pady=(0, 12))

        self.msg_listbox = tk.Listbox(msg_inner,
            bg=CARD_IN, fg=DIM,
            font=("Segoe UI", 9),
            relief=tk.FLAT, bd=0,
            selectbackground=ACCENT,
            highlightthickness=0,
            activestyle="none")

        msg_sb = tk.Scrollbar(msg_inner, orient=tk.VERTICAL,
                               command=self.msg_listbox.yview)
        self.msg_listbox.configure(yscrollcommand=msg_sb.set)

        msg_sb.pack(side=tk.RIGHT, fill=tk.Y)
        self.msg_listbox.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

    

    @staticmethod
    def _card(parent):
        return tk.Frame(parent, bg=CARD)

    @staticmethod
    def _card_title(parent, text):
        tk.Label(parent, text=text,
                 font=("Segoe UI", 9, "bold"),
                 bg=CARD, fg=ACCENT
        ).pack(anchor="w", padx=12, pady=(10, 6))

    def _btn(self, parent, text, cmd, primary=True):
        bg  = ACCENT  if primary else "#252530"
        fg  = WHITE   if primary else DIM
        abg = ACCENT2 if primary else "#2e2e3d"
        return tk.Button(parent, text=text, command=cmd,
                         font=("Segoe UI", 9, "bold" if primary else "normal"),
                         bg=bg, fg=fg, activebackground=abg, activeforeground=fg,
                         padx=14, pady=7, relief=tk.FLAT, bd=0, cursor="hand2")

    
    def _set_status(self, text, ok=True):
        self.status_bar.config(text=f"● {text}", fg=GREEN if ok else RED)
        self.root.after(3000,
            lambda: self.status_bar.config(text="● Ready", fg=DIM))


    def show_notification(self, from_user, message):
        try:
            from plyer import notification
            notification.notify(title=f"💌 {from_user}",
                                message=message[:50], timeout=5,
                                app_name="Ping")
        except:
            pass
        try:
            import winsound
            winsound.Beep(1000, 300)
        except:
            pass


    def generate_code(self):
        def _do():
            try:
                r = requests.post(f"{BACKEND_URL}/api/generate-code", timeout=10)
                if r.status_code == 200:
                    code = r.json()["code"]
                    self._save_code(code)
                    self.root.after(0, lambda: self.code_label.config(text=code))
                    self.root.after(0, lambda: self.status_label.config(
                        text="✅  Code ready! Share it with your partner"))
                    self.root.after(0, lambda: self.status_icon.config(text="🟢"))
                    self._set_status("Code generated")
                    self._register_pc(code)
                    self.start_background_services()
                    messagebox.showinfo("Ping", f"Your code:\n\n  {code}\n\nShare this with your partner!")
                else:
                    messagebox.showerror("Error", "Server returned an error")
            except Exception as e:
                messagebox.showerror("Error", f"Cannot reach backend:\n{e}")
        threading.Thread(target=_do, daemon=True).start()

    def _register_pc(self, code):
        try:
            requests.post(f"{BACKEND_URL}/api/pc-connect/{code}", timeout=5)
        except:
            pass

    def copy_code(self):
        if self.user_code:
            self.root.clipboard_clear()
            self.root.clipboard_append(self.user_code)
            self._set_status("Copied to clipboard!")
        else:
            messagebox.showwarning("Ping", "Generate a code first.")

    def toggle_game_detection(self):
        if self.game_var.get():
            self._start_game_detection()
        else:
            self._stop_game_detection()

    def add_message(self, from_user, message):
        ts   = datetime.now().strftime("%H:%M")
        text = f"[{ts}]  {from_user}:  {message[:65]}"
        self.msg_listbox.insert(0, text)
        if self.msg_listbox.size() > 30:
            self.msg_listbox.delete(30, tk.END)
        self.msg_listbox.see(0)
        self.show_notification(from_user, message)
        self._set_status(f"Message from {from_user}")


    def start_background_services(self):
        if self.user_code and not self.msg_poller_running:
            self._start_auth_checker()
            self._start_msg_poller()

    def _start_auth_checker(self):
        if self.auth_checker_running:
            return
        self.auth_checker_running = True

        def _loop():
            while self.is_running and self.user_code:
                try:
                    r = requests.get(
                        f"{BACKEND_URL}/api/check-auth/{self.user_code}", timeout=5)
                    if r.status_code == 200 and r.json().get("authenticated"):
                        if not self.is_authenticated:
                            self.is_authenticated = True
                            self.root.after(0, lambda: self.status_icon.config(text="🔗"))
                            self.root.after(0, lambda: self.status_label.config(
                                text="🔗  Connected! Your partner can see your activity"))
                            self._set_status("Partner connected!")
                            self.add_message("System", "Partner connected! 🎉")
                except:
                    pass
                time.sleep(3)

        threading.Thread(target=_loop, daemon=True).start()

    def _start_msg_poller(self):
        if self.msg_poller_running:
            return
        self.msg_poller_running = True

        def _loop():
            while self.is_running and self.user_code:
                try:
                    r = requests.get(
                        f"{BACKEND_URL}/api/get-messages/{self.user_code}", timeout=3)
                    if r.status_code == 200:
                        msgs = r.json().get("messages", [])
                        if msgs:
                            for m in msgs:
                                self.add_message(m.get("from", "GF"), m.get("message", ""))
                            requests.delete(
                                f"{BACKEND_URL}/api/clear-messages/{self.user_code}")
                except:
                    pass
                time.sleep(3)

        threading.Thread(target=_loop, daemon=True).start()

    def _start_game_detection(self):
        if self.detector_thread and self.detector_thread.is_alive():
            return
        self.game_detection = True
        self.game_status.config(text="🟢  ACTIVE — sharing your activity", fg=GREEN)
        self.detector_thread = threading.Thread(
            target=self._detect_loop, daemon=True)
        self.detector_thread.start()
        self._set_status("Game detection ON")

    def _stop_game_detection(self):
        self.game_detection = False
        self.game_status.config(text="Detection disabled", fg=DIM)
        self._send_status("available", None, False, None)
        self._set_status("Game detection OFF")

    def _detect_loop(self):
        GAMES = {
            "VALORANT-Win64-Shipping.exe": "Valorant",
            "cs2.exe":                     "Counter-Strike 2",
            "GTA5.exe":                    "GTA V",
            "Minecraft.Windows.exe":       "Minecraft",
            "FortniteClient-Win64-Shipping.exe": "Fortnite",
            "RocketLeague.exe":            "Rocket League",
            "Cyberpunk2077.exe":           "Cyberpunk 2077",
            "ApexLegends.exe":             "Apex Legends",
        }
        STREAMS = {
            "obs64.exe":           "OBS Studio",
            "obs32.exe":           "OBS Studio",
            "Streamlabs OBS.exe":  "Streamlabs",
        }

        while self.game_detection and self.is_running:
            game = stream = None
            try:
                for p in psutil.process_iter(["name"]):
                    n = p.info["name"]
                    if n in GAMES:   game   = GAMES[n]
                    if n in STREAMS: stream = STREAMS[n]
            except:
                pass

            if game and stream:
                self._send_status("actively_playing", game, True, stream)
                self.game_status.config(
                    text=f"🎮  {game}  +  🔴 STREAMING", fg=RED)
            elif game:
                self._send_status("actively_playing", game, False, None)
                self.game_status.config(text=f"🎮  Playing {game}", fg=RED)
            elif stream:
                self._send_status("streaming_only", None, True, stream)
                self.game_status.config(text=f"🔴  Streaming", fg=ORANGE)
            else:
                self._send_status("available", None, False, None)
                self.game_status.config(
                    text="🟢  ACTIVE — sharing your activity", fg=GREEN)

            time.sleep(5)

    def _send_status(self, status, game, is_streaming, stream_sw):
        if not self.user_code:
            return
        try:
            requests.post(f"{BACKEND_URL}/api/activity-status", json={
                "user_id":         self.user_code,
                "status":          status,
                "game":            game,
                "is_streaming":    is_streaming,
                "stream_software": stream_sw,
                "timestamp":       datetime.now().isoformat(),
            }, timeout=2)
        except:
            pass

    

    def _on_close(self):
        self.is_running = False
        if self.game_detection:
            self._send_status("available", None, False, None)
        self.root.destroy()


if __name__ == "__main__":
    CoupleSoftware()