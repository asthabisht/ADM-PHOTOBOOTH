@echo off
REM ============================================================
REM  ADM BMW Photobooth - start in kiosk mode (Windows)
REM  Double-click to start. To exit kiosk mode: Alt+F4
REM  Before the event:
REM   - Set the photo printer as the Windows DEFAULT printer,
REM     paper 4x6 in (10x15 cm), borderless, portrait.
REM   - The first time, allow camera access when Chrome asks
REM     (this launcher remembers it in its own profile folder).
REM ============================================================

set "URL=https://adm-photobooth.netlify.app/"
set "PROFILE=%LOCALAPPDATA%\ADMBoothChrome"

set "CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" (
  echo Google Chrome was not found. Install Chrome and try again.
  pause
  exit /b 1
)

REM Close any Chrome already using the booth profile, so the flags below take effect
taskkill /F /FI "WINDOWTITLE eq ADM BMW*" >nul 2>&1

start "" "%CHROME%" ^
  --user-data-dir="%PROFILE%" ^
  --kiosk "%URL%" ^
  --kiosk-printing ^
  --use-fake-ui-for-media-stream ^
  --autoplay-policy=no-user-gesture-required ^
  --disable-pinch ^
  --overscroll-history-navigation=0 ^
  --no-first-run ^
  --no-default-browser-check ^
  --disable-features=TranslateUI ^
  --disable-session-crashed-bubble ^
  --noerrdialogs
