with customers as (
    select * from {{ ref ('dim_customer')}}
),
orders as (
    select * from {{ ref ('fact_orders')}}
),

customer_orders as(
    select 
    o.customer_key,
    count(distinct  o.order_id) as total_orders,
    sum(o.total_amount)         as lifetime_value,
    avg(o.total_amount)         as avg_order_value,
    min(o.order_date)           as first_order_date,
    max(o.order_date)           as last_order_date,
    datediff('day', max(o.order_date),current_date)as days_since_last_order
    from orders o
    group by 1
),
final as(
    select
    c.customer_id,
    c.full_name,
    c.segment,
    c.acquisition_channel,
    c.loyalty_points,
    c.is_active,
    c.customer_segment,
    co.total_orders,
    co.lifetime_value,
    co.avg_order_value,
    co.first_order_date,
    co.last_order_date,
    co.days_since_last_order,
    case
    when co.days_since_last_order <= 30  then 'Active'
    when co.days_since_last_order <= 90  then 'At Risk'
    when co.days_since_last_order <= 180 then 'Lapsing'
    else 'Churned'
    end as recency_segment,

    case
    when co.lifetime_value >= 10000 then 'High Value'
    when co.lifetime_value >= 3000  then 'Mid Value'
    else 'Low Value'
    end as value_segment

    from customers c
    left join customer_orders co using (customer_key)
)

select * from final

