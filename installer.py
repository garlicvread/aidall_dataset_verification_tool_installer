# -*- coding: utf-8 -*-
"""
AidALL 데이터셋 검증 도구 설치 마법사
Windows GUI 인스톨러 (tkinter)
"""

import os
import stat
import sys
import subprocess
import threading
import shutil
import logging
import time
import urllib.request
from datetime import datetime
from pathlib import Path

import tkinter as tk
from tkinter import ttk, messagebox

# --- 경로 설정 ---
USERPROFILE = os.environ.get("USERPROFILE", os.path.expanduser("~"))
DESKTOP = os.path.join(USERPROFILE, "Desktop")
AIDALL_DIR = os.path.join(DESKTOP, "AidALL")
LOGFILE = os.path.join(AIDALL_DIR, "install_log.txt")
MINICONDA_USER = os.path.join(USERPROFILE, "miniconda3")
MINICONDA_SYSTEM = r"C:\ProgramData\miniconda3"
MINICONDA_URL = "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"
MINICONDA_INSTALLER = os.path.join(USERPROFILE, "miniconda.exe")
GDRIVE_FOLDER_URL = "https://drive.google.com/drive/folders/1OCQee9t9GH2wra_AVjOPX4JKEManxs2q?usp=sharing"

# 번들된 리소스 경로 (PyInstaller 호환)
if getattr(sys, "frozen", False):
    BUNDLE_DIR = sys._MEIPASS
else:
    BUNDLE_DIR = os.path.dirname(os.path.abspath(__file__))


def get_resource(filename):
    """번들된 리소스 파일 경로 반환"""
    return os.path.join(BUNDLE_DIR, filename)


# --- 로깅 설정 ---
def setup_logging():
    os.makedirs(AIDALL_DIR, exist_ok=True)
    logging.basicConfig(
        filename=LOGFILE,
        level=logging.INFO,
        format="[%(asctime)s] %(message)s",
        datefmt="%Y-%m-%d_%H-%M-%S",
        encoding="utf-8",
    )


# --- 설치 단계 ---
class InstallerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("AidALL 데이터셋 검증 도구 설치 마법사")
        self.root.geometry("900x650")
        self.root.resizable(False, False)
        self.root.configure(bg="#1a1a2e")

        self._build_ui()
        self.cancelled = False

    def _build_ui(self):
        # 헤더
        header = tk.Frame(self.root, bg="#16213e", height=100)
        header.pack(fill=tk.X)
        header.pack_propagate(False)

        tk.Label(
            header,
            text="AidALL Inc.",
            font=("Consolas", 28, "bold"),
            fg="#00ff88",
            bg="#16213e",
        ).pack(pady=(15, 0))
        tk.Label(
            header,
            text="데이터셋 검증 도구 설치 마법사",
            font=("맑은 고딕", 15),
            fg="#e0e0e0",
            bg="#16213e",
        ).pack()

        # 진행 상태 바
        progress_frame = tk.Frame(self.root, bg="#1a1a2e")
        progress_frame.pack(fill=tk.X, padx=20, pady=(15, 5))

        self.progress_label = tk.Label(
            progress_frame,
            text="설치 준비 중...",
            font=("맑은 고딕", 13),
            fg="#aaaaaa",
            bg="#1a1a2e",
            anchor="w",
        )
        self.progress_label.pack(fill=tk.X)

        self.progress = ttk.Progressbar(
            progress_frame, length=660, mode="determinate"
        )
        self.progress.pack(fill=tk.X, pady=(5, 0))

        # 로그 출력
        log_frame = tk.Frame(self.root, bg="#1a1a2e")
        log_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=10)

        self.log_text = tk.Text(
            log_frame,
            height=16,
            bg="#0f0f23",
            fg="#00ff88",
            font=("Consolas", 12),
            state=tk.DISABLED,
            wrap=tk.WORD,
            borderwidth=1,
            relief="solid",
        )
        self.log_text.pack(fill=tk.BOTH, expand=True)

        scrollbar = ttk.Scrollbar(self.log_text, command=self.log_text.yview)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        self.log_text.configure(yscrollcommand=scrollbar.set)

        # 버튼 프레임
        btn_frame = tk.Frame(self.root, bg="#1a1a2e")
        btn_frame.pack(fill=tk.X, padx=20, pady=(0, 15))

        self.cancel_btn = tk.Button(
            btn_frame,
            text="취소",
            command=self._cancel,
            font=("맑은 고딕", 13),
            bg="#e74c3c",
            fg="white",
            width=10,
            relief="flat",
        )
        self.cancel_btn.pack(side=tk.RIGHT, padx=(10, 0))

        self.install_btn = tk.Button(
            btn_frame,
            text="설치 시작",
            command=self._start_install,
            font=("맑은 고딕", 13, "bold"),
            bg="#00ff88",
            fg="#1a1a2e",
            width=15,
            relief="flat",
        )
        self.install_btn.pack(side=tk.RIGHT)

    def log(self, message, level="INFO"):
        """GUI 로그 출력 + 파일 로그"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        display = f"[{timestamp}] {message}"

        self.log_text.configure(state=tk.NORMAL)
        self.log_text.insert(tk.END, display + "\n")
        self.log_text.see(tk.END)
        self.log_text.configure(state=tk.DISABLED)

        if level == "ERROR":
            logging.error(message)
        elif level == "WARN":
            logging.warning(message)
        else:
            logging.info(message)

    def set_progress(self, value, label=None):
        self.progress["value"] = value
        if label:
            self.progress_label.configure(text=label)
        self.root.update_idletasks()

    def _cancel(self):
        self.cancelled = True
        self.log("사용자가 설치를 취소했습니다.", "WARN")
        self.install_btn.configure(state=tk.NORMAL, text="설치 시작")
        self.cancel_btn.configure(state=tk.DISABLED)

    def _start_install(self):
        self.install_btn.configure(state=tk.DISABLED)
        self.cancel_btn.configure(state=tk.NORMAL)
        self.cancelled = False
        thread = threading.Thread(target=self._install_sequence, daemon=True)
        thread.start()

    def _run_cmd(self, cmd, description=None, shell=True):
        """명령어 실행 + 로그"""
        if description:
            self.log(description)
        try:
            result = subprocess.run(
                cmd,
                shell=shell,
                capture_output=True,
                text=True,
                timeout=600,
                encoding="utf-8",
                errors="replace",
            )
            if result.stdout.strip():
                for line in result.stdout.strip().split("\n")[-5:]:
                    self.log(f"  {line}")
            if result.returncode != 0 and result.stderr.strip():
                for line in result.stderr.strip().split("\n")[-3:]:
                    self.log(f"  [STDERR] {line}", "WARN")
            return result.returncode == 0
        except subprocess.TimeoutExpired:
            self.log("명령 실행 시간 초과", "ERROR")
            return False
        except Exception as e:
            self.log(f"명령 실행 실패: {e}", "ERROR")
            return False

    def _install_sequence(self):
        """설치 순서"""
        setup_logging()

        steps = [
            (5, "AidALL 디렉토리 생성", self._step_create_dirs),
            (15, "기존 Miniconda 확인", self._step_check_miniconda),
            (30, "Miniconda 다운로드", self._step_download_miniconda),
            (50, "Miniconda 설치", self._step_install_miniconda),
            (65, "Conda 가상환경 생성", self._step_create_env),
            (75, "LabelMe 설치", self._step_install_labelme),
            (85, "데이터셋 다운로드", self._step_download_dataset),
            (95, "바로가기 생성", self._step_create_shortcut),
            (100, "설치 완료", None),
        ]

        for progress_val, label, step_fn in steps:
            if self.cancelled:
                return

            self.root.after(0, self.set_progress, progress_val, label)

            if step_fn:
                try:
                    success = step_fn()
                    if not success and not self.cancelled:
                        self.root.after(
                            0,
                            lambda: messagebox.showerror(
                                "설치 오류",
                                f"'{label}' 단계에서 오류가 발생했습니다.\n"
                                f"로그 파일을 확인해 주세요:\n{LOGFILE}",
                            ),
                        )
                        self.root.after(0, self._reset_buttons)
                        return
                except Exception as e:
                    self.log(f"예기치 않은 오류: {e}", "ERROR")
                    self.root.after(0, self._reset_buttons)
                    return

        # 설치 완료
        self.log("=" * 50)
        self.log("모든 프로세스가 정상적으로 완료되었습니다.")
        self.log(f"바탕화면의 AidALL 폴더에서 LabelMe 바로가기를 실행하실 수 있습니다.")
        self.log("=" * 50)

        self.root.after(
            0,
            lambda: messagebox.showinfo(
                "설치 완료",
                "데이터셋 검증 도구 설치가 완료되었습니다.\n\n"
                "바탕화면의 AidALL 폴더에서\nLabelMe 바로가기를 실행하실 수 있습니다.",
            ),
        )
        self.root.after(0, self._on_complete)

    def _reset_buttons(self):
        self.install_btn.configure(state=tk.NORMAL, text="재시도")
        self.cancel_btn.configure(state=tk.DISABLED)

    def _on_complete(self):
        self.install_btn.configure(state=tk.DISABLED)
        self.cancel_btn.configure(state=tk.DISABLED)

        close_btn = tk.Button(
            self.cancel_btn.master,
            text="닫기",
            command=self.root.destroy,
            font=("맑은 고딕", 13),
            bg="#00ff88",
            fg="#1a1a2e",
            width=10,
            relief="flat",
        )
        close_btn.pack(side=tk.RIGHT, padx=(10, 0))

    # --- 유틸리티 ---

    @staticmethod
    def _remove_readonly(func, path, _excinfo):
        """읽기전용 속성 해제 후 재시도"""
        os.chmod(path, stat.S_IWRITE)
        func(path)

    def _rmtree_retry(self, path, max_retries=5, delay=3):
        """shutil.rmtree를 재시도 + 읽기전용 해제로 실행"""
        for attempt in range(1, max_retries + 1):
            try:
                shutil.rmtree(path, onerror=self._remove_readonly)
                self.log(f"삭제 완료: {path}")
                return True
            except OSError as e:
                if attempt < max_retries:
                    self.log(f"삭제 재시도 {attempt}/{max_retries} (대기 {delay}초)...", "WARN")
                    time.sleep(delay)
                else:
                    self.log(f"디렉토리 삭제 실패 ({max_retries}회 시도): {e}", "ERROR")
                    return False
        return False

    # --- 각 설치 단계 구현 ---

    def _step_create_dirs(self):
        self.log("바탕화면에 AidALL 디렉토리를 생성합니다...")
        try:
            os.makedirs(AIDALL_DIR, exist_ok=True)
            self.log("AidALL 디렉토리 생성 완료")
            return True
        except OSError as e:
            self.log(f"디렉토리 생성 실패: {e}", "ERROR")
            return False

    def _step_check_miniconda(self):
        user_exists = os.path.isdir(MINICONDA_USER)
        system_exists = os.path.isdir(MINICONDA_SYSTEM)

        if not user_exists and not system_exists:
            self.log("기존 Miniconda 설치가 없습니다. 새로 설치합니다.")
            return True

        # 기존 설치 발견 - GUI에서 삭제 동의 요청
        locations = []
        if user_exists:
            locations.append(MINICONDA_USER)
        if system_exists:
            locations.append(MINICONDA_SYSTEM)

        self.log(f"기존 Miniconda 발견: {', '.join(locations)}")

        # 메인 스레드에서 messagebox 호출
        result = [None]

        def ask():
            result[0] = messagebox.askyesno(
                "기존 Miniconda 발견",
                "기존 Miniconda 설치가 발견되었습니다.\n"
                "새로운 Miniconda를 설치하려면 기존 설치를 제거해야 합니다.\n\n"
                "기존 Miniconda를 제거하시겠습니까?",
            )

        self.root.after(0, ask)
        # 응답 대기
        while result[0] is None:
            if self.cancelled:
                return False
            import time
            time.sleep(0.1)

        if not result[0]:
            self.log("사용자가 기존 Miniconda 제거를 거부했습니다.")
            self.cancelled = True
            return False

        self.log("사용자가 기존 Miniconda 제거에 동의했습니다.")

        # 제거 실행
        for path in locations:
            uninstaller = os.path.join(path, "Uninstall-Miniconda3.exe")
            if os.path.isfile(uninstaller):
                self.log(f"Miniconda Uninstaller 실행: {path}")
                success = self._run_cmd(
                    f'start /wait "" "{uninstaller}" /S',
                    description=f"Miniconda Uninstaller로 제거 시도...",
                )
                if not success:
                    self.log("Uninstaller 실행 실패", "ERROR")
                    return False
                import time
                time.sleep(5)

            if os.path.isdir(path):
                self.log(f"Miniconda 디렉토리 삭제: {path}")
                if not self._rmtree_retry(path):
                    return False

        return True

    def _step_download_miniconda(self):
        if os.path.isfile(MINICONDA_INSTALLER):
            self.log("기존 Miniconda 설치 파일 발견, 재사용합니다.")
            return True

        self.log("Miniconda 최신 버전을 다운로드합니다...")
        self.log("(파일 크기 약 100MB, 잠시 기다려 주십시오)")

        try:

            def _report(block_num, block_size, total_size):
                if total_size > 0:
                    pct = min(block_num * block_size / total_size * 100, 100)
                    if int(pct) % 20 == 0:
                        self.log(f"  다운로드 진행: {pct:.0f}%")

            urllib.request.urlretrieve(
                MINICONDA_URL, MINICONDA_INSTALLER, reporthook=_report
            )
            self.log("Miniconda 다운로드 완료")
            return True
        except Exception as e:
            self.log(f"Miniconda 다운로드 실패: {e}", "ERROR")
            self.log("인터넷 연결을 확인해 주십시오.")
            return False

    def _step_install_miniconda(self):
        self.log("Miniconda를 설치합니다... (수 분이 소요될 수 있습니다)")

        success = self._run_cmd(
            f'start /wait "" "{MINICONDA_INSTALLER}" /S',
            description="Miniconda 사일런트 설치 실행 중...",
        )

        # 설치 파일 정리
        if os.path.isfile(MINICONDA_INSTALLER):
            os.remove(MINICONDA_INSTALLER)

        if not success:
            self.log("Miniconda 설치 실패", "ERROR")
            return False

        # conda 존재 확인
        conda_exe = os.path.join(MINICONDA_USER, "Scripts", "conda.exe")
        if not os.path.isfile(conda_exe):
            self.log("Miniconda 설치 확인 실패: conda.exe를 찾을 수 없습니다.", "ERROR")
            return False

        # 버전 확인
        self._run_cmd(f'"{conda_exe}" --version', description="Miniconda 버전 확인:")
        self.log("Miniconda 설치 완료")
        return True

    def _step_create_env(self):
        activate = os.path.join(MINICONDA_USER, "Scripts", "activate.bat")
        cmd = f'call "{activate}" && conda create -n verify_results python=3.12 -y'
        success = self._run_cmd(cmd, description="Conda 가상환경 'verify_results' 생성 중...")

        if not success:
            self.log("Conda 가상환경 생성 실패", "ERROR")
            return False

        self.log("Conda 가상환경 'verify_results' 생성 완료")

        # status 파일 생성
        status_file = os.path.join(AIDALL_DIR, "status.txt")
        with open(status_file, "w", encoding="utf-8") as f:
            f.write("conda_env_setup_complete")

        return True

    def _step_install_labelme(self):
        activate = os.path.join(MINICONDA_USER, "Scripts", "activate.bat")
        cmd = f'call "{activate}" verify_results && pip install labelme'
        success = self._run_cmd(cmd, description="LabelMe 설치 중...")

        if not success:
            self.log("LabelMe 설치 실패", "ERROR")
            return False

        self.log("LabelMe 설치 완료")
        return True

    def _step_download_dataset(self):
        activate = os.path.join(MINICONDA_USER, "Scripts", "activate.bat")

        # gdown 설치
        cmd = f'call "{activate}" verify_results && pip install -U gdown --quiet'
        self._run_cmd(cmd, description="gdown 설치 중...")

        # Google Drive 다운로드 시도
        self.log("Google Drive에서 데이터를 다운로드합니다...")
        self.log("다운로드하는 데이터셋의 크기는 약 60GB 정도입니다.")
        self.log("네트워크 상태에 따라 십수 분이 소요될 수 있습니다.")

        cmd = (
            f'call "{activate}" verify_results && '
            f'cd /d "{AIDALL_DIR}" && '
            f"gdown --folder {GDRIVE_FOLDER_URL}"
        )
        success = self._run_cmd(cmd)

        if not success:
            self.log("Google Drive 자동 다운로드 실패", "WARN")
            self.log("웹 브라우저를 통해 직접 다운로드해 주시기 바랍니다.")

            # 브라우저에서 링크 열기
            try:
                os.startfile(GDRIVE_FOLDER_URL)
            except Exception:
                pass

            # 데이터셋 다운로드 실패는 치명적이지 않음
            self.log("다운로드 완료 후 AidALL 폴더에 압축을 풀어주세요.")

        return True  # 데이터셋 다운로드 실패해도 설치 계속 진행

    def _step_create_shortcut(self):
        # run_labelme.bat, ascii_art.bat 복사
        for filename in ("run_labelme.bat", "ascii_art.bat"):
            src = get_resource(filename)
            dst = os.path.join(AIDALL_DIR, filename)
            if os.path.isfile(src):
                try:
                    shutil.copy2(src, dst)
                    self.log(f"{filename} 복사 완료")
                except OSError as e:
                    self.log(f"{filename} 복사 실패: {e}", "ERROR")
                    return False
            else:
                self.log(f"{filename} 파일을 찾을 수 없습니다: {src}", "WARN")

        # VBScript로 바로가기 생성
        run_labelme_path = os.path.join(AIDALL_DIR, "run_labelme.bat")
        shortcut_path = os.path.join(AIDALL_DIR, "LabelMe.lnk")
        vbs_path = os.path.join(os.environ.get("TEMP", AIDALL_DIR), "CreateShortcut.vbs")

        vbs_content = (
            'Set oWS = WScript.CreateObject("WScript.Shell")\n'
            f'sLinkFile = "{shortcut_path}"\n'
            "Set oLink = oWS.CreateShortcut(sLinkFile)\n"
            f'oLink.TargetPath = "{run_labelme_path}"\n'
            f'oLink.WorkingDirectory = "{AIDALL_DIR}"\n'
            "oLink.Save\n"
        )

        try:
            with open(vbs_path, "w", encoding="utf-8") as f:
                f.write(vbs_content)

            success = self._run_cmd(
                f'cscript //nologo "{vbs_path}"',
                description="LabelMe 바로가기 생성 중...",
            )

            if os.path.isfile(vbs_path):
                os.remove(vbs_path)

            if not success:
                self.log("바로가기 생성 실패", "ERROR")
                return False

            self.log("바로가기 생성 완료")
            return True

        except OSError as e:
            self.log(f"바로가기 생성 중 오류: {e}", "ERROR")
            return False


def main():
    # DPI 스케일링 (Tk 초기화 전에 호출)
    try:
        from ctypes import windll
        windll.shcore.SetProcessDpiAwareness(2)  # Per-Monitor DPI Aware
    except Exception:
        pass

    root = tk.Tk()

    # 윈도우 아이콘 설정 (있을 경우)
    icon_path = get_resource("icon.ico")
    if os.path.isfile(icon_path):
        root.iconbitmap(icon_path)

    app = InstallerApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
