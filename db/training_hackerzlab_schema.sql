DROP TABLE IF EXISTS user;
CREATE TABLE user (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    login_id        TEXT,
    password        TEXT,
    approved        INTEGER,
    deleted         INTEGER,
    created_ts      TEXT,
    modified_ts     TEXT
);
