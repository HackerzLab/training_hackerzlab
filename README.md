# NAME

training_hackerzlab - ハッカーズラボクイズシステム

# SYNOPSIS

## URL

<http://training.hackerzlab.com> - 開発用サーバー

## LOCAL SETUP

お手元の開発環境設定

### INSTALL

環境構築、準備

#### git clone

お手元の PC に任意のディレクトリを準備後、 github サイトよりリポジトリを取得

<https://github.com/ykHakata/training_hackerzlab> - github

```
(例: ホームディレクト配下に github 用のディレクトリ作成)
$ mkdir ~/github

# github ディレクトリ配下に departure リポジトリ展開
$ cd ~/github
$ git clone git@github.com:ykHakata/training_hackerzlab.git
```

#### Perl install

```
(5.26.1 を使用)
$ cd ~/github/training_hackerzlab/
$ cat .perl-version
5.26.1
```

plenv を活用し、perl 5.26.1, cpnam, carton までのインストールを実行

手順の参考

<https://github.com/ykHakata/summary/blob/master/perl5_install.md> - perl5_install / perl5 ローカル環境での設定手順

#### Mojolicious install

Mojolicious を始めとする必要なモジュール一式のインストール実行

```
(cpanfile に必要なモジュール情報が記載)
$ cd ~/github/training_hackerzlab/
$ cat cpanfile
requires 'Mojolicious', '== 7.59';

(carton を使いインストール実行)
$ carton install
```

手順の参考

<https://github.com/ykHakata/summary/blob/master/mojo_setup.md> - mojo_setup - Mojolicious の基本的なセットアップ

## START APP

アプリケーションスタート

### お手元の PC

```
(WEBフレームワークを起動 development モード)
$ carton exec -- morbo script/training_hackerzlab

(終了時は control + c で終了)
```

コマンドラインで morbo サーバー実行後、web ブラウザ `http://localhost:3000/` で確認

### 開発サーバー

web サーバー nginx 通常はつねに稼働中、サーバーの起動は root 権限

```
(サーバースタート)
# nginx

(サーバーを停止)
# nginx -s quit
```

app サーバー hypnotoad

```
(production モード)
$ carton exec -- hypnotoad script/training_hackerzlab

(停止)
$ carton exec -- hypnotoad --stop script/training_hackerzlab
```

web ブラウザ <http://training.hackerzlab.com> で確認

## TEST

テストコードを実行

```
(テストコードを起動の際は mode を切り替え)
$ carton exec -- script/training_hackerzlab test --mode testing

(テスト結果を詳細に出力)
$ carton exec -- script/training_hackerzlab test -v --mode testing

(テスト結果を詳細かつ個別に出力)
$ carton exec -- script/training_hackerzlab test -v --mode testing t/training_hackerzlab.t

(自動で testing になるように設定している)
$ carton exec -- script/training_hackerzlab test -v t/training_hackerzlab.t
```

## DEPLOY

1. github -> ローカル環境へ pull (最新の状態にしておく)
1. ローカル環境 -> github へ push (修正を反映)
1. github -> vpsサーバーへ pull (vpsサーバーへ反映)
1. アプリケーション再起動

```
(ローカル環境から各自のアカウントでログイン)
$ ssh kusakabe@training.hackerzlab.com

(もしくは)
$ ssh kusakabe@160.16.231.20

(アプリケーションユーザーに)
$ sudo su - training

(移動後、git 更新)
$ cd ~/training_hackerzlab/
$ git pull origin master

(再起動)
$ carton exec -- hypnotoad script/training_hackerzlab
```

# DESCRIPTION

# TODO

```
旧システムのメモ
/hackerz/question
問題を解く画面
    ユーザーID表示
    名前表示
    問題を始めるボタン -> 第1問へ
    ログアウトボタン -> ログアウトしてトップページ
    得点確認ボタン -> 解答結果画面


パスワードクラッキングせよ画面?
    IDを入力
    パスワードを入力

このサイトをかいざんせよ画面?
    入力フォーム
    送信ボタン

wab api
    /api/question/list
    /api/question/create
    /api/question/deleteall
    /api/question/item
    /api/answer/deleteall
    /api/user/deleteall

問題編集画面(当初はなかった) ログイン後 /admin で直接
    問題追加ボタン
    問題を全て削除ボタン
    解答を全て削除ボタン
    ユーザーを全て削除ボタン
    各問題の項目一覧
        編集ボタン

問題のパターン
    問題文
    テキスト入力
    送信ボタン

    問題文
    答えを選択(4択、ラジオボタン)
    送信ボタン

    問題文
    ダウンロードボタン
    データーの中を調査
    テキスト入力
    送信ボタン

    pattern
        form(10) -> 問題文に対して入力フォームにテキスト入力で解答
        choice(20) -> 問題文に対して答えを4択から選択して解答
        survey(30) -> 調査するページから解答を導き出してテキスト入力で解答
        survey_and_file(31) -> survey, file, 組み合わせ
        explain(40) -> 問題とその詳細から解答と導き出してテキスト入力で解答
        file(50) -> 問題文とダウンロードファイルから解答を導き出してテキスト入力で解答

問題集を解くためのパスコード
過去問題のための「問題集」
CREATE TABLE question_collected (                       -- 問題集
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    title           TEXT,                               -- タイトル (例: '第１回 2016-01-31')
    description     TEXT,                               -- 問題集の説明 (例: '簡単なものから難しいものまで')
    passcode        TEXT,                               -- 問題集の解くための認証 (例: 'hackerz999')
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);

CREATE TABLE question_collect_ids (                             -- 問題集と問題の順番
    id                      INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    question_collected_id   INTEGER,                            -- 問題集ID (例 1)
    question_id             INTEGER,                            -- 問題ID (例: 1)
    collected_id            INTEGER,                            -- 問題集の中での問題の順番 (例: 1)
    deleted                 INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts              TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts             TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
sqlite バージョン
yk-MacBookAir-2015:training_hackerzlab yk$ sqlite3 -version
3.19.3 2017-06-27 16:48:08 2b0954060fe10d6de6d479287dd88890f1bef6cc1beca11bc6cdb79f72e2377b
[training@tk2-257-38266 ~]$ sqlite3 -version
3.6.20
[training@tk2-257-38266 ~]$
開発サーバー(CentOS6 の sqlite3 のバージョンが古いせいか csv インポートが一部失敗)
q 14, 20, 43 を一部修正

Hackerz Lab.博多 Vol.1: 2016-01-31 (日) 14:00〜: q1-q10
Hackerz Lab.博多 Vol.2: 2016-03-27 (日) 14:00〜:
Hackerz Lab.博多 Vol.3: 2016-05-08 (日) 14:00〜: q11-q15
Hackerz Lab.博多 Vol.4: 2016-06-26 (日) 16:00〜: q16-q25
Hackerz Lab.博多 Vol.5: 2016-08-08 (月) 19:00〜:
Hackerz Lab.博多 Vol.6: 2016-09-18 (日) 14:00〜:
Hackerz Lab.博多 Vol.7: 2016-11-20 (日) 14:00〜: q26-35
Hackerz Lab.博多 Vol.8: 2017-01-22 (日) 14:00〜: q36-45
Hackerz Lab.博多 Vol.9: 2017-02-26 (日) 14:00〜:
Hackerz Lab.博多 Vol.9: 2017-04-16 (日) 10:00〜:【Revival】
Hackerz Lab.博多 Vol.10: 2017-04-16 (日) 15:00〜:
Hackerz Lab.博多 Vol.10: 2017-05-28 (日) 10:00〜:【Revival】
Hackerz Lab.博多 Vol.11: 2017-05-28 (日) 15:00〜:
Hackerz Lab.博多 Vol.11: 2017-07-02 (日) 10:00〜:【Revival】
Hackerz Lab.博多 Vol.12: 2017-07-02 (日) 15:00〜:
Hackerz Lab.博多 Vol.12: 2017-09-03 (日) 10:00〜:【Revival】
Hackerz Lab.博多 Vol.13: 2017-09-03 (日) 15:00〜:
Hackerz Lab.博多 Vol.14: 2017-11-12 (日) 15:00〜:
Hackerz Lab.博多 Vol.15: 2018-01-07 (日) 15:00〜:
```

```sql
-- 当初のスキーマー
drop table if exists users;
create table users (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `user_id` VARCHAR(50) BINARY NOT NULL,
    `username` VARCHAR(50) BINARY NOT NULL,
    `password` VARCHAR(128) BINARY NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `user_id_and_passwrd` (user_id, password)
);

drop table if exists questions;
create table questions (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `question` TEXT BINARY NOT NULL,
    `answer` TEXT BINARY NOT NULL,
    `score` INT UNSIGNED NOT NULL,
    `level` INT UNSIGNED NOT NULL,
    `hint1` TEXT BINARY,
    `hint2` TEXT BINARY,
    `hint3` TEXT BINARY,
    `hint4` TEXT BINARY,
    `hint5` TEXT BINARY,
    `type` VARCHAR(30) BINARY NOT NULL,
    `addfile` VARCHAR(255) BINARY NOT NULL DEFAULT '',
    `option1` VARCHAR(128) BINARY NOT NULL DEFAULT '',
    `option2` VARCHAR(128) BINARY NOT NULL DEFAULT '',
    `option3` VARCHAR(128) BINARY NOT NULL DEFAULT '',
    `option4` VARCHAR(128) BINARY NOT NULL DEFAULT '',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

drop table if exists answers;
create table answers (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `question_id` INT UNSIGNED NOT NULL,
    `user_id` INT UNSIGNED NOT NULL,
    `user_answer` TEXT BINARY NOT NULL,
    `score` INT UNSIGNED NOT NULL,
    `hint1` INT UNSIGNED,
    `hint2` INT UNSIGNED,
    `hint3` INT UNSIGNED,
    `hint4` INT UNSIGNED,
    `hint5` INT UNSIGNED,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `question_id_and_user_id` (question_id, user_id)
);

drop table if exists scores;
create table scores (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `score` INT UNSIGNED NOT NULL,
    `updated_at` TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `user_id` (user_id)
);

drop table if exists sessions;
create table sessions (
    `session_id` VARCHAR(128) BINARY NOT NULL,
    `session_data` TEXT BINARY NOT NULL,
    `session_expires` DATETIME NOT NULL,
    `created_at` DATETIME NOT NULL,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## 開発の進め方基本ルール

__リファクタリングを常に意識して実装__

### サイクル

```
常にURLにアクセスして回覧できる状態にしておく
実際に使用して検証する
必要な機能を少しづつ追加する
見直し、修正
```

### 仕様設計

```
完結な仕様を示す資料を残す
仕様書の資料は重複した存在を避ける
仕様の変更が行われた場合は仕様書の変更を必ず行う
```

### 実装方法

```
言語や言語の拡張ライブラリでまかなえる機能はオリジナルの実装を避けて活用する
拡張ライブラリを活用する場合は必要最低限してできるだけ依存度を低くする
自動テストコードと同時進行で実装コードをコーディングする
仕様は常に変更されることを前提にして、コードの結合を低く小さい単位で実装
```

### 動作検証

```
自動テストコードで担保できる部分は担保する
自動テストコードは全てを完全に再現できないことを前提にしておく
最終は本番の環境で実際に動作確認をする
```

### 納期

```
納期の設定は慎重にそして厳守
```

## 開発進行の目安

### 公開された領域の開発

### 認証で保護された領域の開発

## DB 初期設計

いづれ作り直すことになるので、最低限度にとどめておく

命名規則参考

- <http://qiita.com/softark/items/63e68a0172a1d2f92b5c>
- <http://oxynotes.com/?p=8679>

何かの動作が完了したことを表現するには、過去分詞を使う

# EXAMPLES

# SEE ALSO

- <https://github.com/cferdinandi/smooth-scroll> - smooth-scroll
- <https://getbootstrap.com/docs/3.3/> - bootstrap
- <https://bootswatch.com/3/> - bootswatch
