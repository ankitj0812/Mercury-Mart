{{ config(materialized='view', tags=['staging','mercurymart']) }}

with cleaned as (
    select
        cast(product_id as varchar)                    as product_id,
        nullif(trim(product_name), '')                 as product_name,
        nullif(trim(category), '')                     as category,
        nullif(trim(brand), '')                        as brand,
        coalesce(cast(unit_price as numeric(10,2)), 0) as unit_price
    from {{ source('mart_raw', 'raw_products') }}
)

select *
from cleaned