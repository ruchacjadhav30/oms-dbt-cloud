{{ config(
    materialized='table'
) }}

SELECT
    MD5(
        COALESCE(
            TO_VARCHAR(companyname),
            'null'
        )
    ) AS hk_h_supplier,

    companyname AS supplier_name,

    homepage,

    country,

    supplierid,

    address,

    city,

    region,

    postalcode,

    contactname,

    contacttitle,

    phone,

    fax,

    MD5(
        COALESCE(
            TO_VARCHAR(homepage),
            'null'
        )
    ) AS dss_change_hash_supplier_hroc_traders_south,

    MD5(
        COALESCE(TO_VARCHAR(country), 'null') || '||' ||
        COALESCE(TO_VARCHAR(supplierid), 'null') || '||' ||
        COALESCE(TO_VARCHAR(address), 'null') || '||' ||
        COALESCE(TO_VARCHAR(city), 'null') || '||' ||
        COALESCE(TO_VARCHAR(region), 'null') || '||' ||
        COALESCE(TO_VARCHAR(postalcode), 'null')
    ) AS dss_change_hash_supplier_lroc_traders_south,

    MD5(
        COALESCE(TO_VARCHAR(contactname), 'null') || '||' ||
        COALESCE(TO_VARCHAR(contacttitle), 'null') || '||' ||
        COALESCE(TO_VARCHAR(phone), 'null') || '||' ||
        COALESCE(TO_VARCHAR(fax), 'null')
    ) AS dss_change_hash_supplier_mroc_traders_south,

    dss_record_source,

    dss_load_date,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ source('sleekmart_raw', 'LOAD_SUPPLIERS_TRADERS_SOUTH') }}