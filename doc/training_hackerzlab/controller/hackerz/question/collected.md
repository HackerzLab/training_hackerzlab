# NAME

training_hackerzlab/controller/hackerz/question/collected - TrainingHackerzlab

# SYNOPSIS

## URL

- GET - `/hackerz/question/collected/:id` - index - 各問題集をとく画面
- GET - `/hackerz/question/collected/:collected_id/:sort_id/think` - think - 問題集からの各問題画面

# DESCRIPTION

## - GET - `/hackerz/question/collected/:id` - show - 各問題集をとく画面

```
ログイン後のメニュー画面 (/hackerz/menu)
問題集 -> クリック
    ユーザーID, 名前
    問題はこっちだ (ボタン) -> 各問題画面
    得点確認 (ボタン) -> 解答結果画面
    パスコード入力フォーム (問題集ごとにパスコードが設定)
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

- `lib/TrainingHackerzlab/Controller/Hackerz/Question/Collected.pm` -
- `lib/TrainingHackerzlab/Model/Hackerz/Question/Collected.pm` -
- `templates/hackerz/question/collected/index.html.ep` -
- `t/training_hackerzlab/controller/hackerz/question/collected.t` -
