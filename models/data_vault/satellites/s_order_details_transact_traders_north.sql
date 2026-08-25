{{ config(
    materialized='incremental'
) }}

WITH stage_order_details_traders_north AS (

    SELECT *
    FROM {{ ref('stage_order_details_traders_north') }}

),

current_rows AS (

    {% if is_incremental() %}

    SELECT
        hk_l_order_details,
        MAX(dss_start_date) AS dss_start_date,
        MAX(dss_version) AS dss_version

    FROM {{ this }}

    GROUP BY hk_l_order_details

    {% else %}

    SELECT
        CAST(NULL AS VARCHAR) AS hk_l_order_details,
        CAST(NULL AS TIMESTAMP) AS dss_start_date,
        CAST(NULL AS INTEGER) AS dss_version

    WHERE 1 = 0

    {% endif %}

)

SELECT DISTINCT
    stage_order_details_traders_north.hk_l_order_details AS hk_l_order_details,
    stage_order_details_traders_north.orderdate AS orderdate,
    stage_order_details_traders_north.unitprice AS unitprice,
    stage_order_details_traders_north.quantity AS quantity,
    stage_order_details_traders_north.discount AS discount,
    stage_order_details_traders_north.dss_change_hash_order_details_transact_traders_north AS dss_change_hash,
    stage_order_details_traders_north.dss_record_source AS dss_record_source,
    stage_order_details_traders_north.dss_load_date AS dss_load_date,
    CURRENT_TIMESTAMP() AS dss_start_date,
    COALESCE(current_rows.dss_version, 0) + 1 AS dss_version,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM stage_order_details_traders_north

LEFT OUTER JOIN current_rows
    ON stage_order_details_traders_north.hk_l_order_details
        = current_rows.hk_l_order_details

{% if is_incremental() %}

WHERE NOT EXISTS (

    SELECT 1
    FROM {{ this }} AS s_order_details_transact_traders_north

    WHERE stage_order_details_traders_north.hk_l_order_details
        = s_order_details_transact_traders_north.hk_l_order_details

    AND stage_order_details_traders_north.dss_change_hash_order_details_transact_traders_north
        = s_order_details_transact_traders_north.dss_change_hash

    AND current_rows.dss_start_date
        = s_order_details_transact_traders_north.dss_start_date

)

{% endif %}