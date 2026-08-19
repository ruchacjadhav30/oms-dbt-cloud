{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH south_territories AS (

    SELECT DISTINCT
        hk_h_territory,
        territory_id,
        dss_record_source,
        dss_load_date
    FROM {{ ref('stage_territory_traders_south') }}

),

north_territories AS (

    SELECT DISTINCT
        hk_h_territory,
        territory_id,
        dss_record_source,
        dss_load_date
    FROM {{ ref('stage_territory_traders_north') }}

),

south_new_territories AS (

    SELECT
        hk_h_territory,
        territory_id,
        dss_record_source,
        dss_load_date
    FROM south_territories

    {% if is_incremental() %}

    WHERE NOT EXISTS (
        SELECT 1
        FROM {{ this }} h_territory
        WHERE south_territories.territory_id = h_territory.territory_id
    )

    {% endif %}

),

north_new_territories AS (

    SELECT
        north.hk_h_territory,
        north.territory_id,
        north.dss_record_source,
        north.dss_load_date

    FROM north_territories north

    WHERE NOT EXISTS (
        SELECT 1
        FROM south_territories south
        WHERE north.territory_id = south.territory_id
    )

    {% if is_incremental() %}

    AND NOT EXISTS (
        SELECT 1
        FROM {{ this }} h_territory
        WHERE north.territory_id = h_territory.territory_id
    )

    {% endif %}

)

SELECT
    hk_h_territory,
    territory_id,
    dss_record_source,
    dss_load_date,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM south_new_territories

UNION ALL

SELECT
    hk_h_territory,
    territory_id,
    dss_record_source,
    dss_load_date,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM north_new_territories