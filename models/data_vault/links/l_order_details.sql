{{ config(
    materialized='incremental'
) }}

WITH stage_order_details_traders_south AS (

    SELECT *
    FROM {{ ref('stage_order_details_traders_south') }}

),

stage_order_details_traders_north AS (

    SELECT *
    FROM {{ ref('stage_order_details_traders_north') }}

),

south_records AS (

    SELECT DISTINCT
        stage_order_details_traders_south.hk_l_order_details
            AS hk_l_order_details,

        stage_order_details_traders_south.hk_h_order
            AS hk_h_order,

        stage_order_details_traders_south.hk_h_product
            AS hk_h_product,

        stage_order_details_traders_south.dss_record_source
            AS dss_record_source,

        stage_order_details_traders_south.dss_load_date
            AS dss_load_date,

        CURRENT_TIMESTAMP()
            AS dss_create_time

    FROM stage_order_details_traders_south

    {% if is_incremental() %}

    WHERE NOT EXISTS (

        SELECT 1
        FROM {{ this }} AS l_order_details

        WHERE stage_order_details_traders_south.hk_h_order
            = l_order_details.hk_h_order

        AND stage_order_details_traders_south.hk_h_product
            = l_order_details.hk_h_product

    )

    {% endif %}

),

north_records AS (

    SELECT DISTINCT
        stage_order_details_traders_north.hk_l_order_details
            AS hk_l_order_details,

        stage_order_details_traders_north.hk_h_order
            AS hk_h_order,

        stage_order_details_traders_north.hk_h_product
            AS hk_h_product,

        stage_order_details_traders_north.dss_record_source
            AS dss_record_source,

        stage_order_details_traders_north.dss_load_date
            AS dss_load_date,

        CURRENT_TIMESTAMP()
            AS dss_create_time

    FROM stage_order_details_traders_north

    {% if is_incremental() %}

    WHERE NOT EXISTS (

        SELECT 1
        FROM {{ this }} AS l_order_details

        WHERE stage_order_details_traders_north.hk_h_order
            = l_order_details.hk_h_order

        AND stage_order_details_traders_north.hk_h_product
            = l_order_details.hk_h_product

    )

    {% endif %}

)

SELECT *
FROM south_records

UNION ALL

SELECT *
FROM north_records