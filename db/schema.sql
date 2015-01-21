CREATE TABLE weather_data (
  id INTEGER PRIMARY KEY autoincrement,
  temperature REAL NOT NULL,
  humidity REAL NOT NULL,
  pressure INTEGER NOT NULL,
  timestamp DATE DEFAULT (datetime('now', 'localtime'))
);