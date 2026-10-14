CREATE OR REPLACE VIEW postings_classified AS
SELECT
  company, job_id, title, location, url,
  CASE
    WHEN title ILIKE '%data engineer%' OR title ILIKE '%analytics engineer%' THEN 'data engineering'
    WHEN title ILIKE '%data analyst%' OR title ILIKE '%business intelligence%' OR title ILIKE '%analytics%' THEN 'data analytics'
    WHEN title ILIKE '%data scien%' OR title ILIKE '%machine learning%' OR title ILIKE '%research scientist%' THEN 'data science / ML'
    WHEN title ILIKE '%software%' OR title ILIKE '%developer%' OR title ILIKE '%engineer%' THEN 'software / other engineering'
    ELSE 'other'
  END AS role_family,
  CASE
    WHEN title ~* '\y(intern|internship)\y' THEN 'internship'
    WHEN title ~* '\y(early career|new grad|graduate|university)\y' THEN 'new grad / early career'
    WHEN title ~* '\y(junior|entry[- ]level)\y' THEN 'junior'
    WHEN title ~* '\y(senior|staff|principal)\y' THEN 'senior+'
    ELSE 'unlabeled'
  END AS level,
  loaded_at >= max(loaded_at) OVER (PARTITION BY company) - interval '1 hour' AS is_active
FROM postings;