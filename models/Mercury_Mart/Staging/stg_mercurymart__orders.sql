{{ config(
    materialized = 'view',
    tags = ['staging', 'mercurymart']
) }}

with orders as (
    select
        cast(order_id as varchar)         as order_id,
        cast(customer_id as varchar)      as customer_id,
        cast(order_date as date)          as order_date,
        coalesce(trim(status), 'UNKNOWN') as order_status,
        nullif(trim(coupon_code), '')     as coupon_code
    from {{ source('mart_raw', 'raw_orders') }}
),

order_items_agg as (
    select
        order_id,
        sum(gross_item_amount) as gross_amount
    from {{ ref('stg_mercurymart__order_items') }}
    group by order_id
),

payments_refunds as (
    select *
    from {{ ref('_ephemeral__payments_refunds') }}
)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.order_status,
    o.coupon_code,

    -- 🔹 Derived financial metrics
    coalesce(oi.gross_amount, 0)                     as gross_amount,
    coalesce(pr.total_refunded_amount, 0)            as discount_amount,
    coalesce(oi.gross_amount, 0)
      - coalesce(pr.total_refunded_amount, 0)        as net_amount,

    -- 🔹 Payment metrics
    pr.total_paid_amount,
    pr.total_refunded_amount,
    pr.net_paid_amount
from orders o
left join order_items_agg oi
    on o.order_id = oi.order_id
left join payments_refunds pr
    on o.order_id = pr.order_id