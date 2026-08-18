SELECT
    MD5(
        COALESCE(CAST(categoryname AS VARCHAR), 'null')
    ) AS hk_h_category,

    categoryname AS category_name,

    categoryid,

    description,

    MD5(
        COALESCE(CAST(categoryid AS VARCHAR), 'null')
        || '||' ||
        COALESCE(CAST(description AS VARCHAR), 'null')
    ) AS dss_change_hash_category_lroc_traders_north,

    dss_record_source,

    dss_load_date,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ source(
    'sleekmart_raw',
    'LOAD_CATEGORIES_TRADERS_NORTH'
) }}