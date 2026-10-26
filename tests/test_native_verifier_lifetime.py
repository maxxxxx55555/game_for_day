"""Verify that a private native victory verifier survives deletion of its UI owner."""
import argparse,os,subprocess,time,json,hashlib
from pathlib import Path
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--exe',type=Path,required=True);parser.add_argument('--artifacts',type=Path,required=True);parser.add_argument('--timeout',type=int,default=120);args=parser.parse_args()
folder=args.artifacts.resolve();folder.mkdir(parents=True,exist_ok=False);exe=args.exe.resolve();env=os.environ.copy();env.update(GAME_AUDIO_MUTED='1',GAME_QA='1',GAME_LANGUAGE='en')
for var,part in [('APPDATA','roaming'),('LOCALAPPDATA','local')]:
 p=folder/'profile'/part;p.mkdir(parents=True,exist_ok=True);env[var]=str(p)
start=time.monotonic();timed_out=False
with (folder/'console.log').open('w',encoding='utf-8') as log:
 p=subprocess.Popen([str(exe),'--headless','--','--verify-build'],cwd=exe.parent,env=env,stdout=log,stderr=subprocess.STDOUT)
 (folder/'process.json').write_text(json.dumps(dict(pid=p.pid,exe=str(exe)),indent=2)+'\n')
 try:code=p.wait(timeout=args.timeout)
 except subprocess.TimeoutExpired:p.kill();p.wait();code=p.returncode;timed_out=True
text=(folder/'console.log').read_text(encoding='utf-8');errors=[s for s in text.splitlines() if any(v in s for v in ['ERROR:','SCRIPT ERROR','FAIL:','INTEGRITY ANOMALY']) and 'root certificate store' not in s]
record=dict(result='PASS' if not timed_out and code==0 and 'EXPORTED PLAYTHROUGH: PASS' in text and not errors else 'FAIL',timed_out=timed_out,exit=code,completed_victory='EXPORTED PLAYTHROUGH: PASS' in text,errors=errors,seconds=round(time.monotonic()-start,3),binary_sha256=hashlib.sha256(exe.read_bytes()).hexdigest(),console_sha256=hashlib.sha256(text.encode()).hexdigest())
(folder/'result.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record,indent=2));print(text[-1600:]);raise SystemExit(0 if record['result']=='PASS' else 1)
