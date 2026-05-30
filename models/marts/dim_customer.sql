with source as (
    select * from {{ ref('stg_customers') }}
),

final as (
    select
        -- Keys
        customer_id                                                 as customer_key,
        customer_id,

        -- Name
        first_name,
        last_name,
        first_name || ' ' || last_name                             as full_name,

        -- Contact & Demographics
        email,
        phone,
        gender,
        date_of_birth,
        datediff('year', date_of_birth, current_date)              as age_years,

        -- Segmentation inputs
        segment,                        -- your Premium/Enterprise column
        acquisition_channel,
        is_active,
        loyalty_points,

        -- Date dimensions
        registration_date::date                                     as customer_since_date,
        datediff('day', registration_date, current_date)           as customer_age_days,

        case
            when datediff('day', registration_date, current_date) <= 90  then 'New'
            when datediff('day', registration_date, current_date) <= 365 then 'Growing'
            else 'Established'
        end                                                         as customer_segment,

        current_timestamp                                           as dbt_updated_at
    from source
)

select * from final