"""Reject untranslated scene defaults, missing literal keys, and UI/model copy outside catalogs."""
import csv,json,re
ALLOWED_NATIVE={"Русский", "хакатон", "нейросетей", "фонд ищет", "Проблемы со здоровьем", "Антимонопольный"}
ALLOWED_SCENE={"E"}

from pathlib import Path
root=Path(__file__).resolve().parents[1]
rows=list(csv.DictReader((root/'data/strings/ru.csv').open(encoding='utf-8',newline='')))
assert rows==list(csv.DictReader((root/'data/strings/en.csv').open(encoding='utf-8',newline='')))
keys={row['key'] for row in rows};failures=[]
for p in sorted((root/'scripts').rglob('*.gd')):
    text=p.read_text(encoding='utf-8')
    for match in re.finditer(r'"(?:[^"\\\r\n]|\\.)*"',text):
        literal=json.loads(match.group())
        if re.search('[А-Яа-яЁё]',literal) and literal not in ALLOWED_NATIVE:
            failures.append(str(p.relative_to(root))+': copy outside keyed catalog: '+literal)
    for match in re.finditer(r'(?:get_string|source)\("([a-z][a-z0-9_.-]+)"\s*[,)]',text):
        if match[1] not in keys:failures.append(str(p.relative_to(root))+': missing key '+match[1])
for p in sorted((root/'scenes').rglob('*.tscn')):
    for line in p.read_text(encoding='utf-8').splitlines():
        if re.match(r'(?:text|tooltip_text|placeholder_text) = ',line):
            value=json.loads(line.split(' = ',1)[1])
            if re.search('[A-Za-zА-Яа-яЁё]',value) and value not in ALLOWED_SCENE:
                failures.append(str(p.relative_to(root))+': hardcoded scene copy: '+value)
fixture=json.loads((root/'tests/fixtures/canonical-model-copy.json').read_text(encoding='utf-8'))
bykey={row['key']:row for row in rows}
for entry in fixture['entries']:
    assert bykey[entry['key']]['ru']==entry['ru'],'Changed canonical Russian: '+entry['key']

legacy=json.loads((root/'tests/fixtures/canonical-v1.4-copy.json').read_text(encoding='utf-8'))
for key,value in legacy['strings'].items():assert bykey[key]['ru']==value,'Russian1.4 byte regression: '+key
current_events=json.loads((root/'data/events.json').read_text(encoding='utf-8'))
def canonical(value):
    if isinstance(value,list):return [canonical(x) for x in value]
    if isinstance(value,dict):return {k:canonical(v) for k,v in value.items() if not k.endswith(('_key','_ru','_en'))}
    return value
assert canonical(current_events)==legacy['external_events'],'Event order, stage, canonical copy or economic deltas changed'
for failure in failures:print('FAIL:',failure)
assert not failures,str(len(failures))+' copy contract failures'
print('COPY CONTRACT PASS:',len(rows),'keys, scene/model source audit and canonical copy')
