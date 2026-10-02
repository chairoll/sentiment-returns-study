-- Sentiment on day t vs the return on day t (same-day) and t+1 (predictive test).
-- Only rows with a minimum document count are kept, to avoid noisy one-headline days.
CREATE VIEW IF NOT EXISTS v_sentiment_vs_returns AS
SELECT
    ds.ticker,
    ds.model,
    ds.signal_date,
    ds.avg_score,
    ds.n_docs,
    r.ret_1d       AS ret_same_day,
    r.ret_next_1d  AS ret_next_day
FROM v_daily_sentiment ds
JOIN v_returns r
  ON r.ticker = ds.ticker AND r.trade_date = ds.signal_date
WHERE ds.n_docs >= 3;
