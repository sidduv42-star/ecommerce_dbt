{{ config (materialized = 'incremental', unique_key =  'customer_id') }}
 
 select  
 customer_id,
    first_name,
    last_name,
    LOWER(email)                                        AS email,
    phone,
    date_of_birth,
    gender,
    segment,
    acquisition_channel,
    registration_date,
    is_active,
    loyalty_points,
    lifetime_value,
    DATEDIFF('year', date_of_birth, CURRENT_DATE)       AS age
  from {{source ('raw','customers')}}
 {% if is_incremental () %}
 where registration_date> ( select coalesce (max(registration_date),'1900-01-01'
 )
 from {{this}})
 {% endif %}