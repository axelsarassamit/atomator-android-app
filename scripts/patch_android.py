import os
import shutil

# Fix app name
with open('android/app/src/main/AndroidManifest.xml', 'r') as f:
    c = f.read()
c = c.replace('android:label="atomator_app"', 'android:label="Atomator"')

# Add ALL required permissions
permissions = '''
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
    <uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE"/>
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
'''

# Remove old permissions if any, then add all
if 'android.permission.INTERNET' in c:
    # Already has some permissions, replace the block
    import re
    c = re.sub(r'\s*<uses-permission[^/]*/>', '', c)

# Add permissions before <application
c = c.replace('<application', permissions + '\n    <application')

# Add usesCleartextTraffic for local network SSH
if 'usesCleartextTraffic' not in c:
    c = c.replace('<application', '<application android:usesCleartextTraffic="true"', 1)
    # Remove duplicate android:usesCleartextTraffic if flutter already added one
    c = c.replace('android:usesCleartextTraffic="true" android:usesCleartextTraffic="true"', 'android:usesCleartextTraffic="true"')

# Add networkSecurityConfig for local network access
network_security = '''<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>'''

xml_dir = 'android/app/src/main/res/xml'
os.makedirs(xml_dir, exist_ok=True)
with open(os.path.join(xml_dir, 'network_security_config.xml'), 'w') as f:
    f.write(network_security)

if 'networkSecurityConfig' not in c:
    c = c.replace('<application', '<application android:networkSecurityConfig="@xml/network_security_config"', 1)
    c = c.replace('android:networkSecurityConfig="@xml/network_security_config" android:networkSecurityConfig="@xml/network_security_config"', 'android:networkSecurityConfig="@xml/network_security_config"')

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

# Copy app icon
icon_src = 'assets/images/app_icon.png'
if os.path.exists(icon_src):
    for density in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']:
        dest_dir = f'android/app/src/main/res/mipmap-{density}'
        if os.path.exists(dest_dir):
            shutil.copy2(icon_src, os.path.join(dest_dir, 'ic_launcher.png'))

print('Android config patched: name, ALL permissions, network security, NDK, Maven, icon')
