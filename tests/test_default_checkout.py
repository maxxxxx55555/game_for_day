"""Exercise real default Git checkouts; source archives do not need a .git folder."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
CONTRACTS = [
    ('manifest-preflight', 'tools/build_manifest.py', '--check'),
    ('critical-manifest', 'tests/test_critical_manifest.py'),
    ('canonical-copy', 'tests/test_copy_contract.py'),
    ('audio-assets', 'tests/test_audio_assets.py'),
    ('license-bytes', 'tests/test_license_bytes.py'),
    ('soundtrack', 'tests/test_soundtrack.py'),
]


def fixture_paths():
    # Use current source bytes, including an uncommitted repair, or a source ZIP.
    # Never copy .git, .godot, user profiles, private keys, or build outputs.
    paths = {'.gitattributes', 'tools/build_manifest.py', 'tools/generate_audio.py',
             'tests/test_default_checkout.py'}
    paths.update(case[1] for case in CONTRACTS)
    for directory, pattern in [('data', '*.json'), ('data/strings', '*.csv'),
                               ('scripts', '*.gd'), ('scenes', '*.tscn'),
                               ('tests/fixtures', '*.json')]:
        paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / directory).rglob(pattern))
    for p in (ROOT / 'assets/audio').iterdir():
        if p.is_file() and p.suffix in {'.wav', '.json', '.md'}:
            paths.add(p.relative_to(ROOT).as_posix())
    licenses = json.loads((ROOT / 'tests/fixtures/inherited-license-hashes.json').read_text(encoding='utf-8'))
    paths.update(licenses['files'])
    return sorted(paths)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--artifacts', type=Path)
    options = parser.parse_args()
    executable = shutil.which('git')
    if not executable:
        raise SystemExit('DEFAULT CHECKOUT FAIL: Git is required for real checkout verification')
    artifacts = options.artifacts.resolve() if options.artifacts else None
    if artifacts:
        artifacts.mkdir(parents=True, exist_ok=True)
    failures, summary = [], {}
    with tempfile.TemporaryDirectory(prefix='heirs-default-checkout-', dir=artifacts.parent if artifacts else ROOT.parent) as temporary:
        base = Path(temporary)
        environment = {key: value for key, value in os.environ.items() if not key.startswith('GIT_')}
        environment.pop('GODOT_SCRIPT_ENCRYPTION_KEY', None)
        owned_temp = base / 'temp'
        owned_temp.mkdir()
        environment.update(GIT_CONFIG_NOSYSTEM='1', GIT_ATTR_NOSYSTEM='1', GIT_CONFIG_GLOBAL=os.devnull,
                           GIT_TERMINAL_PROMPT='0', TEMP=str(owned_temp), TMP=str(owned_temp))
        empty_attributes = base / 'empty.attributes'
        empty_attributes.write_bytes(b'')

        def git(directory, *arguments):
            command = [executable, '-c', 'safe.directory=' + str(directory),
                       '-c', 'core.attributesFile=' + str(empty_attributes), '-C', str(directory), *arguments]
            result = subprocess.run(command, env=environment, capture_output=True, timeout=120)
            if result.returncode:
                raise RuntimeError('Temporary Git operation failed: ' + ' '.join(arguments[:2]) + '\n' +
                                   result.stderr.decode('utf-8', errors='replace'))
            return result.stdout

        seed = base / 'seed'
        seed.mkdir()
        for relative in fixture_paths():
            original = ROOT / relative
            if not original.is_file() or original.is_symlink() or not original.resolve().is_relative_to(ROOT.resolve()):
                raise RuntimeError('Unsafe or missing source contract input: ' + relative)
            target = seed / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(original, target)
        git(seed, 'init', '--quiet')
        git(seed, 'config', 'core.autocrlf', 'true')
        git(seed, 'config', 'user.name', 'Default checkout regression')
        git(seed, 'config', 'user.email', 'checkout-regression@invalid.example')
        # Model Git's canonical commit serialization before varying checkout policy.
        git(seed, 'add', '--all', '--force')
        # Only the disposable seed receives this commit, never the source repo.
        git(seed, 'commit', '--quiet', '-m', 'Isolated current-source contract fixture')
        for setting in ['true', 'false']:
            checkout = base / ('autocrlf-' + setting)
            # The policy is installed before the first real working checkout.
            git(seed, 'worktree', 'add', '--quiet', '--no-checkout', '--detach', checkout.as_posix(), 'HEAD')
            git(checkout, 'config', 'core.autocrlf', setting)
            git(checkout, 'checkout', '--quiet', '--force', '--detach', 'HEAD')
            local_attributes = Path(git(checkout, 'rev-parse', '--git-path', 'info/attributes').decode().strip())
            if not local_attributes.is_absolute():
                local_attributes = checkout / local_attributes
            if local_attributes.exists():
                raise RuntimeError('Default checkout unexpectedly contains local info/attributes')
            reports = {}
            for case in CONTRACTS:
                name, script, *switches = case
                result = subprocess.run([sys.executable, str(checkout / script), *switches],
                                        cwd=checkout, env=environment, capture_output=True, timeout=90)
                output = (result.stdout + result.stderr).decode('utf-8', errors='replace')
                state = 'PASS' if result.returncode == 0 else 'FAIL'
                print('core.autocrlf=' + setting + ' ' + name + ': ' + state, flush=True)
                reports[name] = {'result': state, 'exit': result.returncode}
                if artifacts:
                    (artifacts / (setting + '-' + name + '.log')).write_text(output, encoding='utf-8')
                if result.returncode:
                    failures.append(setting + '/' + name)
                    print(output, flush=True)
            summary[setting] = {'core_autocrlf': setting, 'local_info_attributes': False, 'contracts': reports}
    if artifacts:
        (artifacts / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n', encoding='utf-8')
    if failures:
        print('DEFAULT CHECKOUT FAIL: ' + ', '.join(failures))
        return 1
    print('DEFAULT CHECKOUT PASS: true/false; real manifest/copy/audio/license/soundtrack contracts; no local attributes')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
