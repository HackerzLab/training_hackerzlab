# NAME

training_hackerzlab/controller/hackerz/menu - TrainingHackerzlab アプリメニュー

# SYNOPSIS

## URL

- GET - `/hackerz/menu` - index - トップページ画面 (ログイン中)

# DESCRIPTION

## - GET - `/hackerz/menu` - index - トップページ画面 (ログイン中)

```
トップページ (ログイン中)
    サイトタイトル
    サイト説明文
    各問題集ボタン -> 各問題集の問題を始める画面
    総合ランキングボタン -> 総合ランキング画面
    成績一覧ボタン -> 解答一覧含む獲得点数
    ログアウトボタン -> ログアウトしてトップページ
    登録情報削除ボタン -> ログイン中のユーザー情報削除
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
