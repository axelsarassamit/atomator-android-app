import os
import base64

def setup_signing():
    keystore_b64 = os.environ.get('KEYSTORE_BASE64', '')
    keystore_pass = os.environ.get('KEYSTORE_PASSWORD', '')
    key_alias = os.environ.get('KEY_ALIAS', 'atomator')

    if not keystore_b64:
        print('WARNING: No KEYSTORE_BASE64 secret found - using debug signing')
        print('To enable persistent signing, add KEYSTORE_BASE64 to GitHub Secrets')
        return

    print('Keystore secret found (' + str(len(keystore_b64)) + ' chars)')

    # Decode keystore
    keystore_bytes = base64.b64decode(keystore_b64)
    keystore_path = 'android/app/atomator-release.jks'
    with open(keystore_path, 'wb') as f:
        f.write(keystore_bytes)
    print('Keystore written: ' + keystore_path + ' (' + str(len(keystore_bytes)) + ' bytes)')

    # Patch build.gradle.kts with signing config
    with open('android/app/build.gradle.kts', 'r') as f:
        c = f.read()

    if 'signingConfigs' not in c:
        signing = '''
    signingConfigs {
        create("release") {
            storeFile = file("atomator-release.jks")
            storePassword = "''' + keystore_pass + '''"
            keyAlias = "''' + key_alias + '''"
            keyPassword = "''' + keystore_pass + '''"
        }
    }
'''
        c = c.replace('buildTypes {', signing + '\n    buildTypes {')
        c = c.replace('signingConfig = signingConfigs.getByName("debug")', 'signingConfig = signingConfigs.getByName("release")')
        with open('android/app/build.gradle.kts', 'w') as f:
            f.write(c)
        print('OK: Release signing config added')

        # Verify
        with open('android/app/build.gradle.kts', 'r') as f:
            verify = f.read()
        if 'signingConfigs' in verify and 'release' in verify:
            print('VERIFIED: Signing config present in build.gradle.kts')
        else:
            print('ERROR: Signing config NOT found after patching!')
    else:
        print('Signing config already present')

if __name__ == '__main__':
    setup_signing()
