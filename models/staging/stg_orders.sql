{{ config(
    materialized='incremental',
    unique_key='order_id',
    schema='staging'
) }}

SELECT
    order_id,
    customer_id,
    location_id,
    order_date,
    shipped_date,
    delivered_date,
    status,
    product_category,
    product_sku,
    quantity,
    unit_price,
    discount_pct,
    tax_pct,
    net_amount,
    total_amount,
    payment_method,
    COALESCE(shipping_partner, 'NA') AS shipping_partner,
    is_returned

FROM {{ source('raw', 'orders') }}

{% if is_incremental() %}
    WHERE order_date >= COALESCE(
        (SELECT MAX(order_date) FROM {{ this }}),
        '1900-01-01'
    )
{% endif %}