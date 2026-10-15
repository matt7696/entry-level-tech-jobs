WITH yrs AS (
  SELECT c.company, c.title, c.location, c.url, c.role_family, c.level,
         (regexp_match(p.content, '(\d{1,2})\s*(?:\+|(?:-|\u2013|to)\s*\d{1,2})?\s*(?:years|yrs)', 'i'))[1]::int AS first_years
  FROM postings_classified c
  JOIN postings p USING (company, job_id)
  WHERE c.is_active
    AND c.role_family <> 'other'
    AND c.level <> 'senior+'
)
SELECT company, title, location, url
FROM yrs
WHERE first_years <= 2
ORDER BY company, title;