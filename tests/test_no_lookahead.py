"""A headline published after the close must map to the NEXT trade date."""
import pytest

from sentiment_study.db.load import init_db


@pytest.fixture()
def conn(tmp_path):
    c = init_db(tmp_path / "t.db")
    c.execute("INSERT INTO tickers VALUES ('AAPL','Apple','Tech')")
    return c


def _add_doc(conn, ts, score, h):
    cur = conn.execute(
        "INSERT INTO documents (ticker, source, published_at, text_hash) "
        "VALUES ('AAPL','gdelt',?,?)", (ts, h))
    conn.execute("INSERT INTO sentiment_scores VALUES (?, 'vader', ?)",
                 (cur.lastrowid, score))


def test_after_close_headline_goes_to_next_day(conn):
    _add_doc(conn, "2026-03-02T22:30:00", 0.9, "a")   # after 21:00 UTC close
    _add_doc(conn, "2026-03-02T15:00:00", 0.1, "b")   # during session
    rows = dict(conn.execute(
        "SELECT signal_date, avg_score FROM v_daily_sentiment").fetchall())
    assert rows["2026-03-03"] == pytest.approx(0.9)
    assert rows["2026-03-02"] == pytest.approx(0.1)


def test_next_day_return_uses_future_close(conn):
    for d, c in [("2026-03-02", 100), ("2026-03-03", 110), ("2026-03-04", 99)]:
        conn.execute(
            "INSERT INTO prices_daily (ticker, trade_date, close) VALUES ('AAPL',?,?)",
            (d, c))
    r = dict(conn.execute(
        "SELECT trade_date, ret_next_1d FROM v_returns").fetchall())
    assert r["2026-03-02"] == pytest.approx(0.10)
    assert r["2026-03-04"] is None
