SELECT
    MD5(
        COALESCE(
            CAST(companyname AS VARCHAR),
            'null'
        )
    ) AS hk_h_shipper,

    companyname AS shipper_name,

    shipperid,

    phone,

    MD5(
        COALESCE(CAST(shipperid AS VARCHAR), 'null')
        || '||' ||
        COALESCE(CAST(phone AS VARCHAR), 'null')
    ) AS dss_change_hash_shipper_lroc_traders_south,

    dss_record_source,

    dss_load_date,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ source(
    'sleekmart_raw',
    'LOAD_SHIPPERS_TRADERS_SOUTH'
) }}