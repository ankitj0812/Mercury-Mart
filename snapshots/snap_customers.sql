{% snapshot snap_customers %}

{{ config(
    target_schema = 'SNAPSHOTS',
    strategy = 'check',
    unique_key = 'customer_id',
    check_cols = ['first_name', 'last_name', 'email', 'loyalty_tier']
) }}

select
    customer_id,
    first_name,
    last_name,
    email,
    loyalty_tier
from {{ ref('dim_customers') }}

{% endsnapshot %}