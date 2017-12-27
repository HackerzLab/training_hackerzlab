# NAME

deploy - training_hackerzlab

# SYNOPSIS

## CONTRACT

- サービス名: さくらのVPS(v4) SSD 1G TK02
- SAKURA internet vps - 申し込みから利用開始まで 1時間くらい時間がかかる場合がある
- 完了すると「仮登録完了のお知らせ」メールが届くので大切に保管

## ADDRESS

- vps: tk2-257-38266.vs.sakura.ne.jp
- v4: 160.16.231.20
- v6: 2001:e42:102:1817:160:16:231:20

## USER

See separately password

```
root
id: hackerzlab
id: kusakabe
id: hiramatsu
id: kii
id: ogata
id: training
```

## UPDATE

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

## START

### APP SERVER

```
(モード指定しなければ hypnotoad は production で実行される)
(開始 すぐにデーモン化)
$ carton exec -- hypnotoad script/training_hackerzlab

(開始 出力待ちの状態で開始)
$ carton exec -- hypnotoad --foreground script/training_hackerzlab

(再起動 開始している状態でまた同じことを入力)
$ carton exec -- hypnotoad script/training_hackerzlab

(停止)
$ carton exec -- hypnotoad --stop script/training_hackerzlab

(起動のテストして終了 テストコードが実行されるわけではない)
$ carton exec -- hypnotoad --test script/training_hackerzlab
```

### WEB SERVER

```
(サーバースタート)
# nginx

(サーバーを停止)
# nginx -s quit
```

# DESCRIPTION

## OVERALL FLOW

1. システムの基本的な設定 (インストールからユーザ作成)
1. リモートコントロールするための ssh の設定
1. デプロイの手順をまとめる
1. 各ミドルウェアアプリの設定
1. アプリケーションユーザー内にアプリ配置
1. 最低限のセキュリティ設定
1. web サーバーの準備
1. web ブラウザでの確認

## PREPARE

- sakura vps 契約一式
    - 申し込んで使えるまで1時間ほどかかる場合がある
- 基本的な UNIX の知識
- github 内で web サーバーで公開したい web アプリのリポジトリ作成
- hackerzlab の存在するサーバーと同居させるためサブドメインの設定

## SETUP

### システムの基本的な設定 (インストールからユーザ作成)

__下記参照__

- [os_sakuravps](https://github.com/ykHakata/summary/blob/master/os_sakuravps.md) - sakura vps でのシステムの基本設定

### リモートコントロールするための ssh の設定

__下記参照__

- [ssh_sakuravps](https://github.com/ykHakata/summary/blob/master/ssh_sakuravps.md) - ssh 設定 sakura vps と github

### デプロイの手順をまとめる

```
このドキュメントの
# SYNOPSIS
    ## UPDATE
    ## START
の項目をまとめておく
```

### 各ミドルウェアアプリの設定

perl は 5.26.1 を選択

__下記参照__

- [perl5_install](https://github.com/ykHakata/summary/blob/master/perl5_install.md) - perl5 ローカル環境での設定手順

### アプリケーションユーザー内にアプリ配置

__github のソースコードを配置__

```
$ pwd
/home/training
$ git clone git@github.com:ykHakata/training_hackerzlab.git
$ cd ~/training_hackerzlab/
$ pwd
/home/training/training_hackerzlab

(carton を使い必要なモジュール一式インストール)
$ carton install

(アプリケーションスタート)
$ carton exec -- hypnotoad script/training_hackerzlab

(停止)
$ carton exec -- hypnotoad --stop script/training_hackerzlab
```

### 最低限のセキュリティ設定

__下記参照__

- [security_sakuravps](https://github.com/ykHakata/summary/blob/master/security_sakuravps.md) - 最低限のセキュリティの設定

### web サーバーの準備

__下記参照__

- [nginx_sakuravps](https://github.com/ykHakata/summary/blob/master/nginx_sakuravps.md) - sakura vps での nginx の基本設定

### web ブラウザでの確認

__今回は事前にサブドメインの設定をしているので下記ドメインにてアクセス__

- <http://training.hackerzlab.com/> - サブドメインにてアクセス

# TODO

# SEE ALSO

## 公式サイト

- <https://www.sakura.ad.jp/> - SAKURA internet

## マニュアル

- <https://help.sakura.ad.jp/hc/ja/categories/201105252> - さくらのサポート情報 > VPS
- <https://help.sakura.ad.jp/hc/ja/articles/206208181> - 【さくらのVPS】サーバの初期設定ガイド
- <https://vps-news.sakura.ad.jp/tutorials/> - VPSチュートリアル
