{{
    config(
        materialized='incremental',
        incremental_strategy='append'
    )
}}

WITH current_rows AS (

    {% if is_incremental() %}

    SELECT
        hk_h_territory,
        MAX(dss_start_date) AS dss_start_date,
        MAX(dss_version) AS dss_version

    FROM {{ this }}

    GROUP BY hk_h_territory

    {% else %}

    SELECT
        CAST(NULL AS VARCHAR) AS hk_h_territory,
        CAST(NULL AS TIMESTAMP) AS dss_start_date,
        CAST(NULL AS NUMBER) AS dss_version

    WHERE FALSE

    {% endif %}

)

SELECT DISTINCT

    stage_territory_traders_north.hk_h_territory
        AS hk_h_territory,

    stage_territory_traders_north.territorydescription
        AS territorydescription,

    stage_territory_traders_north.dss_change_hash_territory_lroc_traders_north
        AS dss_change_hash,

    stage_territory_traders_north.dss_record_source
        AS dss_record_source,

    stage_territory_traders_north.dss_load_date
        AS dss_load_date,

    CURRENT_TIMESTAMP()
        AS dss_start_date,

    COALESCE(current_rows.dss_version, 0) + 1
        AS dss_version,

    CURRENT_TIMESTAMP()
        AS dss_create_time

FROM {{ ref('stage_territory_traders_north') }}
    AS stage_territory_traders_north

LEFT JOIN current_rows

    ON stage_territory_traders_north.hk_h_territory
       = current_rows.hk_h_territory

{% if is_incremental() %}

WHERE NOT EXISTS (

    SELECT 1

    FROM {{ this }} AS s_territory_lroc_traders_north

    WHERE stage_territory_traders_north.hk_h_territory
          = s_territory_lroc_traders_north.hk_h_territory

      AND stage_territory_traders_north.dss_change_hash_territory_lroc_traders_north
          = s_territory_lroc_traders_north.dss_change_hash

      AND current_rows.dss_start_date
          = s_territory_lroc_traders_north.dss_start_date

)

{% endif %}