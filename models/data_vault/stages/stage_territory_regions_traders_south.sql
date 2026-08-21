{{ config(
    materialized='table'
) }}

SELECT

    MD5(
        COALESCE(
            CAST(load_territories_traders_south.regionid AS VARCHAR),
            'null'
        )
        || '||' ||
        COALESCE(
            CAST(load_territories_traders_south.territoryid AS VARCHAR),
            'null'
        )
    ) AS hk_l_territory_regions,

    MD5(
        COALESCE(
            CAST(load_territories_traders_south.regionid AS VARCHAR),
            'null'
        )
    ) AS hk_h_region,

    MD5(
        COALESCE(
            CAST(load_territories_traders_south.territoryid AS VARCHAR),
            'null'
        )
    ) AS hk_h_territory,

    load_territories_traders_south.regionid
        AS region_id,

    load_territories_traders_south.territoryid
        AS territory_id,

    load_territories_traders_south.dss_record_source
        AS dss_record_source,

    load_territories_traders_south.dss_load_date
        AS dss_load_date,

    CURRENT_TIMESTAMP()
        AS dss_create_time

FROM {{ source('sleekmart_raw', 'LOAD_TERRITORIES_TRADERS_SOUTH') }}
    AS load_territories_traders_south