@echo off
REM ============================================================
REM  ADM BMW Photobooth - clear stuck print jobs (Windows)
REM  Double-click. Click "Yes" when Windows asks for permission.
REM  Use it when the printer keeps printing blank pages, or
REM  prints by itself as soon as it is switched on.
REM ============================================================

REM --- re-open as administrator if needed ---
net session >nul 2>&1
if %errorlevel% neq 0 (
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

echo.
echo  1. Turn the PRINTER OFF now (leave it off), then press any key.
pause >nul

echo  Stopping the Windows print service...
net stop spooler /y >nul 2>&1

echo  Deleting all stuck print jobs...
del /Q /F /S "%systemroot%\System32\spool\PRINTERS\*" >nul 2>&1

echo  Starting the print service again...
net start spooler >nul 2>&1

echo.
echo  Done - the print queue is empty.
echo  2. Turn the printer back ON. It should stay quiet.
echo  3. Test with ONE photo from the Windows Photos app (4x6) before using the booth.
echo.
pause
