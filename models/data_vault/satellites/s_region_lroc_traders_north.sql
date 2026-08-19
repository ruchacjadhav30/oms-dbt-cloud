{{
    config(
        materialized='incremental',
        incremental_strategy='append'
    )
}}

{% if is_incremental() %}

WITH current_rows AS (

    SELECT
        hk_h_region,
        MAX(dss_start_date) AS dss_start_date,
        MAX(dss_version) AS dss_version
    FROM {{ this }}
    GROUP BY hk_h_region

)

SELECT DISTINCT

    stage_region_traders_north.hk_h_region AS hk_h_region,

    stage_region_traders_north.regiondescription AS regiondescription,

    stage_region_traders_north.dss_change_hash_region_lroc_traders_north
        AS dss_change_hash,

    stage_region_traders_north.dss_record_source AS dss_record_source,

    stage_region_traders_north.dss_load_date AS dss_load_date,

    CURRENT_TIMESTAMP() AS dss_start_date,

    COALESCE(current_rows.dss_version, 0) + 1 AS dss_version,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('stage_region_traders_north') }}
    stage_region_traders_north

LEFT JOIN current_rows

    ON stage_region_traders_north.hk_h_region
       = current_rows.hk_h_region

WHERE NOT EXISTS (

    SELECT 1

    FROM {{ this }} s_region_lroc_traders_north

    WHERE stage_region_traders_north.hk_h_region
          = s_region_lroc_traders_north.hk_h_region

      AND stage_region_traders_north.dss_change_hash_region_lroc_traders_north
          = s_region_lroc_traders_north.dss_change_hash

      AND current_rows.dss_start_date
          = s_region_lroc_traders_north.dss_start_date

)

{% else %}

SELECT DISTINCT

    hk_h_region,

    regiondescription,

    dss_change_hash_region_lroc_traders_north AS dss_change_hash,

    dss_record_source,

    dss_load_date,

    CURRENT_TIMESTAMP() AS dss_start_date,

    1 AS dss_version,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('stage_region_traders_north') }}

{% endif %}