{{ config(
    materialized='table'
) }}

SELECT
    MD5(
        COALESCE(
            CAST(load_customers_traders_north.companyname AS VARCHAR),
            'null'
        )
        || '||' ||
        COALESCE(
            CAST(load_orders_traders_north.employeeid AS VARCHAR),
            'null'
        )
        || '||' ||
        COALESCE(
            CAST(load_orders_traders_north.orderid AS VARCHAR),
            'null'
        )
        || '||' ||
        COALESCE(
            CAST(load_shippers_traders_north.companyname AS VARCHAR),
            'null'
        )
    ) AS hk_l_orders_shippers_employees_customers,

    MD5(
        COALESCE(
            CAST(load_customers_traders_north.companyname AS VARCHAR),
            'null'
        )
    ) AS hk_h_customer,

    MD5(
        COALESCE(
            CAST(load_orders_traders_north.employeeid AS VARCHAR),
            'null'
        )
    ) AS hk_h_employee,

    MD5(
        COALESCE(
            CAST(load_orders_traders_north.orderid AS VARCHAR),
            'null'
        )
    ) AS hk_h_order,

    MD5(
        COALESCE(
            CAST(load_shippers_traders_north.companyname AS VARCHAR),
            'null'
        )
    ) AS hk_h_shipper,

    load_customers_traders_north.companyname AS customer_name,

    load_orders_traders_north.employeeid AS employee_id,

    load_orders_traders_north.orderid AS order_number,

    load_shippers_traders_north.companyname AS shipper_name,

    load_shippers_traders_north.dss_record_source AS dss_record_source,

    load_shippers_traders_north.dss_load_date AS dss_load_date,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ source('sleekmart_raw', 'LOAD_ORDERS_TRADERS_NORTH') }}
    AS load_orders_traders_north

INNER JOIN {{ source('sleekmart_raw', 'LOAD_SHIPPERS_TRADERS_NORTH') }}
    AS load_shippers_traders_north
    ON load_orders_traders_north.shipvia
        = load_shippers_traders_north.shipperid

INNER JOIN {{ source('sleekmart_raw', 'LOAD_CUSTOMERS_TRADERS_NORTH') }}
    AS load_customers_traders_north
    ON load_orders_traders_north.customerid
        = load_customers_traders_north.customerid