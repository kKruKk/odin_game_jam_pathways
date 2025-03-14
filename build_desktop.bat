@echo off

set OUT_DIR=build\desktop
if not exist %OUT_DIR% mkdir %OUT_DIR%

::odin build source\main_desktop -vet -strict-style -out:%OUT_DIR%\game_desktop.exe
odin build source\main_desktop -o:aggressive -vet-cast -vet-semicolon -vet-shadowing  -vet-unused-variables -vet-using-param -vet-using-stmt -warnings-as-errors -out:%OUT_DIR%\game_desktop.exe

IF %ERRORLEVEL% NEQ 0 exit /b 1

xcopy /y /e /i assets %OUT_DIR%\assets >nul
IF %ERRORLEVEL% NEQ 0 exit /b 1

echo Desktop build created in %OUT_DIR%