# AidALL 데이터셋 검증 도구 설치 스크립트
# 사용법: irm https://raw.githubusercontent.com/garlicvread/aidall_dataset_verification_tool_installer/main/install.ps1 | iex

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "AidALL 데이터셋 검증 도구 설치 마법사"

# --- 경로 설정 ---
$AidALLDir = "$env:USERPROFILE\Desktop\AidALL"
$LogFile = "$AidALLDir\install_log.txt"
$MinicondaUser = "$env:USERPROFILE\miniconda3"
$MinicondaSystem = "C:\ProgramData\miniconda3"
$MinicondaURL = "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"
$MinicondaInstaller = "$env:USERPROFILE\miniconda.exe"
$RepoBase = "https://raw.githubusercontent.com/garlicvread/aidall_dataset_verification_tool_installer/main"
$GDriveFolderURL = "https://drive.google.com/drive/folders/1OCQee9t9GH2wra_AVjOPX4JKEManxs2q?usp=sharing"

# --- 유틸리티 함수 ---
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $entry = "[$timestamp] $Message"
    Write-Host $entry -ForegroundColor Green
    if (Test-Path (Split-Path $LogFile)) {
        Add-Content -Path $LogFile -Value $entry -Encoding UTF8
    }
}

function Write-Slow {
    param([string]$Message)
    Write-Log $Message
    Start-Sleep -Milliseconds 300
}

function Show-AsciiArt {
    $lines = @(
        ""
        "        _/_/    _/        _/    _/_/    _/        _/            _/_/_/"
        "     _/    _/        _/_/_/  _/    _/  _/        _/              _/    _/_/_/      _/_/_/"
        "    _/_/_/_/  _/  _/    _/  _/_/_/_/  _/        _/              _/    _/    _/  _/"
        "   _/    _/  _/  _/    _/  _/    _/  _/        _/              _/    _/    _/  _/"
        "  _/    _/  _/    _/_/_/  _/    _/  _/_/_/_/  _/_/_/_/      _/_/_/  _/    _/    _/_/_/  _/"
        ""
    )

    # 정적 표시
    foreach ($line in $lines) {
        Write-Host $line -ForegroundColor Green
    }
    Start-Sleep -Seconds 1

    # 스크롤 애니메이션 (왼쪽으로 밀려나감)
    for ($offset = 0; $offset -le 100; $offset++) {
        Clear-Host
        foreach ($line in $lines) {
            if ($line.Length -gt $offset) {
                Write-Host $line.Substring($offset) -ForegroundColor Green
            } else {
                Write-Host ""
            }
        }
        Start-Sleep -Milliseconds 50
    }
    Clear-Host
}

# --- 메인 설치 ---
Clear-Host
Show-AsciiArt

Write-Host "============================================" -ForegroundColor White
Write-Host "  AidALL Inc. 데이터셋 검증 도구 설치 마법사" -ForegroundColor White
Write-Host "============================================" -ForegroundColor White
Write-Host ""

# AidALL 디렉토리 생성
if (-not (Test-Path $AidALLDir)) {
    New-Item -ItemType Directory -Path $AidALLDir -Force | Out-Null
}
Write-Slow "[INFO] 바탕화면에 AidALL 디렉토리를 생성했습니다."

Write-Host ""
Write-Host "============================================" -ForegroundColor White
Write-Slow "AidALL 디렉토리에는 Labelme 바로가기가 있으며"
Write-Slow "로그 파일도 확인할 수 있습니다."
Write-Slow "또한, 내려받은 데이터셋 파일도 확인할 수 있습니다."
Write-Host "============================================" -ForegroundColor White
Write-Host ""

# 설치 동의
Write-Host ""
Write-Host "설치를 원하시면 키보드에서 Y 키를 누르고 Enter 키를 눌러 주세요." -ForegroundColor Yellow
Write-Host "설치를 원하지 않으시면 N 키를 누르고 Enter 키를 눌러 주세요." -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "설치를 시작하시겠습니까? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Log "[INFO] 사용자가 설치를 취소했습니다."
    exit 0
}

# --- 기존 Miniconda 확인 ---
Write-Slow "[CHECK] 기존 Miniconda 설치 여부를 확인합니다..."

$minicondaPaths = @()
if (Test-Path $MinicondaUser) { $minicondaPaths += $MinicondaUser }
if (Test-Path $MinicondaSystem) { $minicondaPaths += $MinicondaSystem }

if ($minicondaPaths.Count -gt 0) {
    Write-Slow "[WARN] 기존 Miniconda 설치가 발견되었습니다."
    Write-Slow "       새로운 Miniconda를 설치하려면 기존 설치를 제거해야 합니다."
    Write-Host ""
    Write-Host "제거를 원하시면 키보드에서 Y 키를 누르고 Enter 키를 눌러 주세요." -ForegroundColor Yellow
    Write-Host ""
    $remove = Read-Host "기존 Miniconda를 제거하시겠습니까? (Y/N)"
    if ($remove -ne "Y" -and $remove -ne "y") {
        Write-Log "[INFO] 사용자가 기존 Miniconda 제거를 거부했습니다."
        Write-Slow "[INFO] 설치를 중단합니다."
        exit 0
    }
    Write-Log "[INFO] 사용자가 기존 Miniconda 제거에 동의했습니다."

    foreach ($path in $minicondaPaths) {
        Write-Slow "[INFO] 기존 Miniconda 디렉토리를 발견했습니다: $path"

        $uninstaller = Join-Path $path "Uninstall-Miniconda3.exe"
        if (Test-Path $uninstaller) {
            Write-Slow "[INFO] Miniconda Uninstaller로 제거를 시도합니다..."
            $proc = Start-Process -FilePath $uninstaller -ArgumentList "/S" -PassThru
            $elapsed = 0
            while (-not $proc.HasExited) {
                $min = [math]::Floor($elapsed / 60)
                $sec = $elapsed % 60
                Write-Host -NoNewline "`r  제거 중... (${min}분 ${sec}초 경과)  " -ForegroundColor Cyan
                Start-Sleep -Seconds 1
                $elapsed++
            }
            Write-Host ""
            if ($proc.ExitCode -ne 0) {
                Write-Slow "[WARN] Uninstaller 실행 중 문제 발생. 수동 삭제를 시도합니다."
            }
            Start-Sleep -Seconds 3
        }

        if (Test-Path $path) {
            Write-Slow "[INFO] 기존 Miniconda 디렉토리를 삭제합니다..."
            $retries = 5
            for ($i = 1; $i -le $retries; $i++) {
                try {
                    Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
                    Write-Slow "[INFO] 삭제 완료: $path"
                    break
                } catch {
                    if ($i -lt $retries) {
                        Write-Log "[WARN] 삭제 재시도 $i/$retries (대기 3초)..."
                        Start-Sleep -Seconds 3
                    } else {
                        Write-Host "[ERROR] 디렉토리 삭제 실패: $_" -ForegroundColor Red
                        Write-Log "[ERROR] 디렉토리 삭제 실패: $_"
                        exit 1
                    }
                }
            }
        }
    }
    Write-Slow "[INFO] 기존 Miniconda 제거 완료"
}

# --- Miniconda 다운로드 ---
Write-Slow "[INFO] Miniconda 최신 버전을 다운로드합니다..."
Write-Slow "       (파일 크기 약 100MB, 잠시 기다려 주십시오)"

try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $MinicondaURL -OutFile $MinicondaInstaller -UseBasicParsing
    $ProgressPreference = 'Continue'
    Write-Slow "[INFO] Miniconda 다운로드 완료"
} catch {
    Write-Host "[ERROR] Miniconda 다운로드 실패: $_" -ForegroundColor Red
    Write-Slow "인터넷 연결을 확인해 주십시오."
    exit 1
}

# --- Miniconda 설치 ---
Write-Slow "[INFO] Miniconda를 설치합니다..."
Write-Host ""
Write-Host "============================================" -ForegroundColor Yellow
Write-Host "  설치에 5~10분 정도 소요될 수 있습니다." -ForegroundColor Yellow
Write-Host "  화면이 멈춘 것처럼 보여도 정상입니다." -ForegroundColor Yellow
Write-Host "  창을 닫지 마시고 기다려 주세요." -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Yellow
Write-Host ""

$installArgs = "/S /AddToPath=0 /RegisterPython=0 /D=$MinicondaUser"
$proc = Start-Process -FilePath $MinicondaInstaller -ArgumentList $installArgs -PassThru

# 설치 진행률 애니메이션
$spinner = @("▓░░░░░░░░░", "▓▓░░░░░░░░", "▓▓▓░░░░░░░", "▓▓▓▓░░░░░░", "▓▓▓▓▓░░░░░", "▓▓▓▓▓▓░░░░", "▓▓▓▓▓▓▓░░░", "▓▓▓▓▓▓▓▓░░", "▓▓▓▓▓▓▓▓▓░", "▓▓▓▓▓▓▓▓▓▓")
$i = 0
$elapsed = 0
while (-not $proc.HasExited) {
    $bar = $spinner[$i % $spinner.Count]
    $min = [math]::Floor($elapsed / 60)
    $sec = $elapsed % 60
    Write-Host -NoNewline "`r  설치 중... [$bar] (${min}분 ${sec}초 경과)  " -ForegroundColor Cyan
    Start-Sleep -Seconds 1
    $elapsed++
    $i++
}
Write-Host ""

if ($proc.ExitCode -ne 0) {
    Write-Host "[ERROR] Miniconda 설치 실패 (exit code: $($proc.ExitCode))" -ForegroundColor Red
    exit 1
}

# 설치 파일 정리
if (Test-Path $MinicondaInstaller) {
    Remove-Item $MinicondaInstaller -Force
}

# conda 확인
$condaExe = "$MinicondaUser\Scripts\conda.exe"
$waited = 0
while (-not (Test-Path $condaExe) -and $waited -lt 30) {
    Write-Log "[INFO] conda.exe 대기 중... ($($waited+3)초)"
    Start-Sleep -Seconds 3
    $waited += 3
}

if (-not (Test-Path $condaExe)) {
    Write-Host "[ERROR] Miniconda 설치 확인 실패: conda.exe를 찾을 수 없습니다." -ForegroundColor Red
    Write-Log "[ERROR] 확인 경로: $condaExe"
    exit 1
}

Write-Slow "[INFO] Miniconda 설치 완료"
& $condaExe --version
Write-Host ""

# --- Conda 가상환경 생성 ---
Write-Slow "[INFO] Conda 가상환경을 생성합니다..."

$activate = "$MinicondaUser\Scripts\activate.bat"
& cmd /c "call `"$activate`" && conda create -n verify_results python=3.12 -y"
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Conda 가상환경 생성 실패" -ForegroundColor Red
    exit 1
}

Write-Slow "[INFO] Conda 가상환경 'verify_results' 생성 완료"
"conda_env_setup_complete" | Out-File -FilePath "$AidALLDir\status.txt" -Encoding UTF8
Write-Host ""

# --- LabelMe 설치 ---
Write-Slow "[INFO] Labelme를 설치합니다..."

& cmd /c "call `"$activate`" verify_results && pip install labelme"
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Labelme 설치 실패" -ForegroundColor Red
    exit 1
}
Write-Slow "[INFO] Labelme 설치 완료"
Write-Host ""

# --- 데이터셋 다운로드 ---
Write-Slow "[INFO] 데이터셋 다운로드를 시작합니다..."
Write-Slow "       데이터셋 크기는 약 60GB 정도입니다."

& cmd /c "call `"$activate`" verify_results && pip install -U gdown --quiet && cd /d `"$AidALLDir`" && gdown --folder $GDriveFolderURL"
if ($LASTEXITCODE -ne 0) {
    Write-Log "[WARN] Google Drive 자동 다운로드 실패"
    Write-Slow "[INFO] 웹 브라우저를 통해 직접 다운로드해 주시기 바랍니다."
    Write-Slow "       다운로드 완료 후 AidALL 폴더에 압축을 풀어주세요."
    Start-Process $GDriveFolderURL
}
Write-Host ""

# --- 바로가기 생성 ---
Write-Slow "[INFO] 바로가기를 생성합니다..."

# run_labelme.bat, ascii_art.bat 다운로드
foreach ($file in @("run_labelme.bat", "ascii_art.bat")) {
    $url = "$RepoBase/$file"
    $dest = "$AidALLDir\$file"
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        Write-Log "[INFO] $file 다운로드 완료"
    } catch {
        Write-Host "[WARN] $file 다운로드 실패: $_" -ForegroundColor Yellow
    }
}

# LabelMe 바로가기 생성
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$AidALLDir\LabelMe.lnk")
$Shortcut.TargetPath = "$AidALLDir\run_labelme.bat"
$Shortcut.WorkingDirectory = $AidALLDir
$Shortcut.Save()
Write-Slow "[INFO] 바로가기 생성 완료"

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Slow "[INFO] 데이터 세트 검증 도구 설치가 완료되었습니다."
Write-Slow "바탕화면의 AidALL 폴더에서 LabelMe 바로가기를 실행하실 수 있습니다."
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Slow "[INFO] 모든 프로세스가 정상적으로 완료되었습니다."
Write-Host ""
Write-Host "명령 프롬프트를 닫으시려면 아무 키나 눌러 주십시오." -ForegroundColor White
Write-Host "Press any key to close..." -ForegroundColor White
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
