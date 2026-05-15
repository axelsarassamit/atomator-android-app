import os
import sys

def setup_signing():
    keystore_b64 = os.environ.get('KEYSTORE_BASE64', '')
    keystore_pass = os.environ.get('KEYSTORE_PASSWORD', '')
    key_alias = os.environ.get('KEY_ALIAS', 'atomator')

    if not keystore_b64:
        print('No keystore secret - using debug signing')
        return

    # Decode keystore
    import base64
    keystore_bytes = base64.b64decode(keystore_b64)
    keystore_path = 'android/app/atomator-release.jks'
    with open(keystore_path, 'wb') as f:
        f.write(keystore_bytes)
    print('Keystore written to ' + keystore_path)

    # Write key.properties
    with open('android/key.properties', 'w') as f:
        f.write('storePassword=' + keystore_pass + '\n')
        f.write('keyPassword=' + keystore_pass + '\n')
        f.write('keyAlias=' + key_alias + '\n')
        f.write('storeFile=atomator-release.jks\n')
    print('key.properties written')

    # Patch build.gradle.kts
    with open('android/app/build.gradle.kts', 'r') as f:
        c = f.read()

    if 'signingConfigs' not in c:
        signing = """
    signingConfigs {
        create("release") {
            storeFile = file("atomator-release.jks")
            storePassword = """" + keystore_pass + """"
            keyAlias = """" + key_alias + """"
            keyPassword = """" + keystore_pass + """"
        }
    }
"""
        c = c.replace('buildTypes {', signing + '\n    buildTypes {')
        c = c.replace('signingConfig = signingConfigs.getByName("debug")', 'signingConfig = signingConfigs.getByName("release")')
        with open('android/app/build.gradle.kts', 'w') as f:
            f.write(c)
        print('Signing config added to build.gradle.kts')
    else:
        print('Signing config already present')

if __name__ == '__main__':
    setup_signing()
