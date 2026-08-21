{{
    config(
        materialized='incremental'
    )
}}

WITH south_rows AS (

    SELECT DISTINCT
        hk_h_territory,
        territory_id,
        dss_record_source,
        dss_load_date
    FROM {{ ref('stage_territory_traders_south') }}

),

north_rows AS (

    SELECT DISTINCT
        north.hk_h_territory,
        north.territory_id,
        north.dss_record_source,
        north.dss_load_date
    FROM {{ ref('stage_territory_traders_north') }} north

    WHERE NOT EXISTS (

        SELECT 1
        FROM south_rows south
        WHERE north.territory_id = south.territory_id

    )

),

combined_rows AS (

    SELECT
        hk_h_territory,
        territory_id,
        dss_record_source,
        dss_load_date
    FROM south_rows

    UNION ALL

    SELECT
        hk_h_territory,
        territory_id,
        dss_record_source,
        dss_load_date
    FROM north_rows

)

SELECT
    combined_rows.hk_h_territory,
    combined_rows.territory_id,
    combined_rows.dss_record_source,
    combined_rows.dss_load_date,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM combined_rows

{% if is_incremental() %}

WHERE NOT EXISTS (

    SELECT 1
    FROM {{ this }} h_territory
    WHERE combined_rows.territory_id = h_territory.territory_id

)

{% endif %}