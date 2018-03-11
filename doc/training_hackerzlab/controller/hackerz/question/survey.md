# NAME

training_hackerzlab/controller/hackerz/question/survey - TrainingHackerzlab

# SYNOPSIS

## URL

- GET - `/hackerz/question/collected/:collected_id/:sort_id/survey/cracking` - cracking - クラッキングページ
- POST - `/hackerz/question/collected/:collected_id/:sort_id/survey/cracking` - cracking - クラッキングページ (解答)

# DESCRIPTION

## - GET - `/hackerz/question/collected/:collected_id/:sort_id/survey/cracking` - cracking - クラッキングページ
## - POST - `/hackerz/question/collected/:collected_id/:sort_id/survey/cracking` - cracking - クラッキングページ (解答)

```
第３問より
クラッキング問題
用意されたページにIDとパスワードが埋め込まれてる
埋め込まれた文字を発見し入力フォームに入力して
解答の言葉を取得する
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

- `lib/TrainingHackerzlab/Controller/Hackerz/Question/Survey.pm` -
- `lib/TrainingHackerzlab/Model/Hackerz/Question/Survey.pm` -
- `templates/hackerz/question/survey/index.html.ep` -
- `t/training_hackerzlab/controller/hackerz/question/survey.t` -
