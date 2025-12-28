{{ config(materialized='view', tags=['staging','mercurymart']) }}

with cleaned as (
    select
        cast(refund_id as varchar)                as refund_id,
        cast(payment_id as varchar)               as payment_id,
        cast(order_id as varchar)                 as order_id,
        cast(refund_date as date)                 as refund_date,
        coalesce(cast(amount as numeric(12,2)), 0) as refund_amount,
        nullif(trim(reason), '')                  as refund_reason
    from {{ source('mart_raw', 'raw_refunds') }}
)

select *
from cleaned