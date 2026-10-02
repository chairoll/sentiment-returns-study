-- Sentiment vs returns study: core schema (SQLite; portable to Postgres with minor type changes)

CREATE TABLE IF NOT EXISTS tickers (
    ticker      TEXT PRIMARY KEY,
    name        TEXT,
    sector      TEXT
);

-- One row per headline / post. Store scores, not republished text, where terms require it.
CREATE TABLE IF NOT EXISTS documents (
    doc_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    ticker        TEXT NOT NULL REFERENCES tickers(ticker),
    source        TEXT NOT NULL,              -- 'gdelt' | 'google_news_rss' | 'stocktwits'
    published_at  TEXT NOT NULL,              -- ISO-8601 UTC
    text_hash     TEXT NOT NULL,              -- dedupe key
    UNIQUE (ticker, source, text_hash)
);

-- One row per (document, model). Lets you compare VADER vs FinBERT vs fine-tuned model.
CREATE TABLE IF NOT EXISTS sentiment_scores (
    doc_id      INTEGER NOT NULL REFERENCES documents(doc_id),
    model       TEXT NOT NULL,                -- 'vader' | 'finbert' | 'distilbert_ft'
    score       REAL NOT NULL,                -- signed, roughly in [-1, 1]
    PRIMARY KEY (doc_id, model)
);

CREATE TABLE IF NOT EXISTS prices_daily (
    ticker      TEXT NOT NULL REFERENCES tickers(ticker),
    trade_date  TEXT NOT NULL,                -- YYYY-MM-DD
    open        REAL, high REAL, low REAL,
    close       REAL NOT NULL,
    volume      INTEGER,
    PRIMARY KEY (ticker, trade_date)
);

CREATE INDEX IF NOT EXISTS idx_docs_ticker_time ON documents (ticker, published_at);
