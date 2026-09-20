#!/usr/bin/env python3
"""Package committed public source with the staged Windows installer; no secrets."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output-dir', required=True, type=Path)
    args = parser.parse_args()
    output = args.output_dir.resolve()
    if output.is_relative_to(ROOT):
        raise SystemExit('Output must be outside the source repository.')
    if subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT, text=True).strip():
        raise SystemExit('Commit the reviewed changes before packaging.')
    subprocess.run(['python3', 'tools/check_git_privacy_v304.py'], cwd=ROOT, check=True)
    metadata = json.loads((ROOT/'RELEASE_VERSION.json').read_text())
    commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    root = 'Warqnaa-V2-' + metadata['release']
    output.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='warqnaa-package-') as directory:
        stage = Path(directory)
        source = stage/'source.zip'
        subprocess.run(['git', 'archive', '--format=zip', f'--prefix={root}/', '-o', str(source), 'HEAD'], cwd=ROOT, check=True)
        package = {'file':'source.zip', 'root':root, 'sha256':hashlib.sha256(source.read_bytes()).hexdigest(), 'commit':commit, 'release':metadata['full']}
        (stage/'release-package.json').write_text(json.dumps(package, indent=2)+'\n')
        (stage/'Install-Warqnaa.ps1').write_bytes((ROOT/'scripts/windows/current/Install-Warqnaa.ps1').read_bytes())
        (stage/'INSTALL_WARQNAA_AUTO.bat').write_bytes(b'@echo off\r\ncd /d "%~dp0"\r\npowershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-Warqnaa.ps1"\r\nexit /b %errorlevel%\r\n')
        (stage/'README_AR.txt').write_text('Warqnaa '+metadata['full']+'\nاستخرج الحزمة خارج D:\\warq ثم شغّل INSTALL_WARQNAA_AUTO.bat.\nالترقية تحفظ بيانات SQLite المحلية ولا تعيد تهيئة الحسابات.\nالتثبيت الأول يحتاج PHP وPython وبيانات مدير خاصة عبر البيئة؛ لا توجد كلمات مرور في هذه الحزمة.\nتحتاج الحزمة الإنترنت لتنزيل الاعتماديات والبناء. اقرأ دليل الإصدار داخل المصدر.\nCommit: '+commit+'\n', encoding='utf-8-sig')
        archive = output/f"Warqnaa-{metadata['release']}-Full.zip"
        with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED) as bundle:
            for file in sorted(stage.iterdir()):
                bundle.write(file, file.name)
        checksum = hashlib.sha256(archive.read_bytes()).hexdigest()
        (output/'SHA256SUMS.txt').write_text(checksum+'  '+archive.name+'\n')
    print(f'Packaged {metadata["full"]} from {commit}')


if __name__ == '__main__':
    main()
