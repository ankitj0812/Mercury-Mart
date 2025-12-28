{{ config(materialized='view', tags=['staging','mercurymart']) }}

with cleaned as (
    select
        cast(payment_id as varchar)                as payment_id,
        cast(order_id as varchar)                  as order_id,
        cast(payment_date as date)                 as payment_date,
        nullif(trim(payment_method), '')           as payment_method,
        coalesce(cast(amount as numeric(12,2)), 0) as payment_amount,
        coalesce(trim(status), 'UNKNOWN')          as payment_status
    from {{ source('mart_raw', 'raw_payments') }}
)

select *
from cleaned