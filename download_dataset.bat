:: download_dataset.bat

@echo off
:: UTF-8 인코딩 활성화 (Windows 10 이상 지원)
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
call :printslow "[INFO] 데이터셋 다운로더 스크립트를 생성합니다..."
call :log "[INFO] 데이터셋 다운로더 스크립트 생성 시작"
echo.

:: ASCII 아트 표시 (if exists)
if exist "%~dp0ascii_art.bat" (
    call "%~dp0ascii_art.bat"
)

:: White color
color 0f

echo.
call :printslow "[INFO] 데이터셋 다운로더 스크립트를 실행합니다..."
call :log "[INFO] 데이터셋 다운로더 스크립트 실행 시작"
echo.

:: 작업 디렉토리 생성 및 이동
if not exist "%USERPROFILE%\Desktop\AidALL" (
    mkdir "%USERPROFILE%\Desktop\AidALL"
)
cd /d "%USERPROFILE%\Desktop\AidALL"

:: Conda 환경 확인 및 활성화
if not exist "%USERPROFILE%\miniconda3\Scripts\activate.bat" (
    call :printslow "[ERROR] Conda가 설치되어 있지 않습니다."
    call :log "[ERROR] Conda 설치 없음"
    exit /b 1
)
call "%USERPROFILE%\miniconda3\Scripts\activate.bat" verify_results

:: gdown 설치
call :printslow "[INFO] gdown 설치 중..."
pip install -U gdown --quiet
if errorlevel 1 (
    call :printslow "[ERROR] gdown 설치 실패"
    call :log "[ERROR] gdown 설치 실패"
    exit /b 1
)
call :log "[INFO] gdown 설치 완료"

:: Google Drive 다운로드 시도
call :printslow "[INFO] Google Drive에서 데이터를 다운로드합니다..."
call :printslow "       다운로드하는 데이터셋의 크기는 약 60GB 정도 입니다."
call :printslow "       네트워크 상태에 따라 십수 분이 소요될 수 있습니다."
echo.

gdown --folder https://drive.google.com/drive/folders/1OCQee9t9GH2wra_AVjOPX4JKEManxs2q?usp=sharing
if errorlevel 1 (
    call :printslow "[WARN] Google Drive에서 데이터셋 다운로드 실패"
    call :log "[WARN] Google Drive 다운로드 실패"
    call :printslow "웹 페이지를 통해 직접 다운로드하실 수 있습니다."
    call :printslow "웹 브라우저를 실행하여 해당 링크를 제공하겠습니다."
    echo.
    call :printslow "       다운로드 완료 후 파일을 AidALL 폴더에 압축 해제해 주세요."
    echo.
    start "" "https://drive.google.com/drive/folders/1OCQee9t9GH2wra_AVjOPX4JKEManxs2q?usp=sharing"
    timeout /t 2 /nobreak > nul
    exit /b 1
)

call :printslow "[INFO] 데이터셋을 다운받을 수 있는 링크를 웹 브라우저로 표시합니다."
call :log "[INFO] 웹 브라우저 실행, 데이터셋 다운로드 링크 제공"
echo.

exit /b 0

:log
echo [%TIMESTAMP%] %* >> "%LOGFILE%"
exit /b

:printslow
echo %*
call :log %*
ping localhost -n 1 -w 200 >nul
exit /b