{{ config(
    materialized='table'
) }}

WITH load_order_details_traders_south AS (

    SELECT *
    FROM {{ source('sleekmart_raw', 'LOAD_ORDER_DETAILS_TRADERS_SOUTH') }}

),

load_products_traders_south AS (

    SELECT *
    FROM {{ source('sleekmart_raw', 'LOAD_PRODUCTS_TRADERS_SOUTH') }}

),

load_orders_traders_south AS (

    SELECT *
    FROM {{ source('sleekmart_raw', 'LOAD_ORDERS_TRADERS_SOUTH') }}

)

SELECT

    MD5(
        COALESCE(
            CAST(load_orders_traders_south.orderid AS VARCHAR),
            'null'
        )
        || '||' ||
        COALESCE(
            CAST(load_products_traders_south.productname AS VARCHAR),
            'null'
        )
    ) AS hk_l_order_details,

    MD5(
        COALESCE(
            CAST(load_orders_traders_south.orderid AS VARCHAR),
            'null'
        )
    ) AS hk_h_order,

    MD5(
        COALESCE(
            CAST(load_products_traders_south.productname AS VARCHAR),
            'null'
        )
    ) AS hk_h_product,

    load_orders_traders_south.orderid AS order_number,

    load_products_traders_south.productname AS product_name,

    load_orders_traders_south.orderdate AS orderdate,

    load_order_details_traders_south.unitprice AS unitprice,

    load_order_details_traders_south.quantity AS quantity,

    load_order_details_traders_south.discount AS discount,

    MD5(
        COALESCE(
            CAST(load_orders_traders_south.orderdate AS VARCHAR),
            'null'
        )
        || '||' ||
        COALESCE(
            CAST(load_order_details_traders_south.unitprice AS VARCHAR),
            'null'
        )
        || '||' ||
        COALESCE(
            CAST(load_order_details_traders_south.quantity AS VARCHAR),
            'null'
        )
        || '||' ||
        COALESCE(
            CAST(load_order_details_traders_south.discount AS VARCHAR),
            'null'
        )
    ) AS dss_change_hash_order_details_transact_traders_south,

    load_products_traders_south.dss_record_source AS dss_record_source,

    load_products_traders_south.dss_load_date AS dss_load_date,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM load_order_details_traders_south

INNER JOIN load_products_traders_south
    ON load_order_details_traders_south.productid
        = load_products_traders_south.productid

INNER JOIN load_orders_traders_south
    ON load_order_details_traders_south.orderid
        = load_orders_traders_south.orderid