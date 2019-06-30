# NAME

training_hackerzlab/controller/exakids - TrainingHackerzlab エクサキッズ仕様

# SYNOPSIS

## URL

- GET - `/exakids` - index - エントリー画面
- GET - `/exakids/menu` - menu - メニュー
- GET - `/exakids/ranking` - ranking - 解答者ランキング一覧
- GET - `/exakids/:user_id/edit` - edit - 解答者のエントリー情報更新画面
- POST - `/exakids/:user_id/update` - update - 解答者のエントリー情報更新画面
- POST - `/exakids/entry` - entry 解答者のエントリー実行
- POST - `/exakids/refresh` - refresh - 解答状況を初期状態にもどす
- POST - `/hackerz/question/opened` - opened - 問題の開封履歴記録

# DESCRIPTION

## 共通事項

```
エントリー画面以外はログイン中のみ表示
exakids エントリーから遷移してきた問題には
タイマー機能もしくは解答時間タイムスタンプ機能
解答登録実行時には実行までにかかった時間を登録
もしくは解答時間を記録する機能
```

- 問題解答、制限時間付きクイズ形式
    - entry1 ~ entry12
    - browse1 ~ browse3
- 問題解答、早押し正解者のみ得点クイズ形式
    - entrysp1 ~ entrysp12
    - browsesp1 ~ browsesp3

__追加機能__

ログインしている人の権限に応じて表示する問題の画面を使い分ける

閲覧者ログイン

```
問題画面
    問題を開くボタン
    問題を開くボタンを押すと問題が開示されて開示時間が記録される
    一度問題を開くと二度と開くの動きはできない
    問題画面をリロードすると早く回答した人順に解答履歴が画面表示
```

解答者ログイン

```
問題画面
    解答を入力するフォームのみ出現
    解答入力を実行すると入力時間が記録される
    一番早く解答した人だけ得点に加算される
    正解しても自分より早く正解者がいれば得点は加算されない
```

__追加DB__

```sql
DROP TABLE IF EXISTS question_opened;
CREATE TABLE question_opened (                          -- 問題の開封履歴
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    user_id         INTEGER,                            -- ユーザーID (例: 5)
    question_id     INTEGER,                            -- 問題ID (例: 5)
    collected_id    INTEGER,                            -- 問題集ID (例: 5)
    opened          INTEGER,                            -- 開封記録 (例: 0: 開封していない, 1: 開封済み )
    opened_ts       TEXT,                               -- 開封日時 (例: '2016-01-08 12:24:12')
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
-- テーブルを変更
DROP TABLE IF EXISTS answer_time;
CREATE TABLE answer_time (                              -- 入力された時間
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    answer_id       INTEGER,                            -- 入力された解答ID (例: 5)
    remaining_sec   INTEGER,                            -- 残り時間 (例: 600) 秒で入力
    entered_ts      TEXT,                               -- 入力した日時 (例: '2016-01-08 12:24:12')
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
```

# - POST - `/hackerz/question/opened` - opened - 問題の開封履歴記録

```
- GET - `/hackerz/question/collected/:collected_id/:sort_id/think` - think - 問題集からの各問題画面
の下部に現れる、問題の開封履歴の記録機能
閲覧者ログインのときに現れる
[問題をオープン] ボタンをクリックすると開封記録 question_opened テーブルに記録
一度オープンした問題はもう一度オープンはできない
```

# - GET - `/exakids` - index - エントリー画面

```
アプリのトップ画面から遷移してくる
解答者と閲覧者のエントリー入力フォーム
リンク(トップ画面)
```

# - GET - `/exakids/menu` - menu - メニュー

```
解答状況をリフレッシュするリンクボタン(閲覧者ログインのみ出現)
画面をリロードするリンクボタン
解答者ランキング一覧へのリンクボタン
プロフィールリンクボタン
解答者12人分の解答状況一覧
```

# - GET - `/exakids/ranking` - ranking - 解答者ランキング一覧

```
ランキング画面
得点の合計と解答入力までの時間の組み合わせで順位を決定
点数が同じ場合は時間が短い方が勝ち
```

# - GET - `/exakids/:user_id/edit` - edit - 解答者のエントリー情報更新画面

```
エントリー者の情報更新の入力フォーム一式
```

# - POST - `/exakids/:user_id/update` - update - 解答者のエントリー情報更新画面

```
エントリー情報の更新実行
実行 -> 失敗(実行せずエントリー情報更新画面に戻る)
実行 -> 成功(実行してエントリー画面に遷移)
```

# - POST - `/exakids/entry` - entry 解答者のエントリー実行

```
エントリーの実行
実行 -> 失敗(実行せずエントリー画面に戻る)
実行 -> 成功(実行してエントリー画面に遷移)
```

# - POST - `/exakids/refresh` - refresh - 解答状況を初期状態にもどす

```
点数、ユーザーの登録情報などを初期状態にする
実行 -> 失敗(実行せずエントリー画面に戻る)
実行 -> 成功(実行してログアウト後、アプリトップ画面に遷移)
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
