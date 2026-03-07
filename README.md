# AidALL 데이터셋 검증 도구 인스톨러

정부 지원 사업 데이터셋 증빙자료 제출을 위한 검증 도구 설치 마법사.
LabelMe 기반으로 데이터셋 라벨링 결과를 검증하고 증빙자료를 준비할 수 있습니다.

## 설치 방법

Windows PowerShell을 **관리자 권한**으로 열고, 아래 명령어를 복사하여 붙여넣으세요:

```powershell
irm https://raw.githubusercontent.com/garlicvread/aidall_dataset_verification_tool_installer/main/install.ps1 | iex
```

### PowerShell 여는 방법 (컴퓨터에 익숙하지 않은 분들을 위한 안내)

1. 키보드에서 **Windows 키**(창문 모양)를 누릅니다
2. `PowerShell` 이라고 입력합니다
3. **"관리자 권한으로 실행"** 을 클릭합니다
4. "이 앱이 변경할 수 있도록 허용하시겠어요?" 라는 팝업이 나오면 **"예"** 를 클릭합니다
5. 파란색 창이 열리면, 위의 명령어를 복사하여 붙여넣고 **Enter** 키를 누릅니다
6. 설치를 시작할지 물어보면, 키보드에서 **Y** 키를 누르고 **Enter** 키를 누릅니다

## 설치되는 항목

| 항목 | 설명 |
|------|------|
| Miniconda | Python 환경 관리자 |
| Conda 가상환경 `verify_results` | Python 3.12 기반 격리 환경 |
| LabelMe | 데이터셋 라벨링 검증 도구 |
| 데이터셋 | Google Drive에서 자동 다운로드 (약 60GB) |
| 바탕화면 바로가기 | `바탕화면/AidALL/LabelMe.lnk` |

## 설치 후 사용 방법

바탕화면의 `AidALL` 폴더에서 `LabelMe` 바로가기를 더블클릭하면 됩니다.

## 프로젝트 구조

```
install.ps1                 # PowerShell 설치 스크립트 (권장)
install_validation_tool.bat # 배치 파일 설치 스크립트 (레거시)
run_labelme.bat             # LabelMe 실행기
ascii_art.bat               # ASCII 아트 표시
download_dataset.bat        # 데이터셋 다운로드
installer.py                # GUI 인스톨러 (코드 서명 시 사용)
```

## 라이선스

[MIT License](LICENSE)
