import os
import base64

def setup_signing():
    keystore_b64 = os.environ.get('KEYSTORE_BASE64', '')
    keystore_pass = os.environ.get('KEYSTORE_PASSWORD', '')
    key_alias = os.environ.get('KEY_ALIAS', 'atomator')

    if not keystore_b64:
        print('WARNING: No KEYSTORE_BASE64 secret - using debug signing')
        return

    print('Keystore secret found (' + str(len(keystore_b64)) + ' chars)')

    keystore_bytes = base64.b64decode(keystore_b64)
    keystore_path = 'android/app/atomator-release.jks'
    with open(keystore_path, 'wb') as f:
        f.write(keystore_bytes)
    print('Keystore written: ' + str(len(keystore_bytes)) + ' bytes')

    with open('android/app/build.gradle.kts', 'r') as f:
        c = f.read()

    # ALWAYS replace signing - remove any existing signingConfig line and add release
    # First add signingConfigs block if not present
    if 'create("release")' not in c:
        signing = """
    signingConfigs {
        create("release") {
            storeFile = file("atomator-release.jks")
            storePassword = \"""" + keystore_pass + """\"
            keyAlias = \"""" + key_alias + """\"
            keyPassword = \"""" + keystore_pass + """\"
        }
    }
"""
        c = c.replace('buildTypes {', signing + '\n    buildTypes {')
        print('Added release signingConfigs block')

    # ALWAYS force release signing in the release buildType
    c = c.replace('signingConfig = signingConfigs.getByName("debug")', 'signingConfig = signingConfigs.getByName("release")')
    print('Set release buildType to use release signing')

    with open('android/app/build.gradle.kts', 'w') as f:
        f.write(c)

    # Verify
    with open('android/app/build.gradle.kts', 'r') as f:
        verify = f.read()

    if 'signingConfigs.getByName("release")' in verify:
        print('VERIFIED: Release signing active')
    elif 'signingConfigs.getByName("debug")' in verify:
        print('ERROR: Still using debug signing!')
    else:
        print('WARNING: No signingConfig line found')

    if 'atomator-release.jks' in verify:
        print('VERIFIED: Keystore referenced in build config')
    else:
        print('ERROR: Keystore NOT referenced!')

if __name__ == '__main__':
    setup_signing()
