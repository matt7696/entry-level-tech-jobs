select
    *,
    row_number() over (
        partition by company, lower(trim(title))
        order by is_active desc,
                 coalesce(location ilike '%united states%' or location ilike '%, us%' or location ilike '%remote - usa%', false) desc,
                 job_id
    ) = 1 as is_primary_posting,
    count(*) over (partition by company, lower(trim(title))) as posting_copies
from {{ ref('int_postings_classified') }}