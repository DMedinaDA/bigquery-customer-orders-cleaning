# bigquery-customer-orders-cleaning
SQL data cleaning project in BigQuery that standardizes messy customer order data and removes duplicates.

# Customer Orders Data Cleaning in BigQuery

A SQL project focused on cleaning and standardizing messy customer order data for analysis.

## Overview

In this project, I used BigQuery SQL to transform raw customer order data into a cleaner, analysis-ready dataset. The workflow included standardizing customer names, order statuses, product names, quantities, and dates, along with removing duplicate records.

## What I did

- Standardized inconsistent order statuses using `CASE` statements.
- Cleaned and normalized product names.
- Converted quantity values into a consistent numeric format.
- Formatted customer names with `INITCAP()`.
- Standardized date values.
- Removed duplicate rows using `ROW_NUMBER()`.

## Tools Used

- BigQuery
- SQL
- Window functions
- String functions
- Date parsing functions
## Key SQL Concepts Used
- `CASE`
- `INITCAP`
- `LOWER`
- `SAFE_CAST`
- `SAFE.PARSE_DATE`
- `ROW_NUMBER()`
- `PARTITION BY`
## Future Improvements
- Add more product mappings.
- Expand duplicate checks.
- Build a dashboard from the cleaned dataset.

## Contact

Built
