@echo OFF

setlocal ENABLEEXTENSIONS
set KEY_NAME="HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\World of Warcraft Classic"
set VALUE_NAME=InstallLocation

FOR /F "usebackq skip=2 tokens=3*" %%A IN (`REG QUERY %KEY_NAME% /v %VALUE_NAME% 2^>nul`) DO (
    set WoWDir="%%A %%B"
)

if defined WoWDir (
    start "" %Wowdir%\_classic_\WowClassic.exe
    @echo Classic Install Path = %WoWDir%
) else (
    @echo "World of Warcraft Classic is not installed" 
)

rem SET Wowdir="%ProgramFiles(x86)%\World of Warcraft\_classic_"
rem start "" %Wowdir%\Wow.exe