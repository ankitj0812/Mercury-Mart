{{ config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    unique_key = ['order_id', 'order_date']
) }}

with orders as (
    select
        order_id,
        customer_id,
        order_date,
        gross_amount,

        -- Discounts must be positive
        abs(discount_amount) as discount_amount
    from {{ ref('stg_mercurymart__orders') }}
),

payments_refunds as (
    select *
    from {{ ref('_ephemeral__payments_refunds') }}
)

select
    o.order_id,
    o.order_date,
    o.customer_id,

    o.gross_amount,
    o.discount_amount,

    -- Net order value must never be negative
    greatest(
        o.gross_amount - o.discount_amount,
        0
    ) as net_amount,

    pr.total_paid_amount,
    pr.total_refunded_amount,
    pr.net_paid_amount,

    case
        when pr.net_paid_amount >= greatest(o.gross_amount - o.discount_amount, 0)
            then 'PAID'
        when pr.net_paid_amount > 0
            then 'PARTIALLY_PAID'
        else 'UNPAID'
    end as payment_status

from orders o
left join payments_refunds pr
    on o.order_id = pr.order_id