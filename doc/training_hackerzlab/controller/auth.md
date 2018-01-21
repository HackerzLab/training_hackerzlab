# NAME

training_hackerzlab/controller/auth - TrainingHackerzlab 認証

# SYNOPSIS

## URL

- GET - `/auth/create` - create - ユーザー登録画面
- GET - `/auth/:id/edit` - edit ユーザーパスワード変更画面 (未実装)
- GET - `/auth/:id` - show ユーザー情報詳細 (未実装)
- GET - `/auth` - index - ログイン入力画面
- GET - `/auth/logout` - logout - ユーザーログアウト画面
- GET - `/auth/remove` - remove ユーザー削除画面
- POST - `/auth/login` - login - ユーザーログイン実行
- POST - `/auth/logout` - logout - ユーザーログアウト実行
- POST - `/auth/:id/update` - update ユーザーパスワード変更実行 (未実装)
- POST - `/auth/:id/remove` - remove ユーザー削除実行
- POST - `/auth` - store ユーザー新規登録実行

# DESCRIPTION

## - GET - `/auth/create` - create - ユーザー登録画面

```
ユーザー登録画面
    入力フォーム
        ユーザーID
        名前
        パスワード
    ログインボタン(登録ボタン?) -> ログインしてアプリメニュートップページ
```

## - GET - `/auth/:id/edit` - edit ユーザーパスワード変更画面 (未実装)

```
旧システムは未実装
```

## - GET - `/auth/:id` - show ユーザー情報詳細 (未実装)

```
旧システムは未実装
```

## - GET - `/auth` - index - ログイン入力画面

```
ログイン入力画面
    入力フォーム
        ユーザーID
        パスワード
    ログインボタン -> ログインしてアプリメニューページ
```

## - GET - `/auth/logout` - logout - ユーザーログアウト画面

```
ログアウトボタン -> ログアウト実行からのリダイレクト
```

## - POST - `/auth/login` - login - ユーザーログイン実行

```
ログインボタン -> ログイン実行 -> 成功(ログインしてアプリメニューページ)
ログインボタン -> ログイン実行 -> 失敗(ログインせずログイン入力画面)
```

## - POST - `/auth/logout` - logout - ユーザーログアウト実行

```
ログアウトボタン -> ログアウト実行 -> 成功(ログアウトしてログアウト画面)
ログアウトボタン -> ログアウト実行 -> 失敗(例外処理)
```

## - POST - `/auth/:id/update` - update ユーザーパスワード変更実行 (未実装)

```
旧システムは未実装
```

## - POST - `/auth/:id/remove` - remove ユーザー削除実行 (未実装)

```
旧システムは未実装
```

## - POST - `/auth` - store ユーザー新規登録実行

```
登録ボタン -> 登録実行 -> 登録失敗(登録せずトップページ)
登録ボタン -> 登録実行 -> 登録成功(登録してログイン状態でアプリメニューページ)
```

# TODO

# SEE ALSO

- `lib/TrainingHackerzlab/Controller/Auth.pm` -
- `lib/TrainingHackerzlab/Model/Auth.pm` -
- `templates/auth/index.html.ep` -
- `t/training_hackerzlab/controller/auth.t` -
