@echo off
REM ============================================================================
REM Auctionator AddOn Symbolic Link Script
REM ============================================================================
REM This script creates symbolic links from this repository to your WoW AddOns
REM directory. Changes made in the repo will immediately be reflected in-game.
REM
REM REQUIREMENTS:
REM   1. Must be run as Administrator (for mklink permissions)
REM   2. WOW_ADDONS_PATH environment variable must be set
REM
REM TO SET THE ENVIRONMENT VARIABLE:
REM   1. Open System Properties > Advanced > Environment Variables
REM   2. Create a new User or System variable:
REM      Variable name: WOW_ADDONS_PATH
REM      Variable value: C:\Path\To\World of Warcraft\_retail_\Interface\AddOns
REM   3. Click OK and restart any open command prompts
REM
REM EXAMPLE PATHS:
REM   Retail: C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns
REM   Classic Era: C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns
REM   Classic: C:\Program Files (x86)\World of Warcraft\_classic_\Interface\AddOns
REM ============================================================================

setlocal

REM Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script requires Administrator privileges.
    echo Please right-click the script and select "Run as administrator"
    pause
    exit /b 1
)

REM Check if WOW_ADDONS_PATH environment variable is set
if "%WOW_ADDONS_PATH%"=="" (
    echo ERROR: WOW_ADDONS_PATH environment variable is not set.
    echo.
    echo Please set the WOW_ADDONS_PATH environment variable to your WoW AddOns directory.
    echo Example: C:\Program Files ^(x86^)\World of Warcraft\_retail_\Interface\AddOns
    echo.
    echo See the instructions at the top of this script for details.
    pause
    exit /b 1
)

REM Validate that the AddOns directory exists
if not exist "%WOW_ADDONS_PATH%" (
    echo ERROR: The path specified in WOW_ADDONS_PATH does not exist:
    echo %WOW_ADDONS_PATH%
    echo.
    echo Please verify the path and update the environment variable.
    pause
    exit /b 1
)

REM Get the directory where this script is located (the repo root)
set REPO_DIR=%~dp0
set REPO_DIR=%REPO_DIR:~0,-1%

echo ============================================================================
echo Auctionator AddOn Linker
echo ============================================================================
echo.
echo Repository: %REPO_DIR%
echo Target:     %WOW_ADDONS_PATH%
echo.

REM Define the addon folders to link
set ADDON1=Auctionator
set ADDON2=Auctionator_Price_Database
set ADDON3=Auctionator_Pricing_History

REM Remove existing symlinks or directories if they exist
echo Cleaning up existing links/folders...
if exist "%WOW_ADDONS_PATH%\%ADDON1%" (
    rmdir "%WOW_ADDONS_PATH%\%ADDON1%" 2>nul
    if exist "%WOW_ADDONS_PATH%\%ADDON1%" (
        echo WARNING: Could not remove %ADDON1% - it may contain files. Please remove manually.
    ) else (
        echo   Removed: %ADDON1%
    )
)
if exist "%WOW_ADDONS_PATH%\%ADDON2%" (
    rmdir "%WOW_ADDONS_PATH%\%ADDON2%" 2>nul
    if exist "%WOW_ADDONS_PATH%\%ADDON2%" (
        echo WARNING: Could not remove %ADDON2% - it may contain files. Please remove manually.
    ) else (
        echo   Removed: %ADDON2%
    )
)
if exist "%WOW_ADDONS_PATH%\%ADDON3%" (
    rmdir "%WOW_ADDONS_PATH%\%ADDON3%" 2>nul
    if exist "%WOW_ADDONS_PATH%\%ADDON3%" (
        echo WARNING: Could not remove %ADDON3% - it may contain files. Please remove manually.
    ) else (
        echo   Removed: %ADDON3%
    )
)
echo.

REM Create symbolic links for each addon
echo Creating symbolic links...

mklink /D "%WOW_ADDONS_PATH%\%ADDON1%" "%REPO_DIR%\%ADDON1%"
if %errorLevel% equ 0 (
    echo   [OK] %ADDON1%
) else (
    echo   [FAILED] %ADDON1%
)

mklink /D "%WOW_ADDONS_PATH%\%ADDON2%" "%REPO_DIR%\%ADDON2%"
if %errorLevel% equ 0 (
    echo   [OK] %ADDON2%
) else (
    echo   [FAILED] %ADDON2%
)

mklink /D "%WOW_ADDONS_PATH%\%ADDON3%" "%REPO_DIR%\%ADDON3%"
if %errorLevel% equ 0 (
    echo   [OK] %ADDON3%
) else (
    echo   [FAILED] %ADDON3%
)

echo.
echo ============================================================================
echo Done! Your Auctionator addons are now linked.
echo Any changes you make in the repository will immediately appear in-game.
echo ============================================================================
echo.
pause
