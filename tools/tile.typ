// 試し刷り用: susume.pdf(A0)を A4 に分割する
// typst compile --root . tools/tile.typ                       # 原寸で分割(A0 1ページを A4 横 3×6 = 18枚)
// typst compile --root . tools/tile.typ --input mode=shrink   # A0 1ページを A4 1枚に縮小(1/4)
// ポスターの枚数が変わったら --input pages=3 のように指定する

#let src = "/susume.pdf"
#let n-pages = int(sys.inputs.at("pages", default: "2")) // ポスターの枚数
#let (W, H) = (841mm, 1189mm)
#let mode = sys.inputs.at("mode", default: "tile")

#set page(paper: "a4", flipped: mode == "tile", margin: 0pt)
#set text(size: 7pt, fill: luma(100), font: ("DejaVu Sans Mono", "Harano Aji Gothic", "Noto Sans CJK JP"))

#let shrink() = range(1, n-pages + 1).map(p => image(src, page: p, width: 100%, height: 100%))

#let tile() = {
  let (cols, rows) = (3, 6)
  let (cw, ch) = (W / cols, H / rows)
  let (mx, my) = ((297mm - cw) / 2, (210mm - ch) / 2)
  let s = .3pt + luma(100)
  // 切り取り線の位置を示すトンボ(セルの四隅から外向きに 4mm)
  let marks = for (x, y, sx, sy) in ((mx, my, -1, -1), (mx + cw, my, 1, -1), (mx, my + ch, -1, 1), (mx + cw, my + ch, 1, 1)) {
    place(line(start: (x + sx * 1mm, y), end: (x + sx * 5mm, y), stroke: s))
    place(line(start: (x, y + sy * 1mm), end: (x, y + sy * 5mm), stroke: s))
  }
  for p in range(1, n-pages + 1) {
    for r in range(rows) {
      for c in range(cols) {
        (
          {
            place(dx: mx, dy: my, box(width: cw, height: ch, clip: true,
              move(dx: -c * cw, dy: -r * ch, image(src, page: p, width: W, height: H))))
            marks
            place(dx: mx + 8mm, dy: 1.8mm,
              [#p/#n-pages ページ　#(r + 1) 段目 #(c + 1) 列目（#(r * cols + c + 1)/#(rows * cols)）])
          },
        )
      }
    }
  }
}

#(if mode == "shrink" { shrink() } else { tile() }).join(pagebreak())
