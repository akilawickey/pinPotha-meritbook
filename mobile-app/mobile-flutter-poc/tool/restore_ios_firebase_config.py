#!/usr/bin/env python3
"""Restore ignored iOS Firebase plist from checked-in iOS options.

For release, compare with the file downloaded from Firebase Console. This helper
reconstructs client configuration, and does not verify live OAuth registration.
"""
import plistlib
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
options = (root / 'lib/firebase_options.dart').read_text().split('static const FirebaseOptions ios =')[1]
def value(name):
    match = re.search(rf"{name}:\s*'([^']+)'", options)
    if not match:
        raise ValueError(f'Missing iOS Firebase option: {name}')
    return match[1]
client = value('iosClientId')
reversed_client = '.'.join(reversed(client.split('.')))
info = plistlib.loads((root / 'ios/Runner/Info.plist').read_bytes())
schemes = [scheme for entry in info.get('CFBundleURLTypes', []) for scheme in entry.get('CFBundleURLSchemes', [])]
if reversed_client not in schemes:
    raise ValueError('iOS URL scheme does not match iosClientId')
output = root / 'ios/Runner/GoogleService-Info.plist'
if output.exists():
    print(f'Preserved existing configuration: {output}')
else:
    output.write_bytes(plistlib.dumps({
        'CLIENT_ID': client, 'REVERSED_CLIENT_ID': reversed_client,
        'API_KEY': value('apiKey'), 'GCM_SENDER_ID': value('messagingSenderId'),
        'PLIST_VERSION': '1', 'BUNDLE_ID': value('iosBundleId'),
        'PROJECT_ID': value('projectId'), 'STORAGE_BUCKET': value('storageBucket'),
        'DATABASE_URL': value('databaseURL'), 'GOOGLE_APP_ID': value('appId'),
        'IS_ADS_ENABLED': False, 'IS_ANALYTICS_ENABLED': True,
        'IS_APPINVITE_ENABLED': True, 'IS_GCM_ENABLED': True, 'IS_SIGNIN_ENABLED': True,
    }))
    print(f'Restored client configuration: {output}')
