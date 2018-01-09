# NAME

training_hackerzlab/controller/hackerz/hint - TrainingHackerzlab

# SYNOPSIS

## URL

- POST - `/hackerz/hint/opened` - store - ヒント開封履歴記録

# DESCRIPTION

## - POST - `/hackerz/hint/opened` - store - ヒント開封履歴記録

```
params:
    user_id:
    hint_id:
    opened:

ヒントを回覧したタイミングで hint_opened テーブルに記録
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
