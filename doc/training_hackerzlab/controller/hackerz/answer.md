# NAME

training_hackerzlab/controller/hackerz/answer - TrainingHackerzlab 解答

# SYNOPSIS

## URL

- GET - `/hackerz/answer/:id/list` - list - 解答一覧画面
- GET - `/hackerz/answer/:id/score` - score - 解答結果画面
- GET - `/hackerz/answer/:id/result` - result - 回答を送信したぞ画面
- POST - `/hackerz/answer` - store - 解答内容送信

# DESCRIPTION

## - GET - `/hackerz/answer/list` - list - 解答一覧画面

```
GET - `/hackerz/menu`
トップページ (ログイン中)
    自分の解答一覧ボタン -> 解答一覧画面

解答一覧画面
    解答した問題の答えのリスト
```

## - GET - `/hackerz/answer/:id/score` - score - 解答結果画面

```
問題を解く画面
    得点確認ボタン -> 解答結果画面

解答結果画面
    回答結果、ユーザーID表示
    現在の得点表示
```

## - GET - `/hackerz/answer/:id/result` - result - 回答を送信したぞ画面

- params:
    - question
    - question_list

```
回答を送信したぞ画面
    おまえの解答だ
    入力した解答
    正解 or 間違い
    第*問へ(次の問題ボタン) -> 次の問題画面
```

## - POST - `/hackerz/answer` - store - 解答内容送信

- params:
    - user_id
    - user_answer
    - question_id

```
各問題画面
    送信ボタン -> 入力値を送信
        -> 回答を送信したぞ画面へ遷移
```

# TODO

# SEE ALSO

- `lib/TrainingHackerzlab/Controller/Hackerz/Answer.pm` -
- `lib/TrainingHackerzlab/Model/Hackerz/Answer.pm` -
- `templates/hackerz/answer/index.html.ep` -
- `t/training_hackerzlab/controller/hackerz/answer.t` -
