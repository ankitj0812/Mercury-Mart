{{ config(materialized='view') }}

with source as (
    select
        product_id,
        product_name,
        category,
        brand,
        unit_price
    from {{ source('mart_raw', 'raw_products') }}
),

standardized as (
    select
        cast(product_id as varchar)              as product_id,
        nullif(trim(product_name), '')           as product_name,

        upper(trim(category))                    as raw_category,

        nullif(trim(brand), '')                  as brand,
        cast(unit_price as numeric(10,2))        as unit_price
    from source
)

select
    product_id,
    product_name,

    case
        when raw_category in ('ELECTRONICS') then 'ELECTRONICS'
        when raw_category in ('GROCERY')     then 'GROCERY'
        when raw_category in ('HOME')        then 'HOME'
        when raw_category in ('BEAUTY')      then 'BEAUTY'
        when raw_category in ('APPAREL','CLOTHING','FASHION')
                                             then 'FASHION'
        else 'OTHER'
    end as category,

    brand,
    unit_price
from standardized