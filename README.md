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
$ sudo su - training_hackerzlab

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
トップページ (ログイン中)
    サイトタイトル
    サイト説明文
    問題をとくボタン -> 問題を解く画面
    ログアウトボタン -> ログアウトしてトップページ
    問題一覧
    自分の回答一覧ボタン -> 解答一覧画面
    総合ランキングボタン -> 総合ランキング画面

問題を解く画面
    ユーザーID表示
    名前表示
    問題を始めるボタン -> 第1問へ
    ログアウトボタン -> ログアウトしてトップページ
    得点確認ボタン -> 回答結果画面

回答結果画面
    回答結果、ユーザーID表示
    現在の得点表示

総合ランキング画面
    ランキング順位、ログインID
    現在の得点
    トップページボタン -> トップページ

解答一覧画面
    解答した問題の答えのリスト

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
    送信ボタン
    (問題により)
    ファイルをダウンロードボタン -> ファイルがダウンロードされる

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
    回答を全て削除ボタン
    ユーザーを全て削除ボタン
    各問題の項目一覧
        編集ボタン
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
