{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH south_regions AS (

    SELECT DISTINCT
        hk_h_region,
        region_id,
        dss_record_source,
        dss_load_date
    FROM {{ ref('stage_region_traders_south') }}

),

north_regions AS (

    SELECT DISTINCT
        hk_h_region,
        region_id,
        dss_record_source,
        dss_load_date
    FROM {{ ref('stage_region_traders_north') }}

),

south_new_regions AS (

    SELECT
        hk_h_region,
        region_id,
        dss_record_source,
        dss_load_date
    FROM south_regions

    {% if is_incremental() %}

    WHERE NOT EXISTS (
        SELECT 1
        FROM {{ this }} h_region
        WHERE south_regions.region_id = h_region.region_id
    )

    {% endif %}

),

north_new_regions AS (

    SELECT
        north.hk_h_region,
        north.region_id,
        north.dss_record_source,
        north.dss_load_date

    FROM north_regions north

    WHERE NOT EXISTS (
        SELECT 1
        FROM south_regions south
        WHERE north.region_id = south.region_id
    )

    {% if is_incremental() %}

    AND NOT EXISTS (
        SELECT 1
        FROM {{ this }} h_region
        WHERE north.region_id = h_region.region_id
    )

    {% endif %}

)

SELECT
    hk_h_region,
    region_id,
    dss_record_source,
    dss_load_date,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM south_new_regions

UNION ALL

SELECT
    hk_h_region,
    region_id,
    dss_record_source,
    dss_load_date,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM north_new_regions