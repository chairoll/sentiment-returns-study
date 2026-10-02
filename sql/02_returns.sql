-- Close-to-close daily returns and next-day returns per ticker.
CREATE VIEW IF NOT EXISTS v_returns AS
SELECT
    ticker,
    trade_date,
    close / LAG(close) OVER (PARTITION BY ticker ORDER BY trade_date) - 1  AS ret_1d,
    LEAD(close) OVER (PARTITION BY ticker ORDER BY trade_date)
        / close - 1                                                        AS ret_next_1d
FROM prices_daily;
