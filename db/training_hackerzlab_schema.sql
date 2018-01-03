DROP TABLE IF EXISTS user;
CREATE TABLE user (                                     -- ユーザー
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    login_id        TEXT,                               -- ログインID名 (例: 'hackerz@gmail.com')
    password        TEXT,                               -- ログインパスワード (例: 'hackerz')
    name            TEXT,                               -- 名前 (例: 'おそまつ')
    approved        INTEGER,                            -- 承認フラグ (例: 0: 承認していない, 1: 承認済み)
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
DROP TABLE IF EXISTS question;
CREATE TABLE question (                                 -- 問題
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    question        TEXT,                               -- 問題文 (例: '以下の暗号を解読し、元の文字列を解読せよ。')
    answer          TEXT,                               -- 問題の答え (例: 'Stay Hungry')
    score           INTEGER,                            -- 得点 (例 10)
    level           INTEGER,                            -- 難易度 (例: 1)
    pattern         INTEGER,                            -- 問題パターン (例: 10: form, 20: choice, ...)
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
DROP TABLE IF EXISTS hint;
CREATE TABLE hint (                                     -- 問題のヒント
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    question_id     INTEGER,                            -- 問題ID (例: 5)
    level           INTEGER,                            -- ヒントレベル (例: 3 )
    hint            TEXT,                               -- ヒント文面 (例: '問題をよく読んでみよう')
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
DROP TABLE IF EXISTS answers;
CREATE TABLE answers (                                  -- 入力された解答
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    question_id     INTEGER,                            -- 問題ID (例: 5)
    user_id         INTEGER,                            -- ユーザーID (例: 5)
    user_answer     TEXT,                               -- 入力した答え (例: 'Stay Hungry')
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
DROP TABLE IF EXISTS scores;
CREATE TABLE scores (                                   -- 得点
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    user_id         INTEGER,                            -- ユーザーID (例: 5)
    score           INTEGER,                            -- 得点の合計 (例: 80)
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
