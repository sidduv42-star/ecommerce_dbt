{{ config (materialized = 'table')}}

SELECT
    location_id,
    location_name,
    location_type,
    address_line1,
    city,
    state,
    pincode,
    country,
    latitude,
    longitude,
    zone,
    capacity_sqft,
    is_active,
    opened_date

FROM {{ source('raw', 'locations') }}
