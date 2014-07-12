CREATE TABLE weather_data (
  id INTEGER PRIMARY KEY autoincrement,
  temperature REAL NOT NULL,
  humidity INTEGER NOT NULL,
  pressure INTEGER NOT NULL,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);