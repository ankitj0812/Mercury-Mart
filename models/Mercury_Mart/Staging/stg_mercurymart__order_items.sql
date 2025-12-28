{{ config(materialized='view', tags=['staging','mercurymart']) }}

with cleaned as (
    select
        cast(order_item_id as varchar)                 as order_item_id,
        cast(order_id as varchar)                      as order_id,
        cast(product_id as varchar)                    as product_id,
        coalesce(cast(quantity as integer), 0)         as quantity,
        coalesce(cast(unit_price as numeric(10,2)), 0) as unit_price
    from {{ source('mart_raw', 'raw_order_items') }}
)

select
    *,
    quantity * unit_price as gross_item_amount,
    quantity * unit_price as net_item_amount
from cleaned