with source as (
    select * from {{ source('raw', 'postings') }}
),

unescaped as (
    select
        *,
        -- pass 1: undo the escaping of the HTML itself (&amp; last)
        replace(replace(replace(replace(replace(content,
            '&lt;', '<'), '&gt;', '>'), '&quot;', '"'), '&#39;', ''''), '&amp;', '&') as html
    from source
)

select
    company,
    job_id,
    title,
    location,
    url,
    updated_at,
    content,
    loaded_at,
    -- pass 2: strip tags, then decode entities that were inside the text (&amp; last)
    trim(regexp_replace(
        replace(replace(replace(replace(replace(replace(replace(
            regexp_replace(html, '<[^>]*>', ' ', 'g'),
            '&nbsp;', ' '), '&mdash;', ' - '), '&quot;', '"'), '&#39;', ''''), '&lt;', '<'), '&gt;', '>'), '&amp;', '&'),
        '\s+', ' ', 'g'
    )) as description_text
from unescaped