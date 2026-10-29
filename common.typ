#import "@preview/codelst:2.0.2": sourcecode

// Typstのすゝめ: A0ポスター共通スタイル(白黒・レポート調)
// 体裁は学科の「実験報告書の書き方」に倣う: 表の見出しは表の上・図の見出しは図の下，
// 三線表，式番号，行番号付きソースコード，[n]形式の参考文献など。
#let ink = black
#let tint = luma(238)
// 和文フォント: 原ノ味がなければ Noto CJK を使う
#let mincho = ("Harano Aji Mincho", "Noto Serif CJK JP")
#let gothic = ("Harano Aji Gothic", "Noto Sans CJK JP")
#let access-date = "2026年10月25日"

// 三線表(最上部は二重線)。自作関数 ftab に，列幅・配置の指定を足したもの
#let ftab(capt, header, cells, sup: "表", columns: auto, align: auto) = {
  [#figure(
    caption: capt,
    supplement: sup,
    table(
      columns: if columns == auto { header.len() } else { columns },
      align: align,
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
}

// 参考文献: 本文中で初めて引用された順に通し番号を振る
#let _cited = state("cited", ())
#let _refdb = state("refdb", (:))

#let c(..keys) = {
  let ks = keys.pos()
  for k in ks { _cited.update(a => if k in a { a } else { a + (k,) }) }
  context {
    let a = _cited.get()
    // 番号は昇順に並べ，3つ以上連続するときは [7-10] のようにまとめる
    let nums = ks.map(k => a.position(x => x == k) + 1).dedup().sorted()
    let parts = ()
    let i = 0
    while i < nums.len() {
      let j = i
      while j + 1 < nums.len() and nums.at(j + 1) == nums.at(j) + 1 { j += 1 }
      if j - i >= 2 { parts.push(str(nums.at(i)) + "-" + str(nums.at(j))) } else {
        for n in nums.slice(i, j + 1) { parts.push(str(n)) }
      }
      i = j + 1
    }
    super(text(size: 1em, "[" + parts.join(",") + "]"))
  }
}

#let refs() = context {
  let db = _refdb.get()
  for (i, k) in _cited.final().enumerate() {
    par(hanging-indent: 2.2em, first-line-indent: 0pt)[\[#(i + 1)\] #db.at(k) (閲覧日 #access-date)]
  }
}

// TeX / LaTeX のロゴ(E を下げ，A を上げて小さくする)
// 詰め量は明朝では metalogo パッケージ(swank-tex)の値．ゴシックでは字が重なるので緩める
#let _sans() = lower(text.font.first()) in gothic.map(lower)
#let TeX = context {
  let (te, ex) = if _sans() { (-0.14em, -0.1em) } else { (-0.165em, -0.122em) }
  box[T#h(te)#text(baseline: 0.22em)[E]#h(ex)X]
}
#let LaTeX = context {
  let (la, a, at) = if _sans() { (-0.28em, (0.72em, -0.22em), -0.02em) } else { (-0.361em, (0.7em, -0.178em), -0.147em) }
  box[L#h(la)#text(size: a.at(0), baseline: a.at(1))[A]#h(at)#TeX]
}
#let _logo(it) = {
  let t = it.text
  if t == "LaTeX" { LaTeX } else if t == "LuaLaTeX" { box[Lua#LaTeX] } else if t == "pLaTeX" { box[p#LaTeX] } else { TeX }
}

// 本文の大きさ size を基準にした共通の書式(ポスターと入門書で共有する)
#let _base(size, body) = {
  let r(x) = x / 28pt * size // ポスター(本文 28pt)で決めた大きさを本文に対する比にする
  set text(font: mincho, size: size, fill: ink, lang: "ja", cjk-latin-spacing: auto)
  set par(leading: 0.85em, spacing: 0.85em, justify: true, first-line-indent: (amount: 1em, all: true))
  set raw(theme: "susume.tmTheme")
  show raw: set text(font: ("DejaVu Sans Mono", "Noto Sans Mono CJK JP"))
  // 色分けの太字(#let などのキーワード)は strong で付くので，下の「太字はゴシック」の規則から外す
  show raw: it => { show strong: set text(font: ("DejaVu Sans Mono", "Noto Sans Mono CJK JP")); it }
  // raw は既定で 0.8em に縮むので，文中のコードは本文の約0.9倍になるよう戻す
  show raw.where(block: false): set text(size: 1.1em)
  show math.equation: set text(font: ("New Computer Modern Math", ..mincho))
  set math.equation(numbering: "(1)")
  // 式の引用は「式(1)」の形にする(本文側で「式」と書くので，番号だけを括弧付きで出す)
  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation {
      link(el.location(), numbering("(1)", ..counter(math.equation).at(el.location())))
    } else { it }
  }
  // 三線表: 最上部は太線，見出し行の下とその他は細線
  set table(inset: r(10pt), stroke: none)
  show table: set text(size: r(26pt))
  show table: set par(justify: false)
  // 表の中のコードは少し小さくし，コマンドの途中で改行しない
  show table: it => { show raw.where(block: false): r => box(text(size: 0.95em, r)); it }
  // 表の見出しは表の上，図の見出しは図の下
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: set text(size: r(26pt))
  // 脚注: 番号の前では改行しない。本文より小さくし，段落の字下げは付けない
  show footnote: it => { sym.wj; it }
  show footnote.entry: set text(size: r(22pt))
  show footnote.entry: set par(first-line-indent: 0pt, leading: 0.6em)
  set footnote.entry(gap: 0.5em, separator: line(length: 30%, stroke: r(0.8pt) + ink))
  set figure.caption(separator: h(1em))
  set heading(numbering: "1.")
  show heading: set text(font: gothic, weight: "bold")
  show strong: set text(font: gothic)

  // 和文と半角の括弧が接するところに四分アキを入れる(例: テンプレート (jarticle) が)
  show regex("[\p{Han}\p{Hiragana}\p{Katakana}ー々]\(|\)[\p{Han}\p{Hiragana}\p{Katakana}ー々]"): it => {
    let cs = it.text.clusters()
    let gap = h(0.25em, weak: true)
    if cs.first() == ")" { ")" + gap + cs.last() } else { cs.first() + gap + "(" }
  }
  // 文中の TeX 系の名前をロゴにする(BibTeX・LuaHBTeX はそのまま)
  show regex("BibTeX|LuaHBTeX|LuaLaTeX|pLaTeX|LaTeX|TeX"): it => if it.text in ("BibTeX", "LuaHBTeX") { it } else { _logo(it) }
  body
}

#let poster(title, subtitle: none, bib: (:), closing: none, body) = {
  set page(width: 841mm, height: 1189mm, margin: (x: 45mm, y: 32mm), fill: white, columns: 2,
    numbering: "1",
    background: context {
      let y0 = 32mm + if counter(page).get().first() == 1 { if subtitle == none { 160pt } else { 210pt } } else { 0pt }
      place(top + left, dx: 50%, dy: y0, line(angle: 90deg, length: page.height - 32mm - y0, stroke: 0.8pt + ink))
    },
    // 2枚目以降は別の紙として貼るので，上部に表題と枚数を出す
    header: context if counter(page).get().first() > 1 {
      text(size: 24pt, font: gothic, weight: "bold")[#title #h(1fr) #counter(page).display("1/1", both: true)]
    },
    footer: context align(center, text(size: 20pt, counter(page).display("1/1", both: true))))
  set columns(gutter: 50pt)
  show: _base.with(28pt)
  show heading.where(level: 1): it => block(above: 1.6em, below: 0.7em, width: 100%, text(size: 40pt, it))
  _refdb.update(bib)
  place(top + center, scope: "parent", float: true, clearance: 60pt, {
    box(height: 100pt, text(size: 80pt, font: gothic, weight: "bold", title))
    if subtitle != none { v(10pt, weak: true); align(center, text(size: 32pt, subtitle)) }
  })
  body
  heading(numbering: none)[参考文献]
  {
    set text(size: 22pt)
    refs()
  }
  // 末尾(最後の段の下)に置く補足
  if closing != none { v(1fr); closing }
}

// A4 の入門書: 学科の「実験報告書の書き方」の様式に従う
// (A4縦・1段，本文は明朝 10.5pt，見出しはゴシック，ページ番号は下部中央，章ごとに番号，参考文献は番号なし，
//  図・表は本文の上部または下部に置く)
#let guide(title, subtitle: none, author: none, bib: (:), body) = {
  set page(paper: "a4", margin: (x: 25mm, top: 25mm, bottom: 25mm), numbering: "1", number-align: center + bottom)
  show: _base.with(10.5pt)
  // 章は「1.」，節は「1.1」
  set heading(numbering: (..n) => numbering(if n.pos().len() == 1 { "1." } else { "1.1" }, ..n))
  // A4 では既定の 0.8em だとコード例が小さすぎるので，本文に近い大きさにする
  show raw.where(block: true): set text(size: 1.1em)
  show heading.where(level: 1): it => block(above: 1.8em, below: 0.9em, width: 100%, text(size: 13pt, it))
  show heading.where(level: 2): it => block(above: 1.4em, below: 0.8em, width: 100%, text(size: 11pt, it))
  set figure(placement: auto)
  _refdb.update(bib)
  align(center, {
    text(size: 20pt, font: gothic, weight: "bold", title)
    if subtitle != none { v(0.6em, weak: true); text(size: 12pt, font: gothic, subtitle) }
    if author != none { v(1.2em, weak: true); text(size: 11pt, author) }
  })
  v(1.5em)
  body
  heading(numbering: none)[参考文献]
  {
    set text(size: 9.5pt)
    refs()
  }
}

#let note(title: none, body) = block(width: 100%, stroke: 1.2em / 28 + ink, radius: 10em / 28, inset: 18em / 28, breakable: false)[
  #if title != none { text(font: gothic, weight: "bold")[(#title)]; linebreak() }
  #body
]

// ソースコードを行番号付きの枠で囲み，図として載せる(codelst パッケージ)
// height を指定すると枠の高さをそろえる(左右に並べるとき用)
// 端末の出力のようにソースコードでないものは，numbers: false で行番号を付けない
#let codefig(code, caption, lab, lang: "typ", placement: none, height: auto, numbers: true) = {
  let frame = b => block(fill: luma(250), stroke: .6pt + luma(200), inset: (x: .45em, y: .65em),
    radius: 3pt, width: 100%, height: height, b)
  [#figure(
    text(size: 24em / 28, sourcecode(frame: frame, numbering: if numbers { "1" } else { none }, raw(code, lang: lang, block: true))),
    caption: caption, kind: image, supplement: [図], placement: placement,
  )#label(lab)]
}

// ソースと組版結果を並べて見せる例
// 大きさは本文(ポスターでは 28pt)に対する比で決める
// 結果の側の図表は枠の中に置くので，浮動させない
#let demo(title, code) = block(width: 100%, stroke: 1.2em / 28 + ink, radius: 10em / 28, inset: 16em / 28, breakable: false)[
  #text(font: gothic, size: 26em / 28)[(#title)]
  #v(6em / 28)
  #grid(
    columns: (1fr, 1fr), column-gutter: 14em / 28,
    block(width: 100%, fill: tint, inset: 14em / 28, text(size: 26em / 28, { set par(leading: 0.5em, spacing: 0.5em, first-line-indent: 0pt); raw(code, lang: "typ", block: true) })),
    block(width: 100%, stroke: 0.8em / 28 + ink, inset: 14em / 28, text(size: 1em, { set figure(placement: none); eval(code, mode: "markup", scope: (ftab: ftab)) })),
  )
]

