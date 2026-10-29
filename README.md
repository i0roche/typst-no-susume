# Typstのすゝめ

実験レポートの作成ツールとして Typst を紹介する、学園祭展示用のポスター(A0 で2枚)のソースです。
ポスター自体を実験レポートの体裁(三線表、表と図の見出し、通し番号の参考文献)で組んでいます。

完成品は [`susume.pdf`](susume.pdf) です。ポスターに入りきらなかった内容(LaTeX との比較、コンパイル時間の測定、関数や参考文献の書き方など)を A4 にまとめた入門書 [`guide.pdf`](guide.pdf) もあります(学科の「実験報告書(レポート)の書き方」の様式に合わせています)。

## ファイル

| ファイル | 内容 |
|---|---|
| `susume.typ` | ポスターの本文 |
| `guide.typ` | A4 の入門書の本文 |
| `common.typ` | 書式をまとめたファイル(ポスター用の `poster` と入門書用の `guide`、三線表の関数 `ftab`、参考文献、コード図など) |
| `example/` | ポスターの9章で使う実験レポートの見本(`report.typ`，測定データ `data.csv`，組んだ `report.pdf`) |
| `susume.tmTheme` | コードの色分けのテーマ |
| `tools/bench/` | コンパイル時間の測定に使ったスクリプト |
| `tools/tile.typ` | 試し刷り用。`susume.pdf` を原寸で A4 に分割する(`typst compile --root . tools/tile.typ`。`--input mode=shrink` で A4 に縮小，`--input pages=3` でポスターの枚数を指定) |

## Typst の導入

Typst は、Webアプリ、コマンドラインツール、VS Code の3通りで使えます。迷ったときは、インストール不要の Webアプリから始めるのがよいです。

### Webアプリ

[typst.app](https://typst.app/) でアカウントを作ります。インストール不要で、プレビュー付きのエディタが使えます。学校のパソコンのようにソフトを入れられない環境では、これで足ります。

### Windows

```powershell
winget install --id Typst.Typst
```

### Mac

```sh
brew install typst
```

### Linux

```sh
# Arch Linux
sudo pacman -S typst

# Ubuntu など(snap)
sudo snap install typst
```

Ubuntu と Debian の apt には typst のパッケージがありません。snap 版は開発元の Typst GmbH が公開しています。

### そのほかの方法

- [GitHub の Releases](https://github.com/typst/typst/releases) から実行ファイルを入手し、パスの通った場所に置く(パッケージ管理を使わない方法)
- Rust の `cargo` で入れる(どの環境でも使えるが、ビルドに時間がかかる)

```sh
cargo install --locked typst-cli
```

### VS Code

拡張機能 [Tinymist Typst](https://github.com/Myriad-Dreamin/tinymist) を入れると、ソースの横でプレビューできます。拡張機能の画面で Tinymist Typst を検索するか、次のコマンドで入れます。

```sh
code --install-extension myriad-dreamin.tinymist
```

Tinymist のプレビューは PDF ではなく独自に描画した画面なので、提出前には出力した PDF を PDF ビューアで開いて確かめてください。スペルチェックの機能もありません。

### 確認

```sh
typst --version
```

バージョンが表示されれば導入できています。パッケージは使うときに自動でダウンロードされるので、事前の準備は要りません。

### よく使うコマンド

```sh
typst compile report.typ   # PDF を1回作る
typst watch report.typ     # 保存のたびに自動で作り直す
typst fonts                # 使えるフォントの一覧(日本語フォントの名前を調べるとき)
```

VS Code で Tinymist のプレビューを開いておけば、`typst watch` と同じように、入力に合わせて更新されます。

## ビルド

Typst 0.15.1 で作成しています。

### 1. 日本語フォントを入れる

和文には原ノ味フォントを使っています。原ノ味がなければ Noto CJK を代わりに使うので、どちらか一方が入っていれば組めます。

- Noto CJK だけの場合: 「unknown font family: harano aji …」という警告が出ますが、そのまま組めます。
- どちらも入っていない場合: 警告が出たうえで、和文が表示されません(コンパイル自体は通ります)。

```sh
# Mac(原ノ味)
brew install --cask font-harano-aji

# Arch Linux(Noto CJK)
sudo pacman -S noto-fonts-cjk

# Ubuntu など(Noto CJK)
sudo apt install fonts-noto-cjk
```

Windows では、[原ノ味フォントのリポジトリ](https://github.com/trueroad/HaranoAjiFonts)の [Tags](https://github.com/trueroad/HaranoAjiFonts/tags) から最新版の zip を入手し、展開した `.otf` ファイルを右クリックして「インストール」を選びます。

入ったかどうかは、Typst が見つけたフォントの一覧で確かめます。

```sh
typst fonts | grep -i -e harano -e "noto.*cjk"   # Windows では typst fonts の一覧から目で探す
```

コードの等幅フォント(DejaVu Sans Mono)は Typst に内蔵されているので、入れる必要はありません。

### 2. コンパイルする

```sh
typst compile example/report.typ   # 見本のレポート(ポスターが読み込む。見本を変えたときだけ作り直す)
typst compile susume.typ    # susume.pdf を作る
typst compile guide.typ     # guide.pdf(A4 の入門書)を作る
typst watch susume.typ      # 保存のたびに自動で作り直す(編集しながら確かめるとき)
```

`@preview` のパッケージ(codelst, tiaoma, cjk-unbreak, zap, lilaq)は、初回のコンパイル時に自動でダウンロードされます。

## 実験レポートへの流用

`common.typ` の `ftab`(三線表)、`c()` と `refs()`(引用順の通し番号の参考文献)、`codefig`(行番号付きのコード図)は、ポスター以外の文書でも使えます。
`poster` 関数は A0 用です。A4 の文書には、入門書が使っている `guide` 関数を使えます。

## コンパイル時間の測定

入門書(`guide.pdf`)の表1の測定は、`tools/bench/` のスクリプトで行いました。Typst のほかに TeX Live(pLaTeX、LuaLaTeX、latexmk)が必要です。

```sh
cd tools/bench
python3 gen.py 12    # 12章の文書を Typst・pLaTeX・LuaLaTeX 用に作る(図の画像がなければダミーを作る)
python3 measure.py   # 各エンジンのコンパイル時間を測る
```

## ライセンス

[MIT License](LICENSE)
