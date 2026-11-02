#import "common.typ": *
#import "@preview/tiaoma:0.3.0": qrcode

// 本書のソースの置き場所
#let repo-url = "https://github.com/i0roche/typst-no-susume"

#show: guide.with(
  [Typstのすゝめ],
  subtitle: [実験レポートのための入門書],
  author: [電子工学科 4年],
  bib: (
    typst: "Typst：typst/typst, GitHub, https://github.com/typst/typst",
    tw: "Thoughtworks：Typst, Technology Radar, https://www.thoughtworks.com/en-ca/radar/tools/typst",
    rein: "rein：Typstで実験レポートを書いた話, Zenn, https://zenn.dev/hanbaagu1/articles/mma-adc2025-day23",
    tinymist: "Myriad-Dreamin：tinymist, GitHub, https://github.com/Myriad-Dreamin/tinymist",
    issoh: "株式会社一創：Typstで縦書き・ルビはできる？和文組版の設定と使い方【0.15.1で検証】, 一創 Tech Blog, https://www.issoh.co.jp/tech/details/9859/",
    docs: "Typst：Typst Documentation, Typst, https://typst.app/docs/",
    universe: "Typst：Typst Universe, Typst, https://typst.app/universe/",
    codelst: "jneug：codelst, Typst Universe, https://typst.app/universe/package/codelst/",
    unbreak: "KZNS：cjk-unbreak, Typst Universe, https://typst.app/universe/package/cjk-unbreak",
    issoh2: "株式会社一創：Typst（タイプスト）とは？LaTeXとの違い・使い方・料金を初心者向けに解説【0.15対応】, 一創 Tech Blog, https://www.issoh.co.jp/tech/details/5507/",
  ),
)


= 目的
実験レポートは数式・図表・参考文献が多く，番号の付け方や配置にも決まりがある。本クラスでは主にWordが使われており，LaTeXを使う人も増えつつある。そこで本書では，実験レポートの作成ツールとして，WordやLaTeXに加えてTypstを提案する。そのために，コンパイル時間，記法，機能をWordとLaTeXの両方と比較して示し，導入の方法も示す。

本書自体も，学科の「実験報告書(レポート)の書き方」の様式(A4縦，本文は明朝体，見出しはゴシック体，図の見出しは図の下，表の見出しは表の上など)に合わせてTypstで組んでいる。本書のソース一式は GitHub(#link(repo-url)[#raw(repo-url)])で公開しており，書式をまとめた `common.typ` は，そのまま実験レポートに流用できる。

= Typstとは
TypstはRustで実装された新しい組版システムである#c("typst")。文章をテキストファイルに書き，コンパイルするとPDFが得られる。この流れはLaTeXと同じだが，LaTeXと同程度の表現力を，より簡単な使い方で実現することを目指している#c("typst")。無料のオープンソースソフトウェア#footnote[ライセンスは Apache-2.0 である。]であり，ブラウザ上のWebアプリ(typst.app)でも，パソコンに入れるコマンドラインツールとしても使える。

書き方には3つの場面がある。文章はMarkdownに近い記法で書き(`=` で見出し，`-` で箇条書き)，数式は `$` で囲んで書き，プログラムは `#` から始めて書く。この3つは1つのファイルの中で切り替えながら使える。文章を書く感覚のまま，必要なところだけ数式やプログラムを足していける。

= 特長
#set enum(numbering: "(1)")
+ *コンパイルが軽い*#h(0.6em)Thoughtworks の技術レーダーでは，LaTeXより高速なコンパイルが評価され，採用を試す価値がある「Trial」に位置づけられている#c("tw")。手元の測定では，同じ文書の全体のコンパイルが，学校のテンプレートと同じpLaTeXより約1.6〜1.8倍，LuaLaTeXより約11〜13倍速かった。1か所を直したあとの再コンパイルは約0.012秒で終わった(後述)。入力のたびに結果を確かめる書き方をしても，待たされない。
+ *VS Codeで即プレビュー*#h(0.6em)拡張機能 Tinymist は言語サーバとプレビューを提供する#c("tinymist")。ソースの横にプレビューを表示でき，入力に合わせて更新される。実験レポートでの使用例でも，ほぼ遅延なく更新されたと報告されており，LaTeXでは保存してから3〜10秒かけてコンパイルしていたという#c("rein")。
+ *エラーが読みやすい*#h(0.6em)LaTeXより明確なエラーメッセージを出すと評価されている#c("tw")。@fig-err のように，ファイル名・行・列と原因を示し，ソースの該当箇所を指してくれる。メッセージは英語だが，どこを直せばよいかはすぐ分かる。同じ間違い(存在しない参照)をLuaLaTeXでコンパイルすると，@fig-err-tex のように，行番号つきの警告が出るだけで，エラーにならずPDFが作られる。本文中には「??」が出力され，ログの中から警告を探す必要がある。
+ *数式を短く書ける*#h(0.6em)分数は ```typc a/b```，平方根は ```typc sqrt(x)```，ギリシャ文字は ```typc pi``` のように，名前をそのまま書く。TeXの ```latex \frac{a}{b}``` ```latex \sqrt{x}``` ```latex \pi``` と比べて短い#footnote[筆者の所感であり，TeXに慣れていればTeXの方が書きやすいという意見もある。]。
+ *中間ファイルが出ない*#h(0.6em)LaTeXでは `.aux` `.log` `.toc` などの補助ファイルができる#footnote[手元の測定では，LuaLaTeXは `.aux` `.log` `.fls` `.fdb_latexmk` を生成した。]。Typstが出力するのはPDFだけで，フォルダにはソースと結果だけが残る。
+ *関数で自動化できる*#h(0.6em)変数，条件分岐，繰り返し，関数を使える。有効数字の整形や表の生成のような，実験レポートの面倒な処理をプログラムとして書ける。有効数字を揃える関数を自作した例がある#c("rein")。
+ *日本語を書きやすい*#h(0.6em)日本語のフォントと ```typc lang: "ja"``` を指定すれば，日本語を書ける。LaTeXのように，日本語用のクラスやエンジンを選ぶ必要がない。`lang` を指定しないと，図表の見出しが「Table 1」のように英語になる。また，ソースで和文の途中を改行すると，出力に半角スペースが入る。段落の中では改行しないか，パッケージ cjk-unbreak で取り除く#c("unbreak")。


= コンパイル時間の測定
同じ内容の文書をTypst，pLaTeX，LuaLaTeXで書き，コンパイル時間を比べた。pLaTeXは学校のレポートのテンプレート(jarticle)が前提とするエンジンで，LuaLaTeXは現在よく勧められるエンジンである。文書は日本語の本文，数式，表，図を含むA4の文書で，章の数を2・12・36に変えて3種類作った#footnote[ページ数はTypstで3・13・37，pLaTeXで3・16・46，LuaLaTeXで3・14・41である。12章の文書は数式12個，表12個，図4枚を含む。]。結果を@tab-bench に示す。

#figure(
  table(columns: (1.5fr, 1fr, 1fr, 1fr), align: (left, center, center, center),
    rows: (2pt, auto),
    table.hline(),
    table.cell(colspan: 4)[],
    table.hline(),
    [場面], [Typst], [pLaTeX], [LuaLaTeX],
    table.hline(),
    [全体(2章)], [約 0.14 秒], [約 0.25 秒], [約 1.8 秒],
    [全体(12章)], [約 0.17 秒], [約 0.29 秒], [約 2.0 秒],
    [全体(36章)], [約 0.23 秒], [約 0.38 秒], [約 2.6 秒],
    [再コンパイル(12章)], [約 0.012 秒], [約 0.12 秒], [約 0.91 秒],
    table.hline()),
  caption: [同じ文書のコンパイル時間],
) <tab-bench>

全体のコンパイルでは，TypstはpLaTeXより約1.6〜1.8倍，LuaLaTeXより約11〜13倍速かった。pLaTeXも36章で約0.38秒であり，差は小さい。LaTeXの速さはエンジンによって大きく変わり，遅いのは主にLuaLaTeXである。

再コンパイルは1か所を直したあとにもう一度コンパイルする場面であり，プレビューを見ながら書くときの待ち時間に当たる。LaTeXは，参照が変わらなければ1回の処理で済み，pLaTeX#footnote[dvipdfmxでのPDF化の時間を含む。]は約0.12秒，LuaLaTeXは約0.91秒かかった。Typstは前回の結果を再利用するので，```sh typst watch``` でのコンパイル自体は約0.012秒だった。ただし保存からPDFの更新までは約0.1秒で，体感の差は小さい。強みは，入力のたびにプレビューが更新される点にある。

LaTeXの全体のコンパイルは，参照を解決するために，latexmk が2回処理した時間である。Typstは1回の実行で参照を解決する。Typst 0.15.1，pLaTeX(jarticle)とdvipdfmx，LuaHBTeX 1.24.0(ltjsarticle)，いずれもTeX Live 2026で，筆者のPC(Linux)で測った。Typstは10回(再コンパイルは8回)，LaTeXは各5回の中央値を示した。厳密なベンチマークではない。結果は文書の内容や環境によって変わる。

#codefig("error: label `<eq0で表される>` does not exist in the document
   ┌─ bench.typ:10:7
   │
10 │ 共振周波数は式@eq0で表される。
   │               ^^^^^^^^^^^^^^", [Typstのエラーメッセージの例(存在しないラベルの参照)], "fig-err", lang: none, placement: top, numbers: false)

#codefig("LaT\u{2060}eX Warning: Reference `eq0' on page 1 undefined on input line 3.
LaT\u{2060}eX Warning: There were undefined references.", [LuaLaTeXの出力の例(存在しない参照，エラーにならない)], "fig-err-tex", lang: none, placement: top, numbers: false)

= Word・LaTeX・Typst の比較
三者の特徴を@tab-cmp にまとめる。評価は筆者の所感である。

Wordは見た目を確かめながら直接編集でき，導入の障壁が最も低い。一方，数式の入力や図表番号・相互参照の管理にマウス操作が多く，書式をそろえる作業が手作業になりやすい。LaTeXは組版の品質，数式，文献管理の点で定番であり，学会のテンプレートなどの資産も多い。一方，環境の構築が重く，エンジンによってはコンパイルに数秒かかり(@tab-bench)，エラーメッセージが読みにくい。TypstはLaTeXと同じく文章をテキストで書く方式を，軽さと書きやすさで改良したものと位置づけられる。一方，資産はまだ少なく，縦書きやルビには外部パッケージが必要である。

#figure(
  table(columns: (1.25fr, 0.75fr, 1.4fr, 1fr), align: (left, center, center, center),
    rows: (2pt, auto),
    table.hline(),
    table.cell(colspan: 4)[],
    table.hline(),
    [], [Word], [LaTeX], [Typst],
    table.hline(),
    [導入の手軽さ], [◎], [△ 環境構築], [○ Web版あり],
    [待ち時間], [◎], [○〜△ エンジンによる], [◎ 速い],
    [エラーの分かりやすさ], [―], [△], [○],
    [数式], [△ GUI操作], [◎ 定番], [◎ 短い],
    [図表・文献の番号], [△ 手作業], [◎], [◎],
    [Gitでの差分管理], [△], [◎], [◎],
    [学会テンプレート], [○], [◎], [△ 少ない],
    [縦書き・ルビ], [◎], [◎], [△ パッケージ],
    table.hline()),
  caption: [三者の比較],
) <tab-cmp>

= 記法の比較(LaTeX と Typst)
LaTeXは `\` から始まる命令と，`{ }` で囲む引数，```latex \begin``` と ```latex \end``` で囲む環境で書く。Typstは見出しや箇条書きを記号で書き，命令は `#` から始める。同じことを書いたときの記法を@tab-syntax に示す。

#figure(
  table(columns: (1fr, 1fr, 1fr), align: left,
    rows: (2pt, auto),
    table.hline(),
    table.cell(colspan: 3)[],
    table.hline(),
    [], [LaTeX], [Typst],
    table.hline(),
    [見出し], [```latex \section{目的}```], [```typ = 目的```],
    [強調], [```latex \textbf{重要}```], [```typ *重要*```],
    [箇条書き], [```latex \begin{itemize}\item …```], [```typ - …```],
    [分数], [```latex $\frac{a}{b}$```], [```typ $a/b$```],
    [図の参照], [```latex \ref{fig:a}```], [```typ @fig-a```],
    [コンパイル], [```sh latexmk```], [```sh typst compile```],
    table.hline()),
  caption: [同じことを書くときの記法],
) <tab-syntax>

実際に同じ内容を書くと，@fig-tex と@fig-typ のようになる。Typstの方が行数も記号も少なく，ソースがそのまま読みやすい。

#block(width: 100%, stroke: 0.5pt + ink, radius: 4pt, inset: 6pt, breakable: false)[
  #text(font: gothic, size: 0.93em)[(同じ内容の比較)]
  #grid(columns: (1.2fr, 1fr), column-gutter: 5pt,
    codefig("\\section{目的}
ラインセンサの出力を\\textbf{調べる}。
\\begin{itemize}
  \\item 白: 0.8 V 以上
  \\item 黒: 0.2 V 以下
\\end{itemize}", [LaTeXで書いた例], "fig-tex", lang: "latex", height: 11.6em),
    codefig("= 目的
ラインセンサの出力を*調べる*。
- 白: 0.8 V 以上
- 黒: 0.2 V 以下", [Typstで書いた例], "fig-typ", lang: "typ", height: 11.6em),
  )
]

= 数式
数式は `$` で囲んで書く。前後に空白を入れると独立行になり，中央に置かれて，右端に式番号が付く。空白を入れないと，文中の数式になる。分数は `/`，上付きは `^`，下付きは `_`，平方根は ```typc sqrt()```，総和は ```typc sum``` のように，TeXより短い名前で書く。ギリシャ文字は ```typc pi``` や ```typc alpha``` と書くだけでよい。単位などの文字は引用符で囲むと立体になり，物理量を斜体，単位を立体とする規則に合わせられる。次の例では共振周波数を式@eq-res として書いている。

#demo("数式の例", "共振周波数 $f_0$ は，次式で表される。
$ f_0 = 1/(2 pi sqrt(L C)) quad [\"Hz\"] $ <eq-res>
ここで，$L$ はインダクタンス，$C$ は静電容量である。式@eq-res より，$f_0$ は $L C$ の平方根に反比例することがわかる。")

式番号は自動で振られ，```typ @eq-res``` のように書けば本文から引用できる。式を追加して番号がずれても，引用の番号も一緒に更新される。注意点として，複数の文字を続けて書くと1つの名前として扱われる。そのため，$L$ と $C$ の積は `LC` ではなく `L C` と，空白で区切って書く。

行列は ```typc mat()```，総和は ```typc sum``` で書ける。式@eq-mat はその例である。

#demo("行列と総和の例", "$ A = mat(1, 2; 3, 4), quad
  sum_(k=1)^n k = (n(n+1))/2 $ <eq-mat>")

= 表と図表番号
表の見出しは表の上に付き，番号は自動で振られる。本文からは @tab-sensor のように引用でき，表の順序を入れ替えても番号を手で直す必要がない。罫線は ```typc table.hline()``` で引き，三線表にしている。

#demo("表の例", "- 白: 0.8 V 以上
- 黒: 0.2 V 以下

#figure(
  table(columns: 2,
    rows: (2pt, auto),
    table.hline(),
    table.cell(colspan: 2)[],
    table.hline(),
    [状態], [出力 [V]],
    table.hline(),
    [白], [0.85],
    [黒], [0.12],
    table.hline()),
  caption: [センサ出力],
) <tab-sensor>

@tab-sensor を参照。")

図も同じ仕組みで，画像ファイルを ```typc image()``` で読み込み，```typc figure()``` で囲んで見出しとラベルを付ける。見出しは図の下に付き，番号は表とは別に数えられる。@fig-image に例を示す。

#codefig("#figure(
  image(\"circuit.png\", width: 60%),
  caption: [回路図],
) <fig-circuit>

回路を@fig-circuit に示す。", [図の読み込みと引用], "fig-image", lang: "typ")

= 書式の設定
Typstでは文書全体の書式を ```typ #set``` と ```typ #show``` で宣言する。```typ #set``` はページ，文字，段落，見出しなどの既定値を決める。```typ #show``` は特定の要素の見た目を決める。@fig-set は見出しの番号，式番号，段落の1字下げ，表の見出しを表の上に置く設定である。このような決まりを数行で書ける。

#codefig("#set page(paper: \"a4\", numbering: \"1\")
#set text(font: \"Harano Aji Mincho\", size: 10.5pt, lang: \"ja\")
#set par(first-line-indent: (amount: 1em, all: true))
#set heading(numbering: \"1.\")
#set math.equation(numbering: \"(1)\")
#show figure.where(kind: table): set figure.caption(position: top)", [書式の設定の例], "fig-set", lang: "typ")

書式の決まりをこのように1か所にまとめておけば，レポートごとに設定し直す必要がなく，書式のばらつきも防げる。本書もこの方法で書式を `common.typ` にまとめている。

= 関数による自動化
Typstには変数，条件分岐，繰り返し，関数がある。データの丸めや表の生成のような繰り返し作業を，関数にして使い回せる。有効数字を揃える関数を自作して，表の全数値に適用した例が報告されている#c("rein")。

#demo("関数の例", "#let r3(x) = str(calc.round(x, digits: 3))
#let data = (1.23456, 2.5, 3.14159)
#for x in data [
  - #x → #r3(x)
]")

測定データはCSVファイルから読み込める。@fig-csv のように ```typc csv()``` で読み込めば，データを書き写す手間と，転記ミスを減らせる。作図やSI単位の表記には，パッケージ cetz や unify がある#c("universe")。パッケージは1行で読み込め，インストールの作業は要らない。

#codefig("#let rows = csv(\"data.csv\")
#table(columns: 2, ..rows.flatten())", [CSVファイルの読み込み], "fig-csv", lang: "typ")

表の罫線のように，毎回同じ形になる書き方も関数にまとめられる。@fig-ftab は筆者が自作した三線表の関数 `ftab` である。表題，見出し行，データを渡すだけで，罫線と番号の付いた表ができる。表を組むたびに ```typc table.hline()``` を並べる手間がなくなり，罫線の太さを変えたいときも1か所の修正で済む。

#codefig("#let ftab(capt, header, cells, sup: \"表\") = {
  [#figure(
    caption: capt,
    supplement: sup,
    table(
      columns: header.len(),
      rows: (2pt,) + (auto,),
      table.hline(),
      table.cell(colspan: header.len())[],
      table.hline(),
      ..header.flatten(),
      table.hline(),
      ..cells.flatten(),
      table.hline(),
    )
  )]
}", [三線表を組む関数 ftab], "fig-ftab", lang: "typ")

#demo("ftab の例", "#ftab([測定結果],
  ([条件], [電圧 [V]]),
  (([A], [1.23]), ([B], [2.34])),
) <tab-ftab>

@tab-ftab を参照。")

共通の書式を関数にまとめておけば，テンプレートとして使い回せる。本書も共通の書式を `common.typ` にまとめている。公開されているテンプレートは Typst Universe で探せる#c("universe")。

= ソースコードの掲載
ソースコードは言語を指定して貼るだけで，等幅フォントで組まれ，言語に合わせて色分けもされる。パッケージ codelst を使うと#c("codelst")，@fig-code のように，枠で囲み，行番号を付けて図として載せられる。

#codefig("data = [1.23456, 2.5, 3.14159]
for x in data:
    print(round(x, 3))", [ソースコードの掲載例(Python)], "fig-code", lang: "python")

長いプログラムはファイルを直接読み込むと便利である。@fig-src のように，行の範囲を指定すれば，必要な部分だけを本文に載せられる。ファイル全体は付録に載せ，本文では要点の数行だけを示す，という使い分けができる。ソースを修正しても，レポート側の掲載内容は自動で更新される。

#codefig("#sourcefile(read(\"work4.ino\"), file: \"work4.ino\",
  lang: \"cpp\", showrange: (42, 49))", [ファイルの一部だけを載せる], "fig-src", lang: "typ")

= 引用と参考文献
参考文献のデータはBibTeX形式の `.bib` ファイルか，Hayagrivaと呼ばれる専用の記法のYAMLファイルで書く。@fig-yaml はHayagriva形式の例である。書式は CSL というスタイルファイルで選べ，学会や学科の書式に合わせて切り替えられる。本文では ```typ @radar``` のように引用すると，引用の順に番号が付き，末尾の文献一覧も自動で作られる。@fig-bib に，読み込みの書き方を示す。

#codefig("radar:
  type: article
  title: \"RADAR: An In-Building RF-based User Location and Tracking System\"
  author: [\"Bahl, Paramvir\", \"Padmanabhan, Venkata N.\"]
  date: 2000
  page-range: 775-784
  parent:
    type: proceedings
    title: Proceedings of IEEE INFOCOM 2000
    volume: 2", [参考文献データの例(Hayagriva形式)], "fig-yaml", lang: "yaml")

#codefig("位置推定には信号強度が使われる @radar。

#bibliography(\"ref.yaml\", style: \"ieee\")", [参考文献の指定], "fig-bib", lang: "typ")

本書の参考文献は学科の書式#footnote[著者：タイトル，サイト名，URL，閲覧日の順に書く。]に合わせて，自作の関数で組んでいる。

= 適用範囲と制約
@tab-fit に，Typstが向く場面と向かない場面を示す。この表は先に紹介した `ftab` で組んでいる。

#ftab(
  [Typstが向く場面と向かない場面],
  ([向く], [向かない・注意]),
  (
    ([実験レポート・課題・配布資料], [縦書き・ルビ(外部パッケージで対応)#c("issoh")]),
    ([数式や図表が多い文書], [学会の投稿規定がTeX前提のとき]),
    ([Gitで履歴を管理したいとき], [日本語フォントと `lang` の指定が必要]),
    ([同じ書式を何度も使い回すとき], [0.x系で，書き方が変わることがある]),
  ),
  columns: (1fr, 1fr), align: left,
) <tab-fit>

実験レポートや課題，配布資料のように，PDFで提出する文書で，数式や図表が多いときは，Typstが向いている。書式をテンプレートにまとめて何度も使うときや，Gitで履歴を管理するときにも向いている。

一方，縦書きやルビが必要な文書には向かない。標準機能になく，外部パッケージで対応することになる#c("issoh")。また，学会の投稿規定がTeXのテンプレートを前提にしているときは，TeXを使う方が確実である。日本語のフォントと `lang` を指定する必要がある点と，まだ0.x系で，バージョンによって書き方が変わることがある点にも注意が必要である。長く使う文書では，使ったTypstとパッケージのバージョンを記録しておくとよい#c("issoh2")。また，日本語の情報やテンプレートはLaTeXよりまだ少ない。提出の形式がWord指定のときは，Wordを使う。

= 導入方法
Typstの使い方はWebアプリ，コマンドラインツール，VS Codeの3通りある。@tab-install に，環境ごとの入れ方を示す。迷ったときは，インストール不要のWebアプリから始めるのがよい。手元に入れる場合，`typst` 本体は1つの実行ファイルで，LaTeXのように大きな環境を用意する必要はない。

#ftab(
  [環境ごとのTypstの入れ方],
  ([環境], [入れ方], [備考]),
  (
    ([Webアプリ], [typst.app でアカウントを作る], [インストール不要#c("docs")]),
    ([Windows], [```sh winget install --id Typst.Typst```], [winget の標準的な方法]),
    ([Mac], [```sh brew install typst```], [Homebrew を使う]),
    ([Linux], [```sh sudo pacman -S typst``` (Arch) \ ```sh sudo snap install typst```], [OSのパッケージ管理を使う]),
    ([実行ファイル], [GitHub から入手してパスに置く#c("typst")], [パッケージ管理を使わない方法]),
    ([どの環境でも], [```sh cargo install --locked typst-cli```], [`cargo` が必要，ビルドが遅い]),
    ([VS Code], [Tinymist Typst を入れる#c("tinymist")], [ソースの横でプレビューできる]),
  ),
  columns: (0.7fr, 1.5fr, 1.3fr), align: left,
) <tab-install>

導入できたかどうかは，```sh typst --version``` でバージョンを表示して確かめる。VS Code の拡張機能は拡張機能の画面で Tinymist Typst を検索して入れる#footnote[コマンドでは ```sh code --install-extension myriad-dreamin.tinymist``` で入れられる。]。Tinymist のプレビューはPDFではなく独自に描画した画面なので，提出前には出力したPDFをPDFビューアで開いて確かめる#footnote[Tinymist にはスペルチェックの機能もないので，誤字は別の方法で確かめる。]。学校のパソコンのように，ソフトを入れられない環境では，Webアプリを使えばよい。パッケージは使うときに自動でダウンロードされるので，事前の準備は要らない。

= 最初の1ページの作成手順
#set enum(numbering: "Step 1.")
+ *Web版で試す*#h(0.6em)ブラウザで typst.app を開き，アカウントを作る。プレビュー付きのエディタが使え，インストールは要らない#c("docs")。まずはここで，数行書いてみるとよい。
+ *ローカルに入れる*#h(0.6em)@tab-install の方法で `typst` を入れる。VS Code を使うなら，拡張機能 Tinymist Typst も入れておく。
+ *日本語フォントを指定して書く*#h(0.6em)@fig-first のように先頭に設定を書き，あとは本文を書く。フォント名はOSに入っているものを指定する。使えるフォントは ```sh typst fonts``` で確認できる。日本語の明朝体の例はWindowsの Yu Mincho，Macの Hiragino Mincho ProN，Linuxの Noto Serif CJK JP である。

#codefig("#set text(font: \"Harano Aji Mincho\", lang: \"ja\")
#set page(paper: \"a4\")

= はじめてのレポート
Typst で書いている。数式は $E = m c^2$ である。", [最初の1ページ], "fig-first", lang: "typ")

= 基本的なコマンド
@fig-cmd に，よく使うコマンドを示す。```sh typst compile``` はPDFを1回作る。```sh typst watch``` はファイルを保存するたびに自動で再コンパイルする。```sh typst fonts``` は使えるフォントの一覧を表示するので，日本語フォントの名前を調べるときに使う。VS Code で Tinymist を使う場合は，プレビューを開いておけば，```sh typst watch``` と同じように，更新が自動で反映される。

#codefig("typst compile report.typ   # PDFを1回作る
typst watch report.typ     # 保存のたびに自動で再コンパイル
typst fonts                # 使えるフォントの一覧", [よく使うコマンド], "fig-cmd", lang: "sh")

= 関連資料
書き方の詳しい説明は公式ドキュメントにあり，テンプレートやパッケージは Typst Universe で探せる#c("docs","universe")。VS Code で使う拡張機能の案内は Tinymist のページにある#c("tinymist")。@fig-qr のQRコードから，それぞれのページに進める。

#figure(
  grid(columns: (1fr, 1fr, 1fr), gutter: 8pt,
    align(center)[#qrcode("https://typst.app/docs/", width: 25mm) \ #text(size: 0.85em)[公式ドキュメント]],
    align(center)[#qrcode("https://typst.app/universe/", width: 25mm) \ #text(size: 0.85em)[テンプレート集]],
    align(center)[#qrcode("https://github.com/Myriad-Dreamin/tinymist", width: 25mm) \ #text(size: 0.85em)[Tinymist(VS Code)]]),
  caption: [参考リンク],
) <fig-qr>

= おわりに
筆者も実験レポートをpLaTeXからLuaLaTeXへ移し，現在はTypstで書いている。本書もTypstで作成した。

筆者がTypstを使い始めたのは2025年10月で，当時のバージョンは0.13.1だった。それから1年で，0.14ではタグ付きPDFやPDFの画像としての読み込み，文字単位の両端揃えが，0.15では可変フォントへの対応や和欧文間の間隔の修正などが加わった。Typstは今も発展を続けている。使う人が増えれば，不具合の報告やパッケージ，日本語の情報も増え，さらに使いやすくなる。

Typstはすべてを覚えてから使い始める必要はない。`=` で見出し，`$` で数式が書けることを知っていれば，レポートの骨組みは書ける。分からない点は書きながら公式ドキュメントで調べれば足りる。

まずは typst.app で，次の実験レポートの「目的」だけでも書いてみてほしい。入力に合わせてプレビューが更新される感覚は，実際に触れると分かりやすい。合わなければ，従来の道具に戻ればよい。それも一つの比較の結果である。
