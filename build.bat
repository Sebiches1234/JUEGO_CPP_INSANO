@echo off
setlocal enabledelayedexpansion

:: --- CONFIGURATION ---
set EXENAME=juego.exe
set MSYS_SHELL_PATH=C:\msys64\msys2_shell.cmd

:: --- INITIAL MODULE STATES (1 = enabled, 0 = disabled) ---
set MOD_BASE=1
set MOD_IMAGE=1
set MOD_AUDIO=1
set MOD_ACODEC=1
set MOD_PRIMITIVES=1
set MOD_FONT=1
set MOD_TTF=1
set MOD_COLOR=0
set MOD_DIALOG=0
set MOD_VIDEO=0

:MAIN_MENU
cls
echo ===================================================
echo             ALLEGRO 5 BUILD MANAGER (UCRT64)
echo ===================================================
echo  1. Compile Game (.cpp to .exe)
echo  2. Run Game (%EXENAME%)
echo  3. Open MSYS2 UCRT64 Terminal Here
echo  4. Exit
echo ===================================================
echo.
set /p choice="Select an option (1-4): "

if "%choice%"=="1" goto COMPILE_MENU
if "%choice%"=="2" goto RUN_GAME
if "%choice%"=="3" goto OPEN_MSYS
if "%choice%"=="4" exit
goto MAIN_MENU

:: -----------------------------------------------------
:: COMPILATION MODULE MENU
:: -----------------------------------------------------
:COMPILE_MENU
cls
echo ===================================================
echo          SELECT ALLEGRO 5 MODULES TO INCLUDE
echo ===================================================
echo  [Toggle options by entering the number/letter]
echo.
if "%MOD_BASE%"=="1"       (echo  1. [X] Base Allegro)       else (echo  1. [ ] Base Allegro)
if "%MOD_IMAGE%"=="1"      (echo  2. [X] Image Addon)        else (echo  2. [ ] Image Addon)
if "%MOD_AUDIO%"=="1"      (echo  3. [X] Audio Addon)        else (echo  3. [ ] Audio Addon)
if "%MOD_ACODEC%"=="1"     (echo  4. [X] Audio Codec Addon)   else (echo  4. [ ] Audio Codec Addon)
if "%MOD_PRIMITIVES%"=="1" (echo  5. [X] Primitives Vector Shapes) else (echo  5. [ ] Primitives Vector Shapes)
if "%MOD_FONT%"=="1"       (echo  6. [X] Font Addon)         else (echo  6. [ ] Font Addon)
if "%MOD_TTF%"=="1"        (echo  7. [X] TrueType Font TTF)  else (echo  7. [ ] TrueType Font TTF)
if "%MOD_COLOR%"=="1"      (echo  8. [X] Color Conversion)   else (echo  8. [ ] Color Conversion)
if "%MOD_DIALOG%"=="1"     (echo  9. [X] Native Dialogs)     else (echo  9. [ ] Native Dialogs)
if "%MOD_VIDEO%"=="1"      (echo  0. [X] Video Streaming)    else (echo  0. [ ] Video Streaming)
echo.
echo  C. START COMPILATION
echo  B. Back to Main Menu
echo ===================================================
echo.
set /p comp_choice="Select an option: "

if "%comp_choice%"=="1" goto TOGGLE_BASE
if "%comp_choice%"=="2" goto TOGGLE_IMAGE
if "%comp_choice%"=="3" goto TOGGLE_AUDIO
if "%comp_choice%"=="4" goto TOGGLE_ACODEC
if "%comp_choice%"=="5" goto TOGGLE_PRIM
if "%comp_choice%"=="6" goto TOGGLE_FONT
if "%comp_choice%"=="7" goto TOGGLE_TTF
if "%comp_choice%"=="8" goto TOGGLE_COLOR
if "%comp_choice%"=="9" goto TOGGLE_DIALOG
if "%comp_choice%"=="0" goto TOGGLE_VIDEO

if /i "%comp_choice%"=="b" goto MAIN_MENU
if /i "%comp_choice%"=="c" goto DO_COMPILE
goto COMPILE_MENU

:: --- Toggle Processing Blocks ---
:TOGGLE_BASE
if "%MOD_BASE%"=="1" (set MOD_BASE=0) else (set MOD_BASE=1)
goto COMPILE_MENU

:TOGGLE_IMAGE
if "%MOD_IMAGE%"=="1" (set MOD_IMAGE=0) else (set MOD_IMAGE=1)
goto COMPILE_MENU

:TOGGLE_AUDIO
if "%MOD_AUDIO%"=="1" (set MOD_AUDIO=0) else (set MOD_AUDIO=1)
goto COMPILE_MENU

:TOGGLE_ACODEC
if "%MOD_ACODEC%"=="1" (set MOD_ACODEC=0) else (set MOD_ACODEC=1)
goto COMPILE_MENU

:TOGGLE_PRIM
if "%MOD_PRIMITIVES%"=="1" (set MOD_PRIMITIVES=0) else (set MOD_PRIMITIVES=1)
goto COMPILE_MENU

:TOGGLE_FONT
if "%MOD_FONT%"=="1" (set MOD_FONT=0) else (set MOD_FONT=1)
goto COMPILE_MENU

:TOGGLE_TTF
if "%MOD_TTF%"=="1" (set MOD_TTF=0) else (set MOD_TTF=1)
goto COMPILE_MENU

:TOGGLE_COLOR
if "%MOD_COLOR%"=="1" (set MOD_COLOR=0) else (set MOD_COLOR=1)
goto COMPILE_MENU

:TOGGLE_DIALOG
if "%MOD_DIALOG%"=="1" (set MOD_DIALOG=0) else (set MOD_DIALOG=1)
goto COMPILE_MENU

:TOGGLE_VIDEO
if "%MOD_VIDEO%"=="1" (set MOD_VIDEO=0) else (set MOD_VIDEO=1)
goto COMPILE_MENU


:: -----------------------------------------------------
:: COMPILATION LOGIC (Forced inside UCRT64 environment)
:: -----------------------------------------------------
:DO_COMPILE
cls
if not exist "%MSYS_SHELL_PATH%" goto PATH_ERROR

echo Constructing build command...
set PKG_FLAGS=
if "%MOD_BASE%"=="1"       set PKG_FLAGS=!PKG_FLAGS! allegro-5
if "%MOD_IMAGE%"=="1"      set PKG_FLAGS=!PKG_FLAGS! allegro_image-5
if "%MOD_AUDIO%"=="1"      set PKG_FLAGS=!PKG_FLAGS! allegro_audio-5
if "%MOD_ACODEC%"=="1"     set PKG_FLAGS=!PKG_FLAGS! allegro_acodec-5
if "%MOD_PRIMITIVES%"=="1" set PKG_FLAGS=!PKG_FLAGS! allegro_primitives-5
if "%MOD_FONT%"=="1"       set PKG_FLAGS=!PKG_FLAGS! allegro_font-5
if "%MOD_TTF%"=="1"        set PKG_FLAGS=!PKG_FLAGS! allegro_ttf-5
if "%MOD_COLOR%"=="1"      set PKG_FLAGS=!PKG_FLAGS! allegro_color-5
if "%MOD_DIALOG%"=="1"     set PKG_FLAGS=!PKG_FLAGS! allegro_dialog-5
if "%MOD_VIDEO%"=="1"      set PKG_FLAGS=!PKG_FLAGS! allegro_video-5

echo Target flags: %PKG_FLAGS%
echo Running compiler through MSYS2 UCRT64...

call "%MSYS_SHELL_PATH%" -ucrt64 -here -defterm -no-start -c "g++ main.cpp -o %EXENAME% $(pkg-config --cflags --libs %PKG_FLAGS%)"

if %ERRORLEVEL% equ 0 (
    echo.
    echo [SUCCESS] Compilation finished flawlessly.
) else (
    echo.
    echo [ERROR] Compilation failed.
)
pause
goto MAIN_MENU

:: -----------------------------------------------------
:: RUN GAME LOGIC
:: -----------------------------------------------------
:RUN_GAME
cls
if not exist %EXENAME% (
    echo [ERROR] %EXENAME% not found! Please compile the game first.
    pause
    goto MAIN_MENU
)
echo Launching %EXENAME% through UCRT64 shell context...
echo ---------------------------------------------------
call "%MSYS_SHELL_PATH%" -ucrt64 -here -defterm -no-start -c "./%EXENAME%"
echo ---------------------------------------------------
echo Game process terminated.
pause
goto MAIN_MENU

:: -----------------------------------------------------
:: DEBUG / OPEN MSYS2 TERMINAL WINDOW
:: -----------------------------------------------------
:OPEN_MSYS
cls
if not exist "%MSYS_SHELL_PATH%" goto PATH_ERROR
echo Launching full interactive MSYS2 UCRT64 environment...
start "" "%MSYS_SHELL_PATH%" -ucrt64 -here
goto MAIN_MENU

:PATH_ERROR
echo [CRITICAL ERROR] Could not locate MSYS2 tool helper at: %MSYS_SHELL_PATH%
pause
goto MAIN_MENU