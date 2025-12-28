{{ config(materialized='ephemeral') }}

with payments as (
    select
        order_id,
        sum(abs(payment_amount)) as total_paid_amount
    from {{ ref('stg_mercurymart__payments') }}
    where payment_status = 'SUCCESS'
    group by order_id
),

refunds as (
    select
        order_id,
        sum(abs(refund_amount)) as total_refunded_amount
    from {{ ref('stg_mercurymart__refunds') }}
    group by order_id
)

select
    coalesce(p.order_id, r.order_id) as order_id,
    coalesce(p.total_paid_amount, 0) as total_paid_amount,
    coalesce(r.total_refunded_amount, 0) as total_refunded_amount,

    greatest(
        coalesce(p.total_paid_amount, 0)
        - coalesce(r.total_refunded_amount, 0),
        0
    ) as net_paid_amount
from payments p
full outer join refunds r
    on p.order_id = r.order_id