# 使い方: python3 gen.py 12 で bench.tex / bench-p.tex / bench.typ を作り，python3 measure.py で測る
# 図に使う fig1.png がなければ，灰色のダミー画像を作る
import sys,os,zlib,struct
if not os.path.exists("fig1.png"):
    W,H=400,300
    def chunk(t,d): return struct.pack(">I",len(d))+t+d+struct.pack(">I",zlib.crc32(t+d)&0xffffffff)
    raw=b"".join(b"\x00"+b"\xb4"*W for _ in range(H))
    open("fig1.png","wb").write(b"\x89PNG\r\n\x1a\n"+chunk(b"IHDR",struct.pack(">IIBBBBB",W,H,8,0,0,0,0))+chunk(b"IDAT",zlib.compress(raw))+chunk(b"IEND",b""))
N=int(sys.argv[1]) if len(sys.argv)>1 else 12
para=("本実験では，マイコンボードに接続したセンサの出力電圧を測定し，その結果をもとに回路の特性を調べた。"
      "測定値には機器の精度による誤差が含まれるため，同一条件で複数回の測定を行い，平均値と標準偏差を求めた。"
      "得られた結果を理論値と比較し，両者の差の原因について考察した。")
def tex():
    o=[r"\documentclass[11pt,a4paper]{ltjsarticle}",r"\usepackage{amsmath}",r"\usepackage{graphicx}",r"\usepackage{booktabs}",r"\begin{document}",r"\title{ベンチマーク用レポート}\author{}\date{}\maketitle"]
    for i in range(N):
        o.append(rf"\section{{実験{i+1}}}")
        o.append(para*3+"\n")
        o.append(rf"共振周波数は式\eqref{{eq{i}}}で表される。")
        o.append(r"\begin{equation}"+rf"\label{{eq{i}}} f_0 = \frac{{1}}{{2\pi\sqrt{{LC}}}} + \sum_{{k=1}}^{{{i+2}}} \frac{{x_k}}{{k^2}}"+r"\end{equation}")
        o.append(para*2+"\n")
        o.append(rf"測定結果を表\ref{{tab{i}}}に示す。")
        o.append(r"\begin{table}[h]\centering\caption{測定結果}"+rf"\label{{tab{i}}}"+r"\begin{tabular}{lrr}\toprule 条件 & 電圧 [V] & 電流 [mA]\\\midrule A & 1.23 & 4.5\\ B & 2.34 & 5.6\\ C & 3.45 & 6.7\\\bottomrule\end{tabular}\end{table}")
        if i%3==0:
            o.append(r"\begin{figure}[h]\centering\includegraphics[width=0.5\textwidth]{fig1.png}\caption{実験装置}\end{figure}")
        o.append(para*2+"\n")
    o.append(r"\end{document}")
    return "\n".join(o)
def typ():
    o=['#set page(paper: "a4")','#set text(font: "Harano Aji Mincho", size: 11pt, lang: "ja")','#set heading(numbering: "1.")','#set math.equation(numbering: "(1)")','#set par(first-line-indent: 1em)','#align(center)[#text(size: 17pt)[ベンチマーク用レポート]]']
    for i in range(N):
        o.append(f"= 実験{i+1}")
        o.append(para*3+"\n")
        o.append(f"共振周波数は式#ref(<eq{i}>)で表される。")
        o.append(f"$ f_0 = 1/(2 pi sqrt(L C)) + sum_(k=1)^({i+2}) x_k/k^2 $ <eq{i}>")
        o.append(para*2+"\n")
        o.append(f"測定結果を#ref(<tab{i}>)に示す。")
        o.append(f'#figure(table(columns: 3, stroke: none, table.hline(), [条件], [電圧 [V]], [電流 [mA]], table.hline(), [A],[1.23],[4.5],[B],[2.34],[5.6],[C],[3.45],[6.7], table.hline()), caption: [測定結果]) <tab{i}>')
        if i%3==0:
            o.append('#figure(image("fig1.png", width: 50%), caption: [実験装置])')
        o.append(para*2+"\n")
    return "\n".join(o)
open("bench.tex","w").write(tex()); open("bench.typ","w").write(typ())
# pLaTeX 用(学校のテンプレートと同じ jarticle): 本文は同じで，クラスだけ替える
open("bench-p.tex","w").write(tex().replace(r"\documentclass[11pt,a4paper]{ltjsarticle}",r"\documentclass[dvipdfmx,11pt,a4paper]{jarticle}"))
