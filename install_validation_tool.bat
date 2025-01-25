:: install_validation_tool.bat

@echo off
:: UTF-8 인코딩 활성화 (Windows 10 이상 지원)
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 데이터셋 검증 도구 설치 디렉토리 생성
if not exist "%USERPROFILE%\Desktop\AidALL" (
    echo.
    echo [DEBUG]: 바탕화면에 AidALL 폴더 생성을 시도합니다...
    pause
    mkdir "%USERPROFILE%\Desktop\AidALL"
    echo.
    echo after mkdir, errorlevel=%errorlevel%
    echo [DEBUG]: 에러코드 %errorlevel%, 디렉토리 생성 성공
    if errorlevel 1 (
        echo.
        echo [ERROR] 디렉토리 생성 실패
        exit /b 1
    )
    echo [DEBUG]: 바탕화면에 AidALL 폴더가 생성되었습니다.
    echo.
)

:: 로그 설정
set LOGDIR="%USERPROFILE%\Desktop\AidALL"
set LOGFILE="%USERPROFILE%\Desktop\AidALL\install_log.txt"

:: date 와 time 변수 활용
set "CURRENT_DATETIME=%date%_%time%"

:: time 변수에서 오전/오후 정보 추출
for /f "tokens=1 delims= " %%a in ("%time%") do set "HOUR=%%a"

:: HOUR 변수 값 출력
rem echo HOUR 변수 값: "%HOUR%"

:: HOUR 변수에서 콜론(:)과 마침표(.) 제거
set "HOUR=!HOUR::=!"
set "HOUR=!HOUR:.=!"

:: HOUR 변수를 숫자로 변환
set /a "HOUR_TEMP=%HOUR%" 
if errorlevel 1 (
    echo [ERROR] HOUR 변수를 숫자로 변환하는 중 오류 발생: "%HOUR%"
    pause  
    exit /b 1
) else (
    set "HOUR=%HOUR_TEMP%"
)
:: 오전/오후 판별 (수정된 부분)
if !HOUR! geq 12 (
    set /a "HOUR_OFFSET=12"
) else (
    set /a "HOUR_OFFSET=0"
)

:: 오전/오후 정보를 숫자로 변환 (오전: 0, 오후: 12)
if "!AMPM!"=="오후" set /a "HOUR_OFFSET=12"
if "!AMPM!"=="오전" set /a "HOUR_OFFSET=0"

:: 불필요한 문자 제거 및 형식 변경
set "CURRENT_DATETIME=!CURRENT_DATETIME:-=!"
set "CURRENT_DATETIME=!CURRENT_DATETIME::=!"
set "CURRENT_DATETIME=!CURRENT_DATETIME:.=!"
set "CURRENT_DATETIME=!CURRENT_DATETIME:/=!"
set "CURRENT_DATETIME=!CURRENT_DATETIME: =!" 
set "CURRENT_DATETIME=!CURRENT_DATETIME:~0,14!"

:: 시간 부분 추출 및 오전/오후 시간으로 변환
set "HH=!CURRENT_DATETIME:~8,2!"
set /a "HH=!HH! + !HOUR_OFFSET!"
if !HH! lss 10 set "HH=0!HH!" 

:: YYYY-MM-DD_HH-MM-SS 형식으로 변환
set "YYYY=!CURRENT_DATETIME:~0,4!"
set "MM=!CURRENT_DATETIME:~4,2!"
set "DD=!CURRENT_DATETIME:~6,2!"
set "MN=!CURRENT_DATETIME:~10,2!"
set "SS=!CURRENT_DATETIME:~12,2!"
set "CURRENT_DATETIME=!YYYY!-!MM!-!DD!_!HH!-!MN!-!SS!"

echo [DEBUG] 에러코드 !errorlevel!, 날짜 및 시간 정보 처리 완료
echo 현재시각=!CURRENT_DATETIME!
pause

set "TIMESTAMP=!CURRENT_DATETIME!"

:: ASCII 아트 표시
call "%~dp0ascii_art.bat"

:: White 색상 출력
color 0f

:: 콘솔 창 제목 & 색상
echo ============================================
echo   AidALL Inc. 데이터셋 검증 도구 설치 마법사
echo ============================================
echo.
call :log "[INFO] 설치 마법사 시작"

call :printslow 지금부터 에이드올 데이터셋 검증 도구 설치를 시작합니다.
echo.
timeout /t 1 /nobreak >nul

echo 설치를 원하시면 키보드에서 y 키를 찾아 눌러 주십시오.
echo.
timeout /t 1 /nobreak >nul

choice /c yn /n /m "계속하시겠습니까? (Y/N)"
if errorlevel 2 (
   call :log "[INFO] 사용자가 설치를 취소했습니다."
   exit /b 0
)

::create_directories
call :printslow "[INFO] 바탕화면에 AidALL 디렉토리를 생성합니다..."
echo.
timeout /t 1 /nobreak >nul

echo ============================================
call :printslow "AidALL 디렉토리에는 Labelme 바로가기가 있으며"
call :printslow "로그 파일도 확인할 수 있습니다."
call :printslow "또한, 내려받은 데이터셋 파일도 확인할 수 있습니다."
echo ============================================
echo.
timeout /t 1 /nobreak >nul

call :printslow "[CHECK] 기존 Miniconda 설치 여부를 확인합니다..."
call :log "[INFO] Miniconda 설치 검사 시작"
echo.
timeout /t 1 /nobreak >nul

:: 사용자 프로필 경로 확인
if exist "%USERPROFILE%\miniconda3" (
   call :printslow "[INFO] 기존 Miniconda 디렉토리를 발견했습니다: %USERPROFILE%\miniconda3"
   echo.
   timeout /t 1 /nobreak >nul
   call :log "[INFO] 기존 Miniconda 발견: %USERPROFILE%\miniconda3"

   if exist "%USERPROFILE%\miniconda3\Uninstall-Miniconda3.exe" (
       call :printslow "[INFO] Miniconda Uninstaller를 발견했습니다."
       echo.
       timeout /t 1 /nobreak >nul
       
       call :printslow "[INFO] Miniconda Uninstaller로 제거를 시도합니다..."
       echo.
       timeout /t 1 /nobreak >nul

       start /wait "" "%USERPROFILE%\miniconda3\Uninstall-Miniconda3.exe" /S
       if errorlevel 1 (
           call :printslow "[ERROR] 언인스톨 중 오류가 발생했습니다."
           echo.
           call :printslow "        수동으로 삭제하거나, 설치 디렉토리를 직접 제거해야 할 수 있습니다."
           call :log "[ERROR] Miniconda Uninstaller 실행 실패"
           echo.
           pause
           exit /b 1
       )
       call :log "[INFO] Miniconda Uninstaller 실행 완료"
       timeout /t 5 /nobreak > nul
   ) else (
       call :printslow "[WARN] Miniconda Uninstaller가 없습니다. 설치가 손상되었을 수 있습니다."
       echo.
       timeout /t 1 /nobreak >nul
       
       call :printslow "[INFO] 기존 Miniconda 디렉토리를 삭제합니다..."
       call :log "[INFO] 수동으로 Miniconda 디렉토리 삭제 시도"
       echo.
   )
   
   rmdir /s /q "%USERPROFILE%\miniconda3"
   if errorlevel 1 (
       call :printslow "[ERROR] Miniconda 디렉토리 삭제 실패"
       call :log "[ERROR] Miniconda 디렉토리 삭제 실패"
       exit /b 1
   )
   call :printslow "[INFO] 기존 Miniconda 제거 완료"
   call :log "[INFO] Miniconda 제거 완료"
)

:: ProgramData 경로 확인
if exist "C:\ProgramData\miniconda3" (
   echo.
   call :printslow "[INFO] 기존 Miniconda 디렉토리를 발견했습니다: C:\ProgramData\miniconda3"
   echo.
   timeout /t 1 /nobreak >nul
   call :log "[INFO] 기존 Miniconda 발견: C:\ProgramData\miniconda3"

   if exist "C:\ProgramData\miniconda3\Uninstall-Miniconda3.exe" (
       call :printslow "[INFO] Miniconda Uninstaller를 발견했습니다."
       echo.
       timeout /t 1 /nobreak >nul
       
       call :printslow "[INFO] Miniconda Uninstaller로 제거를 시도합니다..."
       echo.
       timeout /t 1 /nobreak >nul

       start /wait "" "C:\ProgramData\miniconda3\Uninstall-Miniconda3.exe" /S
       if errorlevel 1 (
           call :printslow "[ERROR] 언인스톨 중 오류가 발생했습니다."
           echo.
           call :printslow "        수동으로 삭제하거나, 설치 디렉토리를 직접 제거해야 할 수 있습니다."
           call :log "[ERROR] Miniconda Uninstaller 실행 실패"
           echo.
           pause
           exit /b 1
       )
       call :log "[INFO] Miniconda Uninstaller 실행 완료"
       timeout /t 5 /nobreak > nul
   ) else (
       call :printslow "[WARN] Miniconda Uninstaller가 없습니다. 설치가 손상되었을 수 있습니다."
       echo.
       timeout /t 1 /nobreak >nul
       
       call :printslow "[INFO] 기존 Miniconda 디렉토리를 삭제합니다..."
       call :log "[INFO] 수동으로 Miniconda 디렉토리 삭제 시도"
       echo.
   )
   
   rmdir /s /q "C:\ProgramData\miniconda3"
   if errorlevel 1 (
       call :printslow "[ERROR] Miniconda 디렉토리 삭제 실패"
       call :log "[ERROR] Miniconda 디렉토리 삭제 실패"
       exit /b 1
   )
   call :printslow "[INFO] 기존 Miniconda 제거 완료"
   call :log "[INFO] Miniconda 제거 완료"
)

call :printslow "[INFO] Miniconda 최신 버전을 다운로드합니다..."
call :log "[INFO] Miniconda 다운로드 시작"
echo.
timeout /t 1 /nobreak >nul

cd /d %USERPROFILE%
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe -o miniconda.exe
if not exist "%USERPROFILE%\miniconda.exe" (
   call :printslow "[ERROR] Miniconda 설치 파일 다운로드에 실패했습니다."
   call :log "[ERROR] Miniconda 다운로드 실패"
   echo.
   call :printslow "인터넷 연결을 확인해 주십시오."
   echo.
   pause
   exit /b 1
)
call :log "[INFO] Miniconda 다운로드 완료"

call :printslow "[INFO] Miniconda를 설치합니다..."
call :log "[INFO] Miniconda 설치 시작"
echo.
timeout /t 1 /nobreak >nul

start /wait "" .\miniconda.exe /S
if errorlevel 1 (
   call :printslow "[ERROR] Miniconda 설치에 실패했습니다."
   call :log "[ERROR] Miniconda 설치 실패"
   echo.
   call :printslow "설치 파일을 확인해 주십시오."
   echo.
   pause
   exit /b 1
)
del .\miniconda.exe
call :log "[INFO] Miniconda 설치 완료"

echo.
call :printslow "[INFO] Miniconda 버전은 다음과 같습니다."
"%USERPROFILE%\Miniconda3\Scripts\conda.exe" --version
call :log "[INFO] Miniconda 버전 확인 완료"
echo.

call :printslow "[INFO] Miniconda 환경이 초기화되었습니다."
call :log "[INFO] Miniconda 환경 초기화 완료"
echo.

call :printslow "[INFO] Conda 가상환경을 생성합니다..."
call :log "[INFO] Conda 가상환경 생성 시작"
echo.
timeout /t 1 /nobreak >nul

call "%USERPROFILE%\Miniconda3\Scripts\activate.bat"
call conda create -n verify_results python=3.12 -y

if errorlevel 1 (
   call :printslow "[ERROR] Conda 가상환경 생성에 실패했습니다."
   call :log "[ERROR] Conda 가상환경 생성 실패"
   pause
   exit /b 1
)

call :printslow "[INFO] Conda 가상환경이 생성되었습니다."
call :printslow "[INFO] 생성한 Conda 가상환경 이름은 'verify_results' 입니다."
call :log "[INFO] Conda 가상환경 'verify_results' 생성 완료"
echo.

echo conda_env_setup_complete > "%USERPROFILE%\Desktop\AidALL\status.txt"

call :printslow "[INFO] Labelme를 설치합니다..."
call :log "[INFO] Labelme 설치 시작"
echo.
timeout /t 1 /nobreak >nul

call "%USERPROFILE%\miniconda3\Scripts\activate.bat" verify_results
pip install labelme
if errorlevel 1 (
   call :printslow "[ERROR] Labelme 설치 실패"
   call :log "[ERROR] Labelme 설치 실패"
   exit /b 1
)
call :log "[INFO] Labelme 설치 완료"

:: Download dataset
call :printslow "[INFO] 데이터셋 다운로드를 시작합니다..."
call :log "[INFO] 데이터셋 다운로드 프로세스 시작"
echo.
timeout /t 1 /nobreak >nul

call "%~dp0download_dataset.bat"
if errorlevel 1 (
    call :printslow "[INFO] 데이터셋은 웹 브라우저를 통해 직접 다운로드해 주시기 바랍니다."
    call :printslow "       다운로드가 완료되면 AidALL 폴더에 압축을 풀어주세요."
    call :log "[INFO] 데이터셋 수동 다운로드 안내 완료"
    echo.
)

::create_shortcut
call :printslow "[INFO] 바로가기를 생성합니다..."
call :log "[INFO] 바로가기 생성 시작"
echo.
timeout /t 1 /nobreak >nul

echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\CreateShortcut.vbs"
echo sLinkFile = "%USERPROFILE%\Desktop\AidALL\LabelMe.lnk" >> "%TEMP%\CreateShortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\CreateShortcut.vbs"
echo oLink.TargetPath = "%~dp0run_labelme.bat" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.WorkingDirectory = "%~dp0" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Save >> "%TEMP%\CreateShortcut.vbs"

cscript //nologo "%TEMP%\CreateShortcut.vbs"
if errorlevel 1 (
   call :printslow "[ERROR] 바로가기 생성 실패"
   call :log "[ERROR] 바로가기 생성 실패"
   exit /b 1
)
del "%TEMP%\CreateShortcut.vbs"
call :log "[INFO] 바로가기 생성 완료"
timeout /t 2 /nobreak >nul

echo.
call :printslow "[INFO] 데이터 세트 검증 도구 설치가 완료되었습니다."
call :log "[INFO] 설치 완료"
call :printslow 바탕화면의 AidALL 폴더에서 LabelMe 바로가기를 실행하실 수 있습니다.
echo.

:: 설치 완료 메시지 및 종료
echo.
call :printslow "[INFO] 모든 프로세스가 정상적으로 완료되었습니다."
call :log "[INFO] 설치 프로세스 완료"
echo.
call :printslow "명령 프롬프트를 닫으시려면 아무 키나 눌러 주십시오."
call :printslow "Press any key to close..."
echo.
pause > nul
exit /b 0

:: 로그 기록 함수
:log
echo [%TIMESTAMP%] %* >> %LOGFILE%
exit /b

:: :printslow - 한 줄씩 천천히 출력 (0.2초 간격)
:printslow
echo %*
call :log %*
ping localhost -n 1 -w 200 >nul
exit /b