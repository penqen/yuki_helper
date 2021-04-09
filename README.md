# Yukicoder Helper

Yukicoder のテストケースダウンロードやローカルでテストケース実行などを行う`Elixir`用のヘルパーです。
yukicoder API を利用しています。

## コマンド

```
# 設定内容を表示する。
mix yuki.config

# 指定された問題のテストケース一覧を表示する。
mix yuki.testcase --no 10

# 指定された問題のテストケースをダウンロードする。
mix yuki.download --no 10
```

## 設定ファイル

下記の順に読み込みを行い、同じ設定は上書きされる。

1. `~/.yukihelper.config.yml`
2. `~/.config/yukihelper/.config.yml`
3. `./yuki_helper.config.yml`

設定例

```./yuki_helper.config.yml
testcase:
  aggregation: null     # 数値を設定する。 テストケースをその数値でサブディレクトリ化する。
  directory: "testcase" # テストケースを保存するディレクトリ名を設定する。
  prefix: "p"           # ある問題のテストケースを入れるディレクトリの接頭辞を指定する。
yukicoder:
  access_token: null    # yukicoderのAPIアクセストークンを設定する。
```

## Roadmap

- [x] テストケースのダウンロード
- [ ] テストケースをDoctest用に変換
- [ ] テストケースの実行
  - [x] CE
  - [x] AC/WA/RE
  - [ ] TLE/MLE/OLE/QLE
- [ ] 通信エラー系の処理対応
