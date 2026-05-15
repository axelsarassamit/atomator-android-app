import sys
import os
import shutil

# Fix app name
with open('android/app/src/main/AndroidManifest.xml', 'r') as f:
    c = f.read()
c = c.replace('android:label="atomator_app"', 'android:label="Atomator"')
with open('android/app/src/main/AndroidManifest.xml', 'w') as f:
    f.write(c)

# Fix NDK
with open('android/app/build.gradle.kts', 'r') as f:
    c = f.read()
c = c.replace('android {', 'android {\n        ndkVersion = "27.0.12077973"', 1)
with open('android/app/build.gradle.kts', 'w') as f:
    f.write(c)

# Add Google Maven mirror
with open('android/settings.gradle.kts', 'r') as f:
    c = f.read()
c = c.replace('gradlePluginPortal()', 'google()\n                gradlePluginPortal()')
with open('android/settings.gradle.kts', 'w') as f:
    f.write(c)

# Manually copy app icon to all mipmap folders as fallback
icon_src = 'assets/images/app_icon.png'
if os.path.exists(icon_src):
    for density in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']:
        dest_dir = f'android/app/src/main/res/mipmap-{density}'
        if os.path.exists(dest_dir):
            shutil.copy2(icon_src, os.path.join(dest_dir, 'ic_launcher.png'))
            print(f'Copied icon to {dest_dir}')

print('Android config patched successfully')
