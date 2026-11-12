@echo off
REM ============================================================
REM  ADM BMW Photobooth - one-time printer setup
REM  Opens the booth in a NORMAL Chrome window using the same
REM  profile as "START BOOTH (kiosk).bat". Kiosk printing re-uses
REM  the print settings you choose here, so do this once:
REM
REM   1. Take a test photo in the booth and go to the QR screen.
REM   2. Press Ctrl+P (do NOT press the PRINT button).
REM   3. Destination: your photo printer
REM      Paper size:  4x6 in / 10x15 cm (may be called 6x4 or PC)
REM      Margins:     None
REM      Scale:       Default (or Fit to printable area)
REM      Options:     tick "Print as image" if prints come out blank
REM   4. Click Print and check the photo comes out correctly.
REM   5. Close this window, then start "START BOOTH (kiosk).bat".
REM ============================================================

set "URL=https://adm-photobooth.netlify.app/?debug"
set "PROFILE=%LOCALAPPDATA%\ADMBoothChrome"

set "CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" (
  echo Google Chrome was not found. Install Chrome and try again.
  pause
  exit /b 1
)

start "" "%CHROME%" --user-data-dir="%PROFILE%" --new-window --no-first-run --no-default-browser-check "%URL%"
