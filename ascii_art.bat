:: ascii_art.bat

@echo off
setlocal EnableDelayedExpansion

:: Green 색상 출력
color 0a

:show_ascii_art
:: ASCII 아트 정의
set "art[0]=                                                                                                 "
set "art[1]=                                                                                                 "
set "art[2]=            _/_/    _/        _/    _/_/    _/        _/            _/_/_/                       "
set "art[3]=         _/    _/        _/_/_/  _/    _/  _/        _/              _/    _/_/_/      _/_/_/    "
set "art[4]=        _/_/_/_/  _/  _/    _/  _/_/_/_/  _/        _/              _/    _/    _/  _/           "
set "art[5]=       _/    _/  _/  _/    _/  _/    _/  _/        _/              _/    _/    _/  _/            "
set "art[6]=      _/    _/  _/    _/_/_/  _/    _/  _/_/_/_/  _/_/_/_/      _/_/_/  _/    _/    _/_/_/  _/   "
set "art[7]=                                                                                                 "
set "art[8]=                                                                                                 "

cls

:: 정적 표시
for /L %%i in (0,1,8) do (
    echo(!art[%%i]!
)
timeout /t 2 >nul

:: 스크롤 애니메이션
cls
for /L %%j in (0,1,100) do (
    cls
    for /L %%i in (0,1,8) do (
        if defined art[%%i] (
            set "line=!art[%%i]!"
            set "scrolled=!line:~%%j!"
            if defined scrolled echo(!scrolled!
        ) else (
            echo(
        )
    )
    ping -n 1 -w 50 127.0.0.1 >nul
)

endlocal
goto :EOF