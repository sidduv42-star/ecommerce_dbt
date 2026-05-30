with orders as (
    select * from {{ ref('fact_orders') }}
),

locations as (
    select * from {{ ref('dim_location') }}
),

final as (
    select
        l.location_key,
        l.location_name,
        l.city,
        l.state,
        l.zone,
        l.location_type,
        l.capacity_sqft,

        count(distinct o.order_id)          as total_orders,
        count(distinct o.customer_key)      as unique_customers,
        sum(o.total_amount)                 as gross_revenue,
        sum(o.net_amount)                   as net_revenue,
        avg(o.total_amount)                 as avg_order_value,
        sum(case when o.is_returned then 1 else 0 end) as total_returns,

        -- Revenue per sqft
        round(sum(o.net_amount) / nullif(l.capacity_sqft, 0), 2) as revenue_per_sqft,

        -- Rank within zone
        rank() over (partition by l.zone order by sum(o.net_amount) desc) as rank_in_zone

    from locations l
    left join orders o using (location_key)
    group by 1,2,3,4,5,6,7
)

select * from final
order by gross_revenue desc