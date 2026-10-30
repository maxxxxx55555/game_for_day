"""Run the real Godot project in an isolated save profile and reject engine errors."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import sys


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', default=os.environ.get('GODOT_BIN') or shutil.which('godot') or shutil.which('godot4'))
    parser.add_argument('--language', choices=['ru','en'], default='ru', help='QA display locale')
    parser.add_argument('--audio-driver', help='Optional silent QA backend, for example Dummy')
    parser.add_argument('--rendered', action='store_true', help='Run the playthrough with a real graphics device')
    parser.add_argument('--artifacts', type=Path, help='Directory for logs and rendered screenshots')
    args = parser.parse_args()
    if not args.godot:
        parser.error('Set GODOT_BIN or pass --godot with the Godot 4.7 executable path')
    project = Path(__file__).resolve().parents[1]
    with tempfile.TemporaryDirectory(prefix='godot-gameplay-') as temporary:
        profile = Path(temporary)
        artifacts = (args.artifacts or profile / 'artifacts').resolve()
        artifacts.mkdir(parents=True, exist_ok=True)
        environment = os.environ.copy()
        environment['GAME_AUDIO_MUTED'] = '1'
        environment['GAME_LANGUAGE'] = args.language
        # The negative QA fixture must prove that env alone cannot unlock the verifier.
        environment['GAME_QA'] = '1'
        for variable, folder in [('APPDATA', 'roaming'), ('LOCALAPPDATA', 'local'), ('XDG_DATA_HOME', 'data'), ('XDG_CONFIG_HOME', 'config'), ('XDG_CACHE_HOME', 'cache')]:
            path = profile / folder
            path.mkdir()
            environment[variable] = str(path)
        environment['GAME_SCREENSHOT'] = str(artifacts / (project.name + '.png'))
        portrait = 'GameManager' in (project / 'project.godot').read_text(encoding='utf-8')
        cases = [
            ('import', ['--headless', '--editor', '--import', '--quit']),
            ('regressions', ['--headless', '--script', 'res://tests/test_gameplay.gd']),
            ('playthrough', ([] if args.rendered else ['--headless']) + ['--resolution', '540x960' if portrait else '1280x720', '--script', 'res://tests/test_gameplay.gd', '--', '--playthrough']),
        ]
        cases.append(('credits', ['--headless', '--script', 'res://tests/test_credits.gd']))
        cases.append(('release-details', ['--headless', '--script', 'res://tests/test_release_details.gd']))
        cases.append(('disabled-explanations', ['--headless', '--script', 'res://tests/test_disabled_explanations.gd']))
        cases.append(('comfort-preferences', ['--headless', '--script', 'res://tests/test_comfort_preferences.gd']))
        cases.append(('canonical-model', ['--headless', '--script', 'res://tests/test_canonical_model.gd']))
        cases.append(('birth-save-contract', ['--headless', '--script', 'res://tests/test_birth_save_contract.gd']))
        cases.append(('birth-locale', ['--headless', '--script', 'res://tests/test_birth_locale.gd']))
        cases.append(('currency-chart', ['--headless', '--script', 'res://tests/test_currency_chart.gd']))
        if args.rendered: cases.append(('chart-path-regression', ['--resolution','540x960','--script','res://tests/test_chart_path_regression.gd']))
        cases.append(('financial-motion', ['--headless', '--script', 'res://tests/test_financial_motion.gd']))
        cases.append(('localization', ['--headless', '--script', 'res://tests/test_localization.gd']))
        cases.append(('translation-coverage', ['--headless', '--script', 'res://tests/test_translation_coverage.gd']))
        cases.append(('audio-scope', ['--headless', '--script', 'res://tests/test_audio_scope.gd']))
        cases.append(('qa-audio-lifetime', ['--headless', '--fixed-fps', '30', '--script', 'res://tests/test_qa_audio_lifetime.gd']))
        cases.append(('audio-shutdown', ['--headless', '--fixed-fps', '30', '--script', 'res://tests/test_audio_shutdown.gd']))
        cases.append(('quit-save', ['--headless', '--script', 'res://tests/test_quit_audio.gd']))
        for close_kind in ['wm','boot','retry','discard']:
            cases.append(('quit-'+close_kind, ['--headless', '--script', 'res://tests/test_quit_audio.gd', '--', '--'+close_kind]))
        cases.append(('presentation', ([] if args.rendered else ['--headless']) + ['--resolution', '540x960' if portrait else '1280x720', '--script', 'res://tests/test_presentation.gd']))
        cases.append(('identity', ['--headless', '--script', 'res://tests/test_identity.gd']))
        cases.append(('mobile-lifecycle', ['--headless', '--script', 'res://tests/test_mobile_lifecycle.gd']))
        cases.append(('market-exit', ['--headless', '--script', 'res://tests/test_market_exit.gd']))
        cases.append(('currencies', ['--headless', '--script', 'res://tests/test_currencies.gd']))
        cases.append(('currency-ui', ['--headless', '--script', 'res://tests/test_currency_ui.gd']))
        cases.append(('integrity', ['--headless', '--script', 'res://tests/test_integrity.gd']))
        cases.append(('protected-saves', ['--headless', '--script', 'res://tests/test_protected_saves.gd']))
        cases.append(('finales', ([] if args.rendered else ['--headless']) + ['--script', 'res://tests/test_finales.gd']))
        cases.append(('choice-sweep', ([] if args.rendered else ['--headless']) + ['--resolution', '360x800', '--script', 'res://tests/test_choice_sweep.gd']))
        cases.append(('clear-play', ([] if args.rendered else ['--headless']) + ['--resolution', '540x960' if portrait else '1280x720', '--script', 'res://tests/test_clear_play.gd']))
        cases.append(('premium-ui', ([] if args.rendered else ['--headless']) + ['--resolution', '540x960' if portrait else '1280x720', '--script', 'res://tests/test_premium_ui.gd']))
        cases.append(('release-hardening', ['--headless', '--script', 'res://tests/test_release_hardening.gd']))
        cases.append(('music-transitions', ['--headless', '--script', 'res://tests/test_music_transitions.gd']))
        for case in ['ui_audio_feedback','context_audio']:
            cases.append((case, ['--headless', '--script', 'res://tests/test_' + case + '.gd']))
        for case in ['qa_router','build_integrity','critical_read_bounds','integrity_notice','save_recovery','cent_ledger']:
            cases.append((case, ['--headless','--script','res://tests/test_'+case+'.gd']))
        cases.append(('settings-lifetime', ['--headless','--script','res://tests/test_settings_lifetime.gd']))
        cases.append(('choice-reentry', ['--headless','--script','res://tests/test_choice_reentry.gd']))
        cases.append(('navigation-matrix', ([] if args.rendered else ['--headless'])+['--resolution', '1280x720' if not portrait else '540x960','--script','res://tests/test_navigation_matrix.gd']))
        cases.append(('qa-seed', ['--headless','--script','res://tests/test_qa_seed.gd']))
        cases.append(('mechanics-inputs', ['--headless','--script','res://tests/test_mechanics_inputs.gd']))
        cases.append(('exact-float-limits', ['--headless','--script','res://tests/test_exact_float_limits.gd']))
        cases.append(('config-float-precision', ['--headless','--script','res://tests/test_config_float_precision.gd']))
        cases.append(('profile-contract', ['--headless','--script','res://tests/test_profile_contract.gd']))
        cases.append(('chains', ['--headless','--script','res://tests/test_chains.gd']))
        cases.append(('dynasty-progression', ['--headless','--script','res://tests/test_dynasty_progression.gd']))
        cases.append(('card-feel', ['--headless','--script','res://tests/test_card_feel.gd']))
        cases.insert(2, ('audio', ['--headless', '--script', 'res://tests/test_audio.gd']))
        if portrait:
            cases.append(('balance', ['--headless', '--script', 'res://tests/test_gameplay.gd', '--', '--balance']))
        else:
            for script in ['strategy', 'campaign']:
                if (project / ('tests/test_' + script + '.gd')).exists():
                    cases.append((script, ([] if args.rendered else ['--headless']) + ['--resolution', '1280x720', '--script', 'res://tests/test_' + script + '.gd']))
        inherited_licenses = subprocess.run([sys.executable, str(project / 'tests/test_license_bytes.py')], timeout=30)
        if inherited_licenses.returncode: return inherited_licenses.returncode
        contract = subprocess.run([sys.executable, str(project / 'tests/test_export_contract.py')], timeout=30)
        if contract.returncode: return contract.returncode
        copy_contract = subprocess.run([sys.executable, str(project / 'tests/test_copy_contract.py')], timeout=30)
        if copy_contract.returncode: return copy_contract.returncode
        generation = subprocess.run([sys.executable, str(project / 'tests/test_localization_generation.py')], timeout=30)
        if generation.returncode: return generation.returncode
        promises = subprocess.run([sys.executable, str(project / 'tests/test_promise_matrix.py')], timeout=30)
        if promises.returncode: return promises.returncode
        mechanics = subprocess.run([sys.executable, str(project / 'tests/test_mechanics_matrix.py')], timeout=30)
        if mechanics.returncode: return mechanics.returncode
        isolation = subprocess.run([sys.executable, str(project / 'tests/test_repo_isolation.py')], timeout=30)
        if isolation.returncode: return isolation.returncode
        soundtrack = subprocess.run([sys.executable, str(project / 'tests/test_soundtrack.py')], timeout=60)
        if soundtrack.returncode: return soundtrack.returncode
        assets = subprocess.run([sys.executable, str(project / 'tests/test_audio_assets.py')], timeout=60)
        if assets.returncode:
            return assets.returncode
        for source_contract in ['test_public_qa_contract.py','test_release_export_tool.py','test_critical_manifest.py','test_default_checkout.py']:
            result=subprocess.run([sys.executable,str(project/'tests'/source_contract)],timeout=180 if source_contract=='test_default_checkout.py' else 60)
            if result.returncode:return result.returncode
        for name, switches in cases:
            if name == 'regressions':
                strict = subprocess.run([sys.executable, str(project / 'tools/check_gdscript_warnings.py'), '--godot', args.godot, '--artifacts', str(artifacts / 'strict')], env=environment, timeout=300)
                if strict.returncode: return strict.returncode
            log_path = artifacts / (name + '.log')
            command = [args.godot, *(['--audio-driver',args.audio_driver] if args.audio_driver else []), '--rendering-method', 'gl_compatibility', '--path', str(project), '--log-file', str(log_path), *switches]
            result = subprocess.run(command, env=environment, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=180)
            log = log_path.read_text(encoding='utf-8', errors='replace') if log_path.exists() else 'ERROR: Missing Godot log'
            console = result.stdout + result.stderr
            (artifacts / (name + '-console.log')).write_text(console, encoding='utf-8')
            log += '\n' + console
            errors = [line for line in log.splitlines() if any(marker in line for marker in ['ERROR:', 'FAIL:', 'SCRIPT ERROR', 'INTEGRITY ANOMALY', 'ObjectDB instances leaked', 'ObjectDB instances were leaked', 'Orphan Nodes detected', 'Resources still in use at exit']) and 'Failed to read the root certificate store' not in line]
            print(f'{name}: ' + ('PASS' if result.returncode == 0 and not errors else 'FAIL'))
            for line in log.splitlines():
                if line.startswith(('RESULT:', 'PLAYTHROUGH', 'FAIL:')):
                    print(line)
            if result.returncode or errors:
                print(log)
                return 1
        if args.artifacts:
            print(f'Artifacts: {artifacts}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
