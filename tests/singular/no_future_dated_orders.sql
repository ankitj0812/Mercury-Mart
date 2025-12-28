select *
from {{ ref('fct_orders_daily') }}
where order_date > current_date