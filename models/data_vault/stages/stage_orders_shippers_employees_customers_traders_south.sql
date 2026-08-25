{{ config(
    materialized='table'
) }}

WITH load_orders_traders_south AS (

    SELECT *
    FROM {{ source('sleekmart_raw', 'LOAD_ORDERS_TRADERS_SOUTH') }}

),

load_customers_traders_south AS (

    SELECT *
    FROM {{ source('sleekmart_raw', 'LOAD_CUSTOMERS_TRADERS_SOUTH') }}

),

load_shippers_traders_south AS (

    SELECT *
    FROM {{ source('sleekmart_raw', 'LOAD_SHIPPERS_TRADERS_SOUTH') }}

)

SELECT
    MD5(
        COALESCE(CAST(load_customers_traders_south.companyname AS VARCHAR), 'null')
        || '||' ||
        COALESCE(CAST(load_orders_traders_south.employeeid AS VARCHAR), 'null')
        || '||' ||
        COALESCE(CAST(load_orders_traders_south.orderid AS VARCHAR), 'null')
        || '||' ||
        COALESCE(CAST(load_shippers_traders_south.companyname AS VARCHAR), 'null')
    ) AS hk_l_orders_shippers_employees_customers,

    MD5(
        COALESCE(CAST(load_customers_traders_south.companyname AS VARCHAR), 'null')
    ) AS hk_h_customer,

    MD5(
        COALESCE(CAST(load_orders_traders_south.employeeid AS VARCHAR), 'null')
    ) AS hk_h_employee,

    MD5(
        COALESCE(CAST(load_orders_traders_south.orderid AS VARCHAR), 'null')
    ) AS hk_h_order,

    MD5(
        COALESCE(CAST(load_shippers_traders_south.companyname AS VARCHAR), 'null')
    ) AS hk_h_shipper,

    load_customers_traders_south.companyname AS customer_name,

    load_orders_traders_south.employeeid AS employee_id,

    load_orders_traders_south.orderid AS order_number,

    load_shippers_traders_south.companyname AS shipper_name,

    load_shippers_traders_south.dss_record_source AS dss_record_source,

    load_shippers_traders_south.dss_load_date AS dss_load_date,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM load_orders_traders_south

INNER JOIN load_customers_traders_south
    ON load_orders_traders_south.customerid
        = load_customers_traders_south.customerid

INNER JOIN load_shippers_traders_south
    ON load_orders_traders_south.shipvia
        = load_shippers_traders_south.shipperid