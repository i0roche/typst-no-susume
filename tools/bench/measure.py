import subprocess,time,statistics as st,os,re,signal
def run(cmd):
    t=time.perf_counter(); subprocess.run(cmd,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL); return time.perf_counter()-t
def clean():
    for f in os.listdir('.'):
        if f.startswith(('bench.','bench-p.')) and f.split('.')[-1] in ('aux','log','pdf','dvi','fls','fdb_latexmk','out'): os.remove(f)
def med(xs): return st.median(xs)
# Typst: cold process, full compile
ty=[run(['typst','compile','bench.typ','bench-typ.pdf']) for _ in range(10)]
# LuaLaTeX full from clean via latexmk (2 passes)
lf=[]
for _ in range(5):
    clean(); lf.append(run(['latexmk','-lualatex','-interaction=nonstopmode','-silent','bench.tex']))
# LuaLaTeX one pass with aux present (edit & rebuild)
l1=[run(['lualatex','-interaction=nonstopmode','bench.tex']) for _ in range(5)]
# pLaTeX + dvipdfmx full from clean via latexmk (2 passes)
pf=[]
for _ in range(5):
    clean(); pf.append(run(['latexmk','-e','$latex=q/platex %O %S/;$dvipdf=q/dvipdfmx %O -o %D %S/','-pdfdvi','-interaction=nonstopmode','-silent','bench-p.tex']))
# pLaTeX one pass + dvipdfmx with aux present (edit & rebuild)
def p1():
    t=time.perf_counter()
    subprocess.run(['platex','-interaction=nonstopmode','bench-p.tex'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    subprocess.run(['dvipdfmx','-q','bench-p.dvi'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    return time.perf_counter()-t
p1s=[p1() for _ in range(5)]
print("typst full median %.3f s  (min %.3f max %.3f)"%(med(ty),min(ty),max(ty)))
print("lualatex latexmk clean median %.3f s (min %.3f max %.3f)"%(med(lf),min(lf),max(lf)))
print("lualatex 1 pass median %.3f s (min %.3f max %.3f)"%(med(l1),min(l1),max(l1)))
print("platex latexmk clean median %.3f s (min %.3f max %.3f)"%(med(pf),min(pf),max(pf)))
print("platex 1 pass + dvipdfmx median %.3f s (min %.3f max %.3f)"%(med(p1s),min(p1s),max(p1s)))
# Typst watch: edit one char, read reported compile time
src=open('bench.typ').read()
p=subprocess.Popen(['typst','watch','bench.typ','bench-typ.pdf'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1)
import threading,queue
q=queue.Queue()
threading.Thread(target=lambda:[q.put(l) for l in p.stdout],daemon=True).start()
time.sleep(3)
while not q.empty(): q.get()
times=[]
for i in range(8):
    new=src.replace('測定値には','測定値に'+('は'*0)+('x' if i%2==0 else '')+'は',1) if False else src.replace('本実験では，','本実験では，'+'あ'*(i+1),1)
    open('bench.typ','w').write(new)
    t0=time.perf_counter(); line=None
    while time.perf_counter()-t0<10:
        try: l=q.get(timeout=0.2)
        except queue.Empty: continue
        if 'compiled' in l: line=l.strip(); break
    times.append((time.perf_counter()-t0,line))
open('bench.typ','w').write(src)
p.send_signal(signal.SIGINT); time.sleep(0.5); p.kill()
for t,l in times: print("%.3f s wall | %s"%(t,l))
