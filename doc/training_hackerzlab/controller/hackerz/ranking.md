# NAME

training_hackerzlab/controller/hackerz/ranking - TrainingHackerzlab ランキング

# SYNOPSIS

## URL

- GET - `/hackerz/ranking` - index - 総合ランキング (ログイン中)

# DESCRIPTION

## - GET - `/hackerz/ranking` - index - 総合ランキング (ログイン中)

```
総合ランキング画面
    ランキング順位、ログインID
    現在の得点
    トップページボタン -> トップページ
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

- `lib/TrainingHackerzlab/Controller/Hackerz/Ranking.pm` -
- `lib/TrainingHackerzlab/Model/Hackerz/Ranking.pm` -
- `templates/hackerz/ranking/index.html.ep` -
- `t/training_hackerzlab/controller/hackerz/ranking.t` -
