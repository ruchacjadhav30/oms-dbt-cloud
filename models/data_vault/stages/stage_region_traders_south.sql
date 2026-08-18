SELECT

    MD5(
        COALESCE(CAST(regionid AS VARCHAR), 'null')
    ) AS hk_h_region,

    regionid AS region_id,

    regiondescription,

    MD5(
        COALESCE(CAST(regiondescription AS VARCHAR), 'null')
    ) AS dss_change_hash_region_lroc_traders_south,

    dss_record_source,

    dss_load_date,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ source(
    'sleekmart_raw',
    'LOAD_REGION_TRADERS_SOUTH'
) }}