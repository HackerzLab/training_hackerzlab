# NAME

training_hackerzlab/controller/hackerz/answer - TrainingHackerzlab 解答

# SYNOPSIS

## URL

- GET - `/hackerz/answer/report` - report - 成績一覧画面
- GET - `/hackerz/answer/:id/result` - result - 解答を送信したぞ画面
- POST - `/hackerz/answer` - store - 解答内容送信

# DESCRIPTION

## - GET - `/hackerz/answer/report` - report - 成績一覧画面

```
問題集ごとに表示
テーブル表示項目
問題ごとに、正解、不正解、問題、入力解答、ヒント開封履歴、獲得点数
問題集ごとに、問題集の情報、合計点
```

## - GET - `/hackerz/answer/:id/result` - result - 解答を送信したぞ画面

- params:
    - question
    - question_list

```
解答を送信したぞ画面
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
        -> 解答を送信したぞ画面へ遷移
```

# TODO

# SEE ALSO

- `lib/TrainingHackerzlab/Controller/Hackerz/Answer.pm` -
- `lib/TrainingHackerzlab/Model/Hackerz/Answer.pm` -
- `templates/hackerz/answer/index.html.ep` -
- `t/training_hackerzlab/controller/hackerz/answer.t` -
