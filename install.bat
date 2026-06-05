@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM Install .cursor agent kit into a target project directory (Windows).
REM Usage:
REM   install.bat C:\path\to\my-project
REM   install.bat .
REM   install.bat C:\path\to\project --force

set "FORCE=0"
set "TARGET="

if "%~1"=="" goto :usage
if /I "%~1"=="-h" goto :usage
if /I "%~1"=="--help" goto :usage

set "TARGET=%~1"
shift

:parse_args
if "%~1"=="" goto :args_done
if /I "%~1"=="--force" (
  set "FORCE=1"
  shift
  goto :parse_args
)
if /I "%~1"=="-h" goto :usage
if /I "%~1"=="--help" goto :usage
echo Unknown option: %~1
goto :usage

:args_done
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "SOURCE=%SCRIPT_DIR%\.cursor"

if not exist "%SOURCE%\" (
  echo Error: .cursor source not found at %SOURCE%
  exit /b 1
)

REM Resolve target to absolute path
if /I "%TARGET%"=="." set "TARGET=%CD%"
pushd "%TARGET%" 2>nul
if errorlevel 1 (
  echo Error: Target directory not found: %TARGET%
  exit /b 1
)
set "TARGET=%CD%"
popd

set "DEST=%TARGET%\.cursor"

if exist "%DEST%\" (
  if "%FORCE%"=="1" (
    for /f %%T in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMddHHmmss"') do set "STAMP=%%T"
    set "BACKUP=%TARGET%\.cursor.bak.!STAMP!"
    echo Backing up existing .cursor -^> !BACKUP!
    move "%DEST%" "!BACKUP!" >nul
    if errorlevel 1 (
      echo Error: Failed to backup existing .cursor
      exit /b 1
    )
  ) else (
    echo Error: %DEST% already exists. Use --force to replace ^(creates backup^).
    exit /b 1
  )
)

echo Installing .cursor -^> %DEST%
mkdir "%DEST%" 2>nul

REM robocopy: exit codes 0-7 = success
robocopy "%SOURCE%" "%DEST%" /E /NFL /NDL /NJH /NJS /nc /ns /np /XD .DS_Store
set "RC=%ERRORLEVEL%"
if %RC% GEQ 8 (
  echo Error: robocopy failed with code %RC%
  exit /b 1
)

mkdir "%DEST%\plans\_briefs" 2>nul
mkdir "%DEST%\plans\features" 2>nul
type nul > "%DEST%\plans\_briefs\.gitkeep" 2>nul
type nul > "%DEST%\plans\features\.gitkeep" 2>nul

echo Done.
echo Next: edit %DEST%\config\project.defaults.yaml ^(locale.chat, architecture, defaults^)
echo Note: hooks use .sh scripts — Git Bash or WSL recommended; Cursor on Windows often runs them via bundled shell.
exit /b 0

:usage
echo.
echo Usage: install.bat ^<target-project-dir^> [--force]
echo.
echo Copies this repository's .cursor\ tree into ^<target-project-dir^>\.cursor\
echo.
echo   --force   Replace existing .cursor ^(backs up to .cursor.bak.^<timestamp^>^)
echo.
echo After install:
echo   1. Edit ^<project^>\.cursor\config\project.defaults.yaml
echo   2. Open project in Cursor — hooks load from .cursor\hooks.json
echo.
exit /b 0
