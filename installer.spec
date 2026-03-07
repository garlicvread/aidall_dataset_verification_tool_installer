# -*- mode: python ; coding: utf-8 -*-
"""
PyInstaller spec for AidALL 데이터셋 검증 도구 설치 마법사
Usage: pyinstaller installer.spec
"""

a = Analysis(
    ['installer.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('run_labelme.bat', '.'),
        ('ascii_art.bat', '.'),
        ('download_dataset.bat', '.'),
    ],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        'matplotlib', 'numpy', 'pandas', 'scipy',
        'PIL', 'cv2', 'torch', 'tensorflow',
    ],
    noarchive=False,
)

pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='AidALL_Installer',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    uac_admin=True,
    icon=None,
)
