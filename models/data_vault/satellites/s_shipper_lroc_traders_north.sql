{{
    config(
        materialized='incremental',
        incremental_strategy='append'
    )
}}

{% if is_incremental() %}

WITH current_rows AS (

    SELECT
        hk_h_shipper,
        MAX(dss_start_date) AS dss_start_date,
        MAX(dss_version) AS dss_version
    FROM {{ this }}
    GROUP BY hk_h_shipper

)

SELECT DISTINCT
    stage_shipper_traders_north.hk_h_shipper AS hk_h_shipper,
    stage_shipper_traders_north.shipperid AS shipperid,
    stage_shipper_traders_north.phone AS phone,
    stage_shipper_traders_north.dss_change_hash_shipper_lroc_traders_north AS dss_change_hash,
    stage_shipper_traders_north.dss_record_source AS dss_record_source,
    stage_shipper_traders_north.dss_load_date AS dss_load_date,
    CURRENT_TIMESTAMP() AS dss_start_date,
    COALESCE(current_rows.dss_version, 0) + 1 AS dss_version,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('stage_shipper_traders_north') }} stage_shipper_traders_north

LEFT JOIN current_rows
    ON stage_shipper_traders_north.hk_h_shipper = current_rows.hk_h_shipper

WHERE NOT EXISTS (
    SELECT 1
    FROM {{ this }} s_shipper_lroc_traders_north
    WHERE stage_shipper_traders_north.hk_h_shipper =
          s_shipper_lroc_traders_north.hk_h_shipper
      AND stage_shipper_traders_north.dss_change_hash_shipper_lroc_traders_north =
          s_shipper_lroc_traders_north.dss_change_hash
      AND current_rows.dss_start_date =
          s_shipper_lroc_traders_north.dss_start_date
)

{% else %}

SELECT DISTINCT
    hk_h_shipper,
    shipperid,
    phone,
    dss_change_hash_shipper_lroc_traders_north AS dss_change_hash,
    dss_record_source,
    dss_load_date,
    CURRENT_TIMESTAMP() AS dss_start_date,
    1 AS dss_version,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('stage_shipper_traders_north') }}

{% endif %}