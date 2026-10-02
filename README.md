# Sentiment vs Returns Study

**Question:** Does news and social-media sentiment predict next-day stock moves, and does FinBERT beat VADER?

> Status: scaffold. Findings, charts and the Power BI dashboard are added as each stage lands.

## Approach
1. Ingest headlines/posts (free, keyless sources) and daily prices.
2. Score with VADER, FinBERT, and a fine-tuned DistilBERT (PyTorch).
3. Store everything in SQL; build views for daily sentiment, returns and lead-lag joins.
4. Test with walk-forward validation and permutation tests across a multi-ticker panel.
5. Report results honestly, including signals that fail out-of-sample.

## Repo layout
`src/` code · `sql/` schema and analysis queries · `tests/` pytest (incl. no-look-ahead checks) · `notebooks/` narrative · `dashboards/` Power BI

## Quickstart
```bash
python -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"        # add ".[ml]" for PyTorch/FinBERT
pytest
```

## Limitations
To be completed with the results (data coverage, source bias, multiple comparisons, transaction costs not modelled).
