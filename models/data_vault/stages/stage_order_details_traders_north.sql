{{ config(
    materialized='table'
) }}

WITH load_order_details_traders_north AS (

    SELECT *
    FROM {{ source('sleekmart_raw', 'LOAD_ORDER_DETAILS_TRADERS_NORTH') }}

),

load_orders_traders_north AS (

    SELECT *
    FROM {{ source('sleekmart_raw', 'LOAD_ORDERS_TRADERS_NORTH') }}

),

load_products_traders_north AS (

    SELECT *
    FROM {{ source('sleekmart_raw', 'LOAD_PRODUCTS_TRADERS_NORTH') }}

)

SELECT

    MD5(
        COALESCE(
            CAST(load_orders_traders_north.orderid AS VARCHAR),
            'null'
        )
        || '||' ||
        COALESCE(
            CAST(load_products_traders_north.productname AS VARCHAR),
            'null'
        )
    ) AS hk_l_order_details,

    MD5(
        COALESCE(
            CAST(load_orders_traders_north.orderid AS VARCHAR),
            'null'
        )
    ) AS hk_h_order,

    MD5(
        COALESCE(
            CAST(load_products_traders_north.productname AS VARCHAR),
            'null'
        )
    ) AS hk_h_product,

    load_orders_traders_north.orderid AS order_number,

    load_products_traders_north.productname AS product_name,

    load_orders_traders_north.orderdate AS orderdate,

    load_order_details_traders_north.unitprice AS unitprice,

    load_order_details_traders_north.quantity AS quantity,

    load_order_details_traders_north.discount AS discount,

    MD5(
        COALESCE(
            CAST(load_orders_traders_north.orderdate AS VARCHAR),
            'null'
        )
        || '||' ||
        COALESCE(
            CAST(load_order_details_traders_north.unitprice AS VARCHAR),
            'null'
        )
        || '||' ||
        COALESCE(
            CAST(load_order_details_traders_north.quantity AS VARCHAR),
            'null'
        )
        || '||' ||
        COALESCE(
            CAST(load_order_details_traders_north.discount AS VARCHAR),
            'null'
        )
    ) AS dss_change_hash_order_details_transact_traders_north,

    load_order_details_traders_north.dss_record_source AS dss_record_source,

    load_order_details_traders_north.dss_load_date AS dss_load_date,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM load_order_details_traders_north

INNER JOIN load_orders_traders_north
    ON load_order_details_traders_north.orderid
        = load_orders_traders_north.orderid

INNER JOIN load_products_traders_north
    ON load_order_details_traders_north.productid
        = load_products_traders_north.productid