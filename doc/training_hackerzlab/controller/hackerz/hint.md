# NAME

training_hackerzlab/controller/hackerz/hint - TrainingHackerzlab

# SYNOPSIS

## URL

- POST - `/hackerz/hint/opened` - opened - ヒント開封履歴記録

# DESCRIPTION

## - POST - `/hackerz/hint/opened` - opened - ヒント開封履歴記録

```
- GET - `/hackerz/question/collected/:collected_id/:sort_id/think` - think - 問題集からの各問題画面
の下部に現れる、ヒントの回覧履歴の記録機能
[ヒント] タブをクリック(回覧)するたびに開封記録 hint_opened テーブルに記録
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

- `lib/TrainingHackerzlab/Controller/Hackerz/Hint.pm` -
- `lib/TrainingHackerzlab/Model/Hackerz/Hint.pm` -
- `templates/hackerz/hint/index.html.ep` -
- `t/training_hackerzlab/controller/hackerz/hint.t` -
