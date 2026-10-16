select
    company,
    job_id,
    title,
    location,
    url,
    updated_at,
    content,
    loaded_at
from {{ source('raw', 'postings') }}