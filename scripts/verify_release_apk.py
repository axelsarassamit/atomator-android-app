"""Fail before publication if release identity, version, or artwork is wrong."""
import hashlib
import os
from pathlib import Path
import re
import subprocess
import sys
import zipfile

# Verified against the published v1.7.2 APK, build 65.
CERTIFICATE = '4d446a9fa1266c1156701a8783ab35941f98f8fed531c4878f494e10812e15b2'
PACKAGE = 'com.example.atomator_app'


def verify(apk):
    sdk = Path(os.environ.get('ANDROID_HOME') or os.environ['ANDROID_SDK_ROOT'])
    versions = sorted((sdk / 'build-tools').iterdir(),
                      key=lambda p: tuple(int(v) for v in p.name.split('.') if v.isdigit()))
    tools = versions[-1]
    suffix = '.bat' if os.name == 'nt' else ''
    signatures = subprocess.check_output(
        [str(tools / ('apksigner' + suffix)), 'verify', '--print-certs', str(apk)], text=True)
    certificates = re.findall(
        r'(?:Signer #\d+|V\d+ Signer):? certificate SHA-256 digest:\s*([0-9a-fA-F]{64})',
        signatures)
    if {certificate.lower() for certificate in certificates} != {CERTIFICATE}:
        print('\n'.join(line for line in signatures.splitlines() if 'certificate' in line), flush=True)
        print(f'Expected certificate SHA-256: {CERTIFICATE}', flush=True)
        raise RuntimeError('Signing certificate differs from the published app')
    aapt = tools / ('aapt.exe' if os.name == 'nt' else 'aapt')
    manifest = subprocess.check_output([str(aapt), 'dump', 'badging', str(apk)], text=True)
    version = re.search(r'^version: ([^+\s]+)\+(\d+)', Path('pubspec.yaml').read_text(), re.M)
    expected = f"package: name='{PACKAGE}' versionCode='{version[2]}' versionName='{version[1]}'"
    if not manifest.startswith(expected):
        raise RuntimeError('APK package/version differs from the source release')
    if int(version[2]) <= 65:
        raise RuntimeError('Version code must be newer than published build 65')
    tag = os.environ.get('GITHUB_REF', '')
    if tag.startswith('refs/tags/') and tag != f'refs/tags/v{version[1]}':
        raise RuntimeError('Release tag and app version differ')
    with zipfile.ZipFile(apk) as archive:
        embedded = archive.read('assets/flutter_assets/assets/images/app_icon.png')
    source = Path('assets/images/app_icon.png').read_bytes()
    if hashlib.sha256(embedded).digest() != hashlib.sha256(source).digest():
        raise RuntimeError('Approved logo is missing from the APK')
    print(f'Verified release {version[1]} ({version[2]}): signing, package, version and approved logo')


if __name__ == '__main__':
    verify(Path(sys.argv[1]))
