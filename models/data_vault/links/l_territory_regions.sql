{{ config(
    materialized='incremental'
) }}

WITH stage_territory_regions_traders_south AS (

    SELECT *
    FROM {{ ref('stage_territory_regions_traders_south') }}

),

stage_territory_regions_traders_north AS (

    SELECT *
    FROM {{ ref('stage_territory_regions_traders_north') }}

),

south_records AS (

    SELECT DISTINCT
        hk_l_territory_regions,
        hk_h_region,
        hk_h_territory,
        dss_record_source,
        dss_load_date,
        CURRENT_TIMESTAMP() AS dss_create_time

    FROM stage_territory_regions_traders_south

    {% if is_incremental() %}

    WHERE NOT EXISTS (

        SELECT 1
        FROM {{ this }} AS l_territory_regions

        WHERE stage_territory_regions_traders_south.hk_h_region
            = l_territory_regions.hk_h_region

        AND stage_territory_regions_traders_south.hk_h_territory
            = l_territory_regions.hk_h_territory

    )

    {% endif %}

),

north_records AS (

    SELECT DISTINCT
        hk_l_territory_regions,
        hk_h_region,
        hk_h_territory,
        dss_record_source,
        dss_load_date,
        CURRENT_TIMESTAMP() AS dss_create_time

    FROM stage_territory_regions_traders_north

    {% if is_incremental() %}

    WHERE NOT EXISTS (

        SELECT 1
        FROM {{ this }} AS l_territory_regions

        WHERE stage_territory_regions_traders_north.hk_h_region
            = l_territory_regions.hk_h_region

        AND stage_territory_regions_traders_north.hk_h_territory
            = l_territory_regions.hk_h_territory

    )

    {% endif %}

)

SELECT *
FROM south_records

UNION ALL

SELECT *
FROM north_records