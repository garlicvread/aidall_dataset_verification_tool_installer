:: run_labelme.bat

@echo off
:: UTF-8 인코딩 활성화 (Windows 10 이상 지원)
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ASCII 아트 표시
call "%~dp0ascii_art.bat"

:: 콘솔 창 제목 & 색상
title Labelme 실행기
color 0a

echo.
echo =============================
echo   AidALL Inc. Labelme 실행기  
echo =============================
echo.

call "%USERPROFILE%\miniconda3\Scripts\activate.bat" verify_results
if errorlevel 1 (
    echo [ERROR] Conda 환경 활성화 실패
    pause
    exit /b 1
)

labelme
if errorlevel 1 (
    echo [ERROR] LabelMe 실행 실패
    pause
    exit /b 1
)

exit /b 0