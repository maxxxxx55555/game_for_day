"""Catalog regeneration must preserve canonical LF bytes on every host."""
from pathlib import Path
import json,shutil,subprocess,sys,tempfile
root=Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='fortune-localization-') as temporary:
    project=Path(temporary)
    for rel in ['tools/compile_localization.py','data/strings/en.csv','data/strings/ru.csv','data/strings/choice_aliases.json']:
        destination=project/rel;destination.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(root/rel,destination)
    subprocess.run([sys.executable,str(project/'tools/compile_localization.py')],check=True)
    raw=(project/'data/strings/localization.json').read_bytes()
    assert b'\r\n' not in raw,'Localization generator must emit canonical LF on Windows'
    assert json.loads(raw)==json.loads((root/'data/strings/localization.json').read_text(encoding='utf-8')),'Generated catalog content differs'
print('LOCALIZATION GENERATION PASS: deterministic LF bytes and identical bilingual content')
