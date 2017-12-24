# NAME

training_hackerzlab/controller/hackerz/menu - TrainingHackerzlab

# SYNOPSIS

## URL

- GET - `/hackerz/menu` - index - トップページ画面 (ログイン中)

# DESCRIPTION

## - GET - `/hackerz/menu` - index - トップページ画面 (ログイン中)

```
トップページ (ログイン中)
    サイトタイトル
    サイト説明文
    問題をとくボタン -> 問題を解く画面
    ログアウトボタン -> ログアウトしてトップページ
    問題一覧
    自分の回答一覧ボタン -> 解答一覧画面
    総合ランキングボタン -> 総合ランキング画面
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

- `lib/TrainingHackerzlab/Controller/Hackerz/Menu.pm` -
- `lib/TrainingHackerzlab/Model/Hackerz/Menu.pm` -
- `templates/hackerz/menu/index.html.ep` -
- `t/training_hackerzlab/controller/hackerz/menu.t` -
