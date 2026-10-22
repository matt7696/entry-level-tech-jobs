select
    company || '-' || job_id as posting_key,
    company,
    job_id,
    title,
    location,
    url,

    case
        when title ilike '%data engineer%' or title ilike '%analytics engineer%' then 'data engineering'
        when title ilike '%data analyst%' or title ilike '%business intelligence%' or title ilike '%analytics%' then 'data analytics'
        when title ilike '%data scien%' or title ilike '%machine learning%' or title ilike '%research scientist%' then 'data science / ML'
        when (title ilike '%software%' or title ilike '%developer%' or title ilike '%engineer%')
             and title !~* '\y(manager|recruiter|director|sales|support|solutions?|technical services|business systems)\y'
             then 'software / other engineering'
        else 'other'
    end as role_family,

    case
        when title ~* '\y(intern|internship)\y' then 'internship'
        when title ~* '\y(early career|new grad|graduate|university)\y' then 'new grad / early career'
        when title ~* '\y(junior|entry[- ]level)\y' then 'junior'
        when title ~* '\y(senior|sr|staff|principal|lead|head|manager|director|vp)\y' then 'senior+'
        else 'unlabeled'
    end as level,

    loaded_at >= max(loaded_at) over (partition by company) - interval '1 hour' as is_active,

    -- first "N years" or "N-M years" mention; for ranges, the lower number
    (regexp_match(
        description_text,
        '(\d{1,2})\s*\+?\s*(?:(?:-|\u2013|to)\s*\d{1,2}\s*\+?)?\s*(?:years|yrs)',
        'i'
    ))[1]::int as required_years,

    case
        when (regexp_match(description_text,
            '(\d{1,2})\s*\+?\s*(?:(?:-|\u2013|to)\s*\d{1,2}\s*\+?)?\s*(?:years|yrs)', 'i'))[1]::int is null then 'not stated'
        when (regexp_match(description_text,
            '(\d{1,2})\s*\+?\s*(?:(?:-|\u2013|to)\s*\d{1,2}\s*\+?)?\s*(?:years|yrs)', 'i'))[1]::int <= 2 then '0-2 years'
        when (regexp_match(description_text,
            '(\d{1,2})\s*\+?\s*(?:(?:-|\u2013|to)\s*\d{1,2}\s*\+?)?\s*(?:years|yrs)', 'i'))[1]::int <= 4 then '3-4 years'
        else '5+ years'
    end as years_bucket

from {{ ref('stg_postings') }}