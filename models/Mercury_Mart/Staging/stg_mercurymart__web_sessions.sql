{{ config(
    materialized = 'view',
    tags = ['staging', 'mercurymart']
) }}

with source as (

    select
        session_id,
        customer_id,
        session_start_time,
        session_end_time,
        device_type,
        country
    from {{ source('mart_raw', 'raw_web_sessions') }}

),

cleaned as (

    select
        cast(session_id as number(38,0))      as session_id,
        cast(customer_id as number(38,0))     as customer_id,

        session_start_time                    as session_start_time,
        session_end_time                      as session_end_time,

        nullif(trim(device_type), '')         as device_type,
        nullif(trim(country), '')             as country
    from source
)

select
    session_id,
    customer_id,
    session_start_time,
    session_end_time,

    cast(session_start_time as date)          as session_date,

    datediff(
        second,
        session_start_time,
        session_end_time
    )                                        as session_duration_seconds,

    device_type,
    country
from cleaned