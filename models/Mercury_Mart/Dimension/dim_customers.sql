{{ config(
    materialized = 'table',
    tags = ['mart', 'dimension']
) }}

with customers as (
    select *
    from {{ ref('stg_mercurymart__customers') }}
),

orders as (
    select
        customer_id,
        min(order_date) as first_order_date,
        count(distinct order_id) as lifetime_orders,
        sum(net_amount) as lifetime_net_revenue
    from {{ ref('stg_mercurymart__orders') }}
    group by customer_id
)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.signup_date,

    o.first_order_date,
    coalesce(o.lifetime_orders, 0) as lifetime_orders,
    coalesce(o.lifetime_net_revenue, 0) as lifetime_net_revenue,

    -- Loyalty tier logic
    case
        when o.lifetime_net_revenue >= 50000 then 'PLATINUM'
        when o.lifetime_net_revenue >= 20000 then 'GOLD'
        when o.lifetime_net_revenue >= 5000 then 'SILVER'
        when o.lifetime_net_revenue is not null then 'BRONZE'
        else 'NEW'
    end as loyalty_tier
from customers c
left join orders o
    on c.customer_id = o.customer_id