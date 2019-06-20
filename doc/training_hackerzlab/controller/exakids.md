# NAME

training_hackerzlab/controller/exakids - TrainingHackerzlab エクサキッズ仕様

# SYNOPSIS

## URL

- GET - `/exakids` - index - エントリー画面
- GET - `/exakids/menu` - menu - メニュー
- GET - `/exakids/ranking` - ranking - 解答者ランキング一覧
- GET - `/exakids/:user_id/entry` - entry 解答者のエントリー画面
- POST - `/exakids/:user_id/update` - update 解答者のエントリー実行
- POST - `/exakids/refresh` - refresh - 解答状況を初期状態にもどす

# DESCRIPTION

## 共通事項

```
エントリー画面以外はログイン中のみ表示
exakids エントリーから遷移してきた問題には全てタイマー機能が表示
解答登録実行時には実行までにかかった時間を登録する機能
```

追加テーブルについて

```sql
DROP TABLE IF EXISTS answer_time;
CREATE TABLE answer_time (                              -- 入力された時間
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    answer_id       INTEGER,                            -- 入力された解答ID (例: 5)
    elapsed_sec     INTEGER,                            -- 経過時間 (例: 600) 秒で入力
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
```

# - GET - `/exakids` - index - エントリー一覧画面

```
アプリのトップ画面から遷移してくる
解答者のエントリーボタン
閲覧者のエントリーボタン
リンク(トップ画面)
```

# - GET - `/exakids/menu` - menu - メニュー

```
解答状況をリフレッシュするリンクボタン(閲覧者ログインのみ出現)
画面をリロードするリンクボタン
解答者ランキング一覧へのリンクボタン
解答者12人分の解答状況一覧
```

# - GET - `/exakids/ranking` - ranking - 解答者ランキング一覧

```
ランキング画面
得点の合計と解答入力までの時間の組み合わせで順位を決定
点数が同じ場合は時間が短い方が勝ち
```

# - GET - `/exakids/:user_id/entry` - entry 解答者のエントリー画面

```
エントリーに必要なフォーム一式
リンク(解答状況一覧画面)
```

# - POST - `/exakids/:user_id/update` - update 解答者のエントリー実行

```
エントリー情報の更新実行
実行 -> 失敗(実行せず解答状況一覧画面に戻る)
実行 -> 成功(実行して解答状況一覧画面に遷移)
```

# - POST - `/exakids/refresh` - refresh - 解答状況を初期状態にもどす

```
点数、ユーザーの登録情報などを初期状態にする
実行 -> 失敗(実行せず解答状況一覧画面に戻る)
実行 -> 成功(実行して解答状況一覧画面に遷移)
```

# TODO

```
- GET - `/example/create` - create
- GET - `/example/search` - search
- GET - `/example` - index
- GET - `/example/:id/edit` - edit
- GET - `/example/:id` - show
- POST - `/example` - store
- POST - `/example/:id/update` - update
- POST - `/example/:id/remove` - remove
```

# SEE ALSO

- `lib/TrainingHackerzlab/Controller/Exakids.pm` -
- `lib/TrainingHackerzlab/Model/Exakids.pm` -
- `templates/exakids/index.html.ep` -
- `t/training_hackerzlab/controller/exakids.t` -
