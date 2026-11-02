#import "@preview/zap:0.6.0"
#import "@preview/lilaq:0.6.0" as lq
#set page(paper: "a4")
#set text(font: "Harano Aji Mincho", lang: "ja")
#set par(first-line-indent: (amount: 1em, all: true))
#set heading(numbering: "1.")
#show heading: set text(font: "Harano Aji Gothic")
#set math.equation(numbering: "(1)", supplement: none)
#set figure.caption(separator: h(1em))
#show figure.where(kind: table): set figure.caption(position: top)

= 目的
RLC直列回路の共振周波数を測定し，理論値と比較する。

= 原理
RLC直列回路の共振周波数 $f_0$ は，次式で表される。
$ f_0 = 1 / (2 pi sqrt(L C)) $ <eq-res>
ここで，$L$ はインダクタンス，$C$ は静電容量である。

= 実験方法
@fig-circuit の回路($C = 0.1 space mu"F"$)で，発振器の周波数を変えながら，抵抗の両端の電圧を測定した。

#figure(
  zap.circuit({
    import zap: *
    acvsource("v", (0, 0), (0, 3), label: "発振器")
    resistor("r", (0, 3), (3, 3), label: $R$)
    inductor("l", (3, 3), (6, 3), label: $L$)
    capacitor("c", (6, 3), (6, 0), label: $C$)
    wire((6, 0), (0, 0))
  }),
  caption: [測定回路],
) <fig-circuit>

= 実験結果
共振周波数の測定値と，式(@eq-res)による理論値を@tab-result に示す。

#figure(
  table(
    columns: 3,
    stroke: none,
    table.hline(),
    [$L$ [mH]], [理論値 [kHz]], [測定値 [kHz]],
    table.hline(stroke: 0.5pt),
    [10], [5.03], [4.98],
    [20], [3.56], [3.52],
    table.hline(),
  ),
  caption: [共振周波数],
) <tab-result>

$L = 10 "mH"$ のときの，抵抗の両端の電圧の周波数特性を@fig-graph に示す。

#let data = csv("data.csv").slice(1).map(r => r.map(float))
#figure(
  lq.diagram(
    width: 8cm, height: 5cm,
    xlabel: [$f$ [kHz]], ylabel: [$V_R$ [V]],
    lq.plot(data.map(r => r.at(0)), data.map(r => r.at(1)),
      mark: "o", stroke: none, color: black),
  ),
  caption: [抵抗の両端の電圧の周波数特性],
) <fig-graph>
