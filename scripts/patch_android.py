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

print('Android config patched successfully')
