import base64
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('ci_android', Path(__file__).resolve().parents[1] / 'ci_android.py')
ci = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ci)


class FakePlay:
    def __init__(self, tracks=None, bundles=None, apks=None, failure=None):
        self.calls, self.failure = [], failure
        self.results = {
            '/edit-1/tracks': {'tracks': tracks if tracks is not None else [{'track': 'alpha', 'releases': [{'versionCodes': ['17']}]}]},
            '/edit-1/bundles': {'bundles': bundles or []}, '/edit-1/apks': {'apks': apks or []},
        }

    def request(self, method, suffix='', body=None):
        self.calls.append((method, suffix))
        if method == 'POST': return {'id': 'edit-1'}
        if method == 'DELETE': return {}
        if suffix == self.failure: raise RuntimeError('API denied')
        return self.results[suffix]


class VersionTests(unittest.TestCase):
    def test_all_tracks_and_unreleased_artifacts_determine_next_version(self):
        play = FakePlay(tracks=[{'track': 'alpha'}, {'track': 'production', 'releases': [{'versionCodes': ['50']}]}],
                        bundles=[{'versionCode': 70}], apks=[{'versionCode': 65}])
        self.assertEqual(ci.next_version(play, 'alpha', 1), 71)
        self.assertEqual(play.calls[-1], ('DELETE', '/edit-1'))
        self.assertFalse(any(method in ('PUT', 'PATCH') or 'commit' in suffix for method, suffix in play.calls))

    def test_rerun_uses_new_version_after_previous_upload(self):
        self.assertEqual(ci.next_version(FakePlay(bundles=[{'versionCode': 71}]), 'alpha', 1), 72)

    def test_explicit_floor_handles_codes_reserved_by_another_publisher(self):
        self.assertEqual(ci.next_version(FakePlay(), 'alpha', 500), 501)

    def test_missing_track_and_api_failure_cleanup_inspection_edit(self):
        for play in (FakePlay(tracks=[{'track': 'production'}]), FakePlay(failure='/edit-1/bundles')):
            with self.subTest(play=play), self.assertRaises((ValueError, RuntimeError)):
                ci.next_version(play, 'alpha', 1)
            self.assertEqual(play.calls[-1], ('DELETE', '/edit-1'))

    def test_maximum_version_code_is_not_overflowed(self):
        with self.assertRaisesRegex(ValueError, 'maximum'):
            ci.next_version(FakePlay(bundles=[{'versionCode': ci.MAX_VERSION_CODE}]), 'alpha', 0)

    def test_non_closed_and_multiple_tracks_rejected_before_api_access(self):
        for track in ('production', 'beta', 'internal', 'internalsharing', 'wear:production', 'alpha,production', 'alpha\nproduction', ''):
            play = FakePlay()
            with self.subTest(track=track), self.assertRaises(ValueError): ci.next_version(play, track, 1)
            self.assertEqual(play.calls, [])

    def test_custom_closed_track_must_exist(self):
        self.assertEqual(ci.next_version(FakePlay(tracks=[{'track': 'friends-and-family'}]), 'friends-and-family', 10), 11)


class SigningTests(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name)
        (self.root / 'app/android').mkdir(parents=True)
        (self.root / 'runner').mkdir()
        (self.root / 'app/pubspec.yaml').write_text('name: pinpotha\nversion: 5.7.0+17\n')
        self.env = {
            'ANDROID_KEYSTORE_BASE64': base64.b64encode(b'fixture-keystore').decode(),
            'ANDROID_KEYSTORE_PASSWORD': 'store=pass:\\word', 'ANDROID_KEY_ALIAS': 'upload',
            'ANDROID_KEY_PASSWORD': ' key\nපින්😀',
            'GOOGLE_PLAY_SERVICE_ACCOUNT_JSON': json.dumps({'type': 'service_account', 'client_email': 'fixture@example.test',
                'private_key': 'fixture-private-key', 'token_uri': 'https://oauth2.googleapis.com/token'}),
            'RUNNER_TEMP': str(self.root / 'runner'), 'GITHUB_OUTPUT': str(self.root / 'output'), 'GOOGLE_PLAY_CLOSED_TRACK': 'alpha',
        }

    def test_signing_material_is_private_escaped_and_not_in_outputs(self):
        ci.prepare(self.env, self.root / 'app')
        key, props = self.root / 'runner/pinpotha-upload.jks', self.root / 'app/android/key.properties'
        self.assertEqual(key.read_bytes(), b'fixture-keystore')
        self.assertEqual(key.stat().st_mode & 0o777, 0o600)
        self.assertEqual(props.stat().st_mode & 0o777, 0o600)
        self.assertIn(r'\ud83d\ude00', props.read_text())
        self.assertIn(r'\n', props.read_text())
        self.assertEqual((self.root / 'output').read_text(), 'track=alpha\nversion_name=5.7.0\nversion_floor=17\n')
        ci.cleanup(self.env, self.root / 'app')
        self.assertFalse(key.exists()); self.assertFalse(props.exists())

    def test_missing_secret_error_names_only_missing_key(self):
        del self.env['ANDROID_KEY_PASSWORD']
        with self.assertRaisesRegex(ValueError, 'Missing GitHub Actions secrets: ANDROID_KEY_PASSWORD'):
            ci.prepare(self.env, self.root / 'app')
        self.assertFalse((self.root / 'runner/pinpotha-upload.jks').exists())

    def test_bad_base64_or_service_account_fail_before_file_creation(self):
        for field, value in [('ANDROID_KEYSTORE_BASE64', 'invalid!'), ('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON', '{}'),
                             ('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON', 'not-json')]:
            with self.subTest(field=field, value=value), self.assertRaises(ValueError):
                ci.prepare(dict(self.env, **{field: value}), self.root / 'app')
        self.assertFalse((self.root / 'runner/pinpotha-upload.jks').exists())

    def test_untrusted_values_cannot_inject_workflow_outputs(self):
        for field, value in [('ANDROID_VERSION_NAME', '5.7\ntrack=production'), ('GOOGLE_PLAY_CLOSED_TRACK', 'alpha\nversion_name=bad'),
                             ('ANDROID_VERSION_CODE_FLOOR', '-1')]:
            with self.subTest(field=field), self.assertRaises(ValueError): ci.prepare(dict(self.env, **{field: value}), self.root / 'app')

    def test_existing_signing_material_is_not_overwritten(self):
        props = self.root / 'app/android/key.properties'
        props.write_text('existing')
        with self.assertRaisesRegex(ValueError, 'Refusing to overwrite'): ci.prepare(self.env, self.root / 'app')
        self.assertEqual(props.read_text(), 'existing')

    def test_credentials_cannot_redirect_token_request(self):
        account = json.loads(self.env['GOOGLE_PLAY_SERVICE_ACCOUNT_JSON'])
        account['token_uri'] = 'https://example.test/capture'
        with self.assertRaisesRegex(ValueError, 'token endpoint'):
            ci.prepare(dict(self.env, GOOGLE_PLAY_SERVICE_ACCOUNT_JSON=json.dumps(account)), self.root / 'app')


if __name__ == '__main__': unittest.main()
