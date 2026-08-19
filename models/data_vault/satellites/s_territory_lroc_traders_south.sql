{{
    config(
        materialized='incremental',
        incremental_strategy='append'
    )
}}

{% if is_incremental() %}

WITH current_rows AS (

    SELECT
        hk_h_territory,
        MAX(dss_start_date) AS dss_start_date,
        MAX(dss_version) AS dss_version
    FROM {{ this }}
    GROUP BY hk_h_territory

)

SELECT DISTINCT
    stage_territory_traders_south.hk_h_territory AS hk_h_territory,
    stage_territory_traders_south.territorydescription AS territorydescription,
    stage_territory_traders_south.dss_change_hash_territory_lroc_traders_south AS dss_change_hash,
    stage_territory_traders_south.dss_record_source AS dss_record_source,
    stage_territory_traders_south.dss_load_date AS dss_load_date,
    CURRENT_TIMESTAMP() AS dss_start_date,
    COALESCE(current_rows.dss_version, 0) + 1 AS dss_version,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('stage_territory_traders_south') }} stage_territory_traders_south

LEFT JOIN current_rows
    ON stage_territory_traders_south.hk_h_territory =
       current_rows.hk_h_territory

WHERE NOT EXISTS (
    SELECT 1
    FROM {{ this }} s_territory_lroc_traders_south
    WHERE stage_territory_traders_south.hk_h_territory =
          s_territory_lroc_traders_south.hk_h_territory
      AND stage_territory_traders_south.dss_change_hash_territory_lroc_traders_south =
          s_territory_lroc_traders_south.dss_change_hash
      AND current_rows.dss_start_date =
          s_territory_lroc_traders_south.dss_start_date
)

{% else %}

SELECT DISTINCT
    hk_h_territory,
    territorydescription,
    dss_change_hash_territory_lroc_traders_south AS dss_change_hash,
    dss_record_source,
    dss_load_date,
    CURRENT_TIMESTAMP() AS dss_start_date,
    1 AS dss_version,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('stage_territory_traders_south') }}

{% endif %}