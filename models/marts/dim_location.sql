with source as (
    select * from {{ ref('stg_locations') }}
),

final as (
    select
        -- Keys
        location_id                 as location_key,
        location_id,

        -- Descriptive attributes
        location_name,
        location_type,
        address_line1,
        city,
        state,
        pincode,
        country,
        zone,                       -- this is your "region" equivalent

        -- Geographic
        latitude,
        longitude,

        -- Sizing
        capacity_sqft,

        current_timestamp           as dbt_updated_at
    from source
)

select * from final