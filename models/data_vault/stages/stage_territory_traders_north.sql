SELECT
    MD5(
        COALESCE(CAST(territoryid AS VARCHAR), 'null')
    ) AS hk_h_territory,

    territoryid AS territory_id,

    territorydescription,

    MD5(
        COALESCE(CAST(territorydescription AS VARCHAR), 'null')
    ) AS dss_change_hash_territory_lroc_traders_north,

    dss_record_source,

    dss_load_date,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ source('sleekmart_raw', 'LOAD_TERRITORIES_TRADERS_NORTH') }}