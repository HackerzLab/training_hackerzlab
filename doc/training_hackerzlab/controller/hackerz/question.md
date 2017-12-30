# NAME

training_hackerzlab/controller/hackerz/question - TrainingHackerzlab

# SYNOPSIS

## URL

- GET - `/hackerz/question/:id/think` - think - 各問題画面

# DESCRIPTION

## - GET - `/hackerz/question/:id/think` - think - 各問題画面

```
各問題画面
    問題番号
    問題文
    得点
    難易度
    ヒント機能
        ヒント1(文面)
        ヒント2(文面)
        ヒント3(文面)
        ヒント4(文面)
        ヒント5(文面)
    解答を入力 (問題により変更)
        入力フォーム (テキスト)
        ラジオボタン
    送信ボタン -> 回答を送信したぞ画面(入力値を送信する)
    (問題により)
    ファイルをダウンロードボタン -> ファイルがダウンロードされる
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

- `lib/TrainingHackerzlab/Controller/Hackerz/Question.pm` -
- `lib/TrainingHackerzlab/Model/Hackerz/Question.pm` -
- `templates/hackerz/question/index.html.ep` -
- `t/training_hackerzlab/controller/hackerz/question.t` -
