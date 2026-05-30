with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select customer_id, customer_key from {{ ref('dim_customer') }}
),

locations as (
    select location_id, location_key from {{ ref('dim_location') }}
),

final as (
    select
        -- Keys
        o.order_id,
        c.customer_key,
        l.location_key,

        -- Dates
        o.order_date,
        o.shipped_date,
        o.delivered_date,
        datediff('day', o.order_date, o.shipped_date)       as days_to_ship,
        datediff('day', o.shipped_date, o.delivered_date)   as days_to_deliver,

        -- Order attributes
        o.status,
        o.product_category,
        o.product_sku,
        o.payment_method,
        o.shipping_partner,
        o.is_returned,

        -- Measures
        o.quantity,
        o.unit_price,
        o.discount_pct,
        o.tax_pct,
        o.net_amount,
        o.total_amount,

        -- Derived metrics
        round(o.unit_price * o.quantity, 2)                 as gross_revenue,
        round(o.total_amount - o.net_amount, 2)             as tax_amount,
        round(o.unit_price * o.quantity * o.discount_pct / 100, 2) as discount_amount,

        current_timestamp as dbt_updated_at
    from orders o
    left join customers c using (customer_id)
    left join locations l using (location_id)
)

select * from final