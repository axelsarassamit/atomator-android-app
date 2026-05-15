import os
import shutil

print('Patching Android config...')

# Copy our correct AndroidManifest.xml over the generated one
src_manifest = 'android_manifest/AndroidManifest.xml'
dest_manifest = 'android/app/src/main/AndroidManifest.xml'
if os.path.exists(src_manifest):
    shutil.copy2(src_manifest, dest_manifest)
    print('Copied AndroidManifest.xml with all permissions')
else:
    print('WARNING: android_manifest/AndroidManifest.xml not found!')

# Copy network security config
xml_dir = 'android/app/src/main/res/xml'
os.makedirs(xml_dir, exist_ok=True)
src_nsc = 'android_manifest/network_security_config.xml'
if os.path.exists(src_nsc):
    shutil.copy2(src_nsc, os.path.join(xml_dir, 'network_security_config.xml'))
    print('Copied network_security_config.xml')

# Fix NDK
with open('android/app/build.gradle.kts', 'r') as f:
    c = f.read()
c = c.replace('android {', 'android {\n        ndkVersion = "27.0.12077973"', 1)
with open('android/app/build.gradle.kts', 'w') as f:
    f.write(c)
print('Fixed NDK version')

# Add Google Maven mirror
with open('android/settings.gradle.kts', 'r') as f:
    c = f.read()
c = c.replace('gradlePluginPortal()', 'google()\n                gradlePluginPortal()')
with open('android/settings.gradle.kts', 'w') as f:
    f.write(c)
print('Added Google Maven mirror')

# Copy app icon
icon_src = 'assets/images/app_icon.png'
if os.path.exists(icon_src):
    for density in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']:
        dest_dir = f'android/app/src/main/res/mipmap-{density}'
        if os.path.exists(dest_dir):
            shutil.copy2(icon_src, os.path.join(dest_dir, 'ic_launcher.png'))
    print('Copied app icon to mipmap folders')

print('Done!')
