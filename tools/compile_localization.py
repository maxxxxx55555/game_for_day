"""Compile editable bilingual copy; canonical source stays stable for authenticated saves."""
import csv,json,re
from pathlib import Path
root=Path(__file__).resolve().parents[1];folder=root/'data/strings'
with (folder/'ru.csv').open(encoding='utf-8',newline='') as f: rows=list(csv.DictReader(f))
with (folder/'en.csv').open(encoding='utf-8',newline='') as f: assert rows==list(csv.DictReader(f)), 'CSV catalogs disagree'
catalog={}
printf=re.compile(r'%(?:[-+0#]*\d*(?:\.\d+)?[sdif]|%)')
for row in rows:
    assert row['key'] not in catalog
    assert row['ru'] and row['en']
    assert printf.findall(row['ru'])==printf.findall(row['en']),row['key']
    catalog[row['key']]={lang:row[lang].replace('\r\n','\n') for lang in ('ru','en')}
aliases=json.loads((folder/'choice_aliases.json').read_text(encoding='utf-8'))
(folder/'localization.json').write_text(json.dumps({'strings':catalog,'aliases':aliases},ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
print('LOCALIZATION COMPILE PASS:',len(catalog),'RU/EN keys')
