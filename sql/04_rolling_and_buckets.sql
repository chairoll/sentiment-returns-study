-- 7-day rolling sentiment per ticker/model (window function).
SELECT
    ticker, model, signal_date, avg_score,
    AVG(avg_score) OVER (
        PARTITION BY ticker, model
        ORDER BY signal_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7d_score
FROM v_daily_sentiment
ORDER BY ticker, model, signal_date;

-- Sentiment quintile vs average next-day return, per model.
-- A real signal should show a monotonic pattern, while flat or noisy results mean no evidence.
WITH ranked AS (
    SELECT
        model, ticker, ret_next_day,
        NTILE(5) OVER (PARTITION BY model ORDER BY avg_score) AS sentiment_quintile
    FROM v_sentiment_vs_returns
    WHERE ret_next_day IS NOT NULL
)
SELECT
    model,
    sentiment_quintile,
    COUNT(*)                AS n_obs,
    AVG(ret_next_day)       AS avg_next_day_return
FROM ranked
GROUP BY model, sentiment_quintile
ORDER BY model, sentiment_quintile;
