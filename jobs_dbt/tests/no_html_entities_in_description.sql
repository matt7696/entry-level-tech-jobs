select *
from {{ ref('stg_postings') }}
where description_text ~ '&(nbsp|mdash|lt|gt|quot);'