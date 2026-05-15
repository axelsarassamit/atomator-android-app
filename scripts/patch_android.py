import os
import shutil

print('=== Patching Android config ===')

# Copy our correct AndroidManifest.xml
src_manifest = 'android_manifest/AndroidManifest.xml'
dest_manifest = 'android/app/src/main/AndroidManifest.xml'
if os.path.exists(src_manifest):
    shutil.copy2(src_manifest, dest_manifest)
    print('OK: Copied AndroidManifest.xml')
    # Verify INTERNET permission is in the manifest
    with open(dest_manifest, 'r') as f:
        content = f.read()
    if 'android.permission.INTERNET' in content:
        print('VERIFIED: INTERNET permission present')
    else:
        print('ERROR: INTERNET permission NOT found!')
    if 'usesCleartextTraffic' in content:
        print('VERIFIED: usesCleartextTraffic present')
    else:
        print('ERROR: usesCleartextTraffic NOT found!')
else:
    print('ERROR: android_manifest/AndroidManifest.xml not found!')
    print('Files in current dir:', os.listdir('.'))
    if os.path.exists('android_manifest'):
        print('Files in android_manifest:', os.listdir('android_manifest'))

# Copy network security config
xml_dir = 'android/app/src/main/res/xml'
os.makedirs(xml_dir, exist_ok=True)
src_nsc = 'android_manifest/network_security_config.xml'
if os.path.exists(src_nsc):
    shutil.copy2(src_nsc, os.path.join(xml_dir, 'network_security_config.xml'))
    print('OK: Copied network_security_config.xml')
else:
    print('ERROR: network_security_config.xml not found!')

# Fix NDK
with open('android/app/build.gradle.kts', 'r') as f:
    c = f.read()
c = c.replace('android {', 'android {\n        ndkVersion = "27.0.12077973"', 1)
with open('android/app/build.gradle.kts', 'w') as f:
    f.write(c)
print('OK: Fixed NDK version')

# Google Maven
with open('android/settings.gradle.kts', 'r') as f:
    c = f.read()
c = c.replace('gradlePluginPortal()', 'google()\n                gradlePluginPortal()')
with open('android/settings.gradle.kts', 'w') as f:
    f.write(c)
print('OK: Added Google Maven mirror')

# Copy icon
icon_src = 'assets/images/app_icon.png'
if os.path.exists(icon_src):
    count = 0
    for density in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']:
        dest_dir = f'android/app/src/main/res/mipmap-{density}'
        if os.path.exists(dest_dir):
            shutil.copy2(icon_src, os.path.join(dest_dir, 'ic_launcher.png'))
            count += 1
    print(f'OK: Copied icon to {count} mipmap folders')

print('=== Patch complete ===')
