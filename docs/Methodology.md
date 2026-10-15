# Methodology

## Data
- Source: public Greenhouse job board API for 33 tech companies (see `boards.txt`)
- 7,610 postings loaded as of Oct 2026; stored raw as JSON and in Postgres
- Postings missing from a company's latest snapshot are flagged inactive, not deleted

## Role family
Keyword rules on the job title: data engineering, data analytics, data science / ML, software / other engineering, and other. Managers, recruiters, sales, and support titles are excluded from the software bucket.

## Level
Keyword rules on the title: internship, new grad / early career, junior, senior+, or unlabeled. Word-boundary matching avoids false hits like "Internal" matching "intern".

## Required experience
Extracted from the first "N years" mention in the description, bucketed into 0-2, 3-4, 5+, or not stated.

## Measured quality (hand-checked samples)
- Title-based entry-level flag: ~81% precision on 36 postings
- Phrase search in descriptions: poor, 0 of 5 readable matches were true entry-level
- Years-of-experience 0-2 group: ~60% were real dev/data roles, many with a "2+ years" minimum

## Known limitations
- Titles only for role family and level; descriptions only for years
- The first "N years" in a description may belong to a specific skill, and ranges like "3-5" may be read as 5
- Sample covers 33 companies, mostly larger tech companies, so results aren't representative of the whole market
- "Low experience required" is not the same as "entry-level"