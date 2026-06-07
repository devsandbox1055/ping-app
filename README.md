<div align="left">
<img src="assets/images/app_logo.png" width="100" height="100" alt="Ping Logo"/>

PING
Gaming? You'll Know.
"She always knew when I was ignoring her. But she never knew I was in the middle of a ranked match."

</div>

The Story Behind Ping
I love gaming. Valorant especially..but also CS2, GTA V, and whatever else pulls me in. Once I lock in, I'm fully locked in. Headphones on, nothing else exists.
But my girlfriend didn't know that.
Every time I didn't pick up her call mid-game, the spiral would begin on her end. Is he ignoring me? Did I do something wrong? Why isn't he responding? The anxiety, the overthinking, the assumptions, all because she had absolutely no way of knowing I was in the middle of a Valorant ranked match, two kills away from clutching a 1v3.
I didn't want her to feel that way. I never was ignoring her...I just couldn't hear the phone over gunshots and callouts.
But I also couldn't pause a competitive game every few minutes to send a "babe I'm gaming, give me 15 mins" text. That's not how ranked works.
So I built Ping.
Now she opens the app and sees:
"Playing Valorant ...Active Now"
She gets it. No more anxiety. No more overthinking. She knows exactly what I'm doing, and understands why I'm not responding.
And if there's a genuine emergency? She hits the Urgent Ping button ,and I get a notification on my PC that cuts through without the game even flickering. No minimize, no disconnect, no losing the match.
That's it. That's the whole story. Built out of love, fueled by ranked games, and slightly inspired by one too many worried phone calls.

What is Ping?
Ping is a real-time couple connectivity system built in three parts:
PartTechPurpose Mobile AppFlutter (Android)Partner sees live status PC Desktop AppPython + TkinterDetects games, runs silentl  BackendFastAPI (Python)Connects everything
No accounts. No social media. Just an 8-digit code, and you're connected.

Urgent Ping — The Most Important Feature
When something is genuinely important, she can send an Urgent Message that:

~Delivers a notification directly to the PC
~Does NOT minimize or interrupt the game ← this was the hardest part to build
~Plays an alert sound that actually gets through
~Works in fullscreen exclusive games (Valorant, CS2, GTA V)


Code saves automatically. Never enter it again.
Zero-Impact Background Mode

Runs silently, no performance hit
Detects games and streaming software automatically
Updates every 3 seconds
Starts with Windows (optional)


Tech Stack
Mobile App

Flutter + Dart
http — API calls
shared_preferences — Persistent login
path_provider — Local session storage

PC Desktop App

Python 3.8+ + Tkinter (UI)
psutil — Game process detection
pywin32 — Windows API (win32gui, win32process)
requests — Backend communication
plyer + PowerShell WinRT — Non-intrusive notifications

Backend
FastAPI + Uvicorn
Pure in-memory storage (lightweight by design)
Zero database dependency


Games it can Detect Now
Valorant, Counter-Strike 2, Rocket League
GTA V ,Cyberpunk 2077,Minecraft
Fortnite, Apex Legends, Overwatch
League of Legends, Dota 2


API Reference

POST/api/generate-codeGenerate pairing code

POST/api/verify-codeAuthenticate mobile

POST/api/pc-connect/{code}Register PC

GET/api/check-auth/{code}Check partner connected

POST/api/activity-statusUpdate game/stream status

GET/api/get-activity/{user_id}Get live activity

POST/api/send-urgent-messageSend urgent ping

GET/api/get-messages/{user_id}Poll messages

DELETE/api/clear-messages/{user_id}Clear messages



What's Next
iOS support

More games & streaming software

Auto-start with Windows

Group Activity Support(for gaming groups of friends)

Contributing
Personal project, but PRs are welcome!
<div align="center">

Made with ❤️ for her.
She asked for a louder notification sound.
Apparently, according to her, my hearing isn't exactly great.
So please bear with it. 😅


 Star this if you've ever missed a call because you were in a ranked match
 </div>
