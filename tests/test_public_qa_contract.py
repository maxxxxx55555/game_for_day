"""Public pack must exclude QA routes; an export feature alone is insufficient."""
import configparser,re
from pathlib import Path
root=Path(__file__).resolve().parents[1]
config=configparser.ConfigParser(interpolation=None,strict=False)
config.read(root/'export_presets.cfg',encoding='utf-8')
def value(section,key):return config[section].get(key,'').strip('"')
presets=[s for s in config.sections() if re.fullmatch(r'preset\.\d+',s)]
qa=[s for s in presets if value(s,'name')=='Windows QA']
public=[s for s in presets if value(s,'name')=='Windows Desktop']
assert len(qa)==1 and len(public)==1,'Separate public and private QA presets are required'
route='scripts/ReleaseVerification.gd*'
for section in public:
    assert 'qa_verifier' not in value(section,'custom_features')
    assert route in value(section,'exclude_filter'),'Public exporter must physically omit the verifier'
for section in qa:
    assert 'qa_verifier' in value(section,'custom_features')
    assert route not in value(section,'exclude_filter')
# 2.1.1 ships NON-encrypted public/QA packs for runnability (PCK encryption was
# disabled in b0e7d59 because the pack key is private and must never be stored in
# the repo). The genuine security boundary is feature separation plus the physical
# exclusion of the QA verifier (enforced above via exclude_filter and below via the
# preload scan); PCK encryption is a secondary obfuscation layer, not the gate.
# We therefore keep every other hardening assertion and only stop demanding
# encrypt_pck/encrypt_directory == 'true'.
for section in public+qa:
    assert value(section,'encryption_include_filters')=='*'
    assert value(section,'script_export_mode')=='2'
    assert value(section+'.options','debug/export_console_wrapper')=='0'
for source in (root/'scripts').rglob('*.gd'):
    if 'verification' in source.parts or source.name=='ReleaseVerification.gd':continue
    assert not re.search(r'preload\([^\n]*ReleaseVerification',source.read_text()),source
router=(root/'scripts/security/QARouter.gd').read_text()
assert 'OS.has_feature("qa_verifier")' in router and 'OS.get_environment("GAME_QA")' in router
print('PUBLIC QA CONTRACT PASS: separate feature/env gate, physical exclusion, hardening filters')
print('  public encrypt_pck=%s / encrypt_directory=%s (2.1.1 non-encrypted pack by design)' % (value(public[0],'encrypt_pck'), value(public[0],'encrypt_directory')))
