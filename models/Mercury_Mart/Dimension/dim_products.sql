{{ config(
    materialized = 'table',
    tags = ['mart', 'dimension']
) }}

with products as (
    select *
    from {{ ref('stg_mercurymart__products') }}
)

select
    product_id,
    product_name,
    brand,
    category,

    -- Supplier (future-proof)
    'UNKNOWN' as supplier_name,

    -- Status
    case
        when unit_price = 0 then 'INACTIVE'
        else 'ACTIVE'
    end as product_status,

    unit_price,

    -- Price bucket
    case
        when unit_price < 500 then 'LOW'
        when unit_price between 500 and 2000 then 'MID'
        else 'PREMIUM'
    end as price_bucket
from products