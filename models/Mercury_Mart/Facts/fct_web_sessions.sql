{{ config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    unique_key = 'session_id'
) }}

select
    session_id,
    customer_id,
    session_date,
    session_start_time,
    session_end_time,
    session_duration_seconds,
    device_type,
    country,

    case
        when session_duration_seconds >= 60 then true
        else false
    end as is_engaged_session

from {{ ref('stg_mercurymart__web_sessions') }}

{% if is_incremental() %}
where session_start_time >= dateadd(day, -2, current_timestamp())
{% endif %}