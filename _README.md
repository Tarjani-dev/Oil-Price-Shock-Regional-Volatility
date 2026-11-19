# Raw Data

The raw Lending Club dataset is **not committed to this repository** because it exceeds GitHub's recommended file size (the full file is ~2.26 million rows, 151 columns, several hundred MB).

## Source

- Dataset: [Lending Club Loan Data (Kaggle)](https://www.kaggle.com/datasets/wordsforthewise/lending-club)
- File used: `accepted_2007_to_2018Q4.csv`

## How to get it

1. Create a free Kaggle account if you don't have one.
2. Go to the dataset link above and click **Download**.
3. Unzip the archive and place `accepted_2007_to_2018Q4.csv` in this folder (`data/raw/`).

Alternatively, using the Kaggle CLI:

```bash
pip install kaggle
# Place your kaggle.json API token in ~/.kaggle/ first
kaggle datasets download -d wordsforthewise/lending-club -p data/raw --unzip
```

## Expected file

| File | Approx. rows | Approx. columns |
|---|---|---|
| `accepted_2007_to_2018Q4.csv` | 2,260,701 | 151 |

## Next step

Once the raw file is in place, run the scripts in `/sql` (starting with `01_filters_funnel.sql`) or the notebook in `/notebooks` to reproduce the cleaned cohort used throughout this analysis.
