{{ config(materialized='view', tags=['staging','mercurymart']) }}

with cleaned as (
    select
        cast(customer_id as varchar) as customer_id,
        nullif(trim(lower(email)), '') as email,
        coalesce(nullif(trim(first_name), ''), 'unknown') as first_name,
        coalesce(nullif(trim(last_name), ''), 'unknown') as last_name,
        cast(signup_date as date) as signup_date
    from {{ source('mart_raw', 'raw_customers') }}
)

select *
from cleaned
qualify row_number() over (
    partition by customer_id
    order by signup_date desc nulls last
) = 1