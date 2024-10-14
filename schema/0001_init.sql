-- 日記テーブル
CREATE TABLE diaries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT UNIQUE NOT NULL,
  created_at TEXT NOT NULL,
  content TEXT,
  rating INTEGER
);
