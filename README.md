# Yukicoder Helper

主に、自分用のコマンド群です。  
Elixir専用？  
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
  aggregation: null
  directory: "testcase"
  prefix: "p"
yukicoder:
  access_token: null
```

## Roadmap

- [x] テストケースのダウンロード
- [ ] テストケースをDoctest用に変換
- [ ] テストケースの実行
  - [ ] AC/WA/RE/CE
  - [ ] TLE/MLE/OLE/QLE
