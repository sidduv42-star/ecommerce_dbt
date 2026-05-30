with base as (
    select * from {{ ref('fact_orders') }}
),

final as (
    select
        date_trunc('month', order_date)::date       as month,
        count(distinct order_id)                    as total_orders,
        count(distinct customer_key)                as unique_customers,
        sum(total_amount)                           as gross_revenue,
        sum(net_amount)                             as net_revenue,
        avg(total_amount)                           as avg_order_value,
        sum(case when is_returned then 1 else 0 end) as total_returns,
        round(sum(case when is_returned then 1 else 0 end) * 100.0 
              / nullif(count(*), 0), 2)             as return_rate_pct
    from base
    group by 1
)

select
    *,
    lag(net_revenue) over (order by month)          as prev_month_revenue,
    round((net_revenue - lag(net_revenue) over (order by month))
          / nullif(lag(net_revenue) over (order by month), 0) * 100, 2) as mom_growth_pct
from final
order by month