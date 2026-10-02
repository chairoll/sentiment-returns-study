-- Daily average sentiment per ticker and model.
-- Documents published after the 21:00 UTC close are assigned to the NEXT trade date,
-- so a headline can never be matched to a price move that already happened (no look-ahead).
CREATE VIEW IF NOT EXISTS v_daily_sentiment AS
SELECT
    d.ticker,
    s.model,
    CASE
        WHEN CAST(strftime('%H', d.published_at) AS INTEGER) >= 21
            THEN date(d.published_at, '+1 day')
        ELSE date(d.published_at)
    END                       AS signal_date,
    AVG(s.score)              AS avg_score,
    COUNT(*)                  AS n_docs
FROM documents d
JOIN sentiment_scores s USING (doc_id)
GROUP BY d.ticker, s.model, signal_date;
