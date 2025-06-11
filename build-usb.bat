@echo off
setlocal

set ISO_URL=https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.5.0-amd64-netinst.iso
set ISO=debian-12.5.0-amd64-netinst.iso

if not exist "%ISO%" (
  echo Downloading Debian ISO...
  curl -L -o "%ISO%" "%ISO_URL%"
)

echo.
echo Available drives:
wmic logicaldisk get name
echo.

set /p USB="Enter USB drive letter (just the letter, e.g. E): "
set USB=%USB:~0,1%
set USBPATH=%USB%:\

echo Using drive %USBPATH%

rufus.exe --quiet --device %USB% --format --noninteractive --iso "%ISO%"
if %errorlevel% neq 0 (
  echo Rufus failed.
  pause
  exit /b %errorlevel%
)

echo.
echo Copying preseed.cfg to USB...
copy preseed.cfg "%USBPATH%"

echo Done!
pause
