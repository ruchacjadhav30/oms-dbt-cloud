{{ config(
    materialized='incremental'
) }}

WITH current_rows AS (

    {% if is_incremental() %}

        SELECT
            hk_h_supplier,
            MAX(dss_start_date) AS dss_start_date,
            MAX(dss_version) AS dss_version
        FROM {{ this }}
        GROUP BY hk_h_supplier

    {% else %}

        SELECT
            NULL AS hk_h_supplier,
            NULL AS dss_start_date,
            NULL AS dss_version
        WHERE 1 = 0

    {% endif %}

)

SELECT DISTINCT

    stage_supplier_traders_north.hk_h_supplier
        AS hk_h_supplier,

    stage_supplier_traders_north.country
        AS country,

    stage_supplier_traders_north.supplierid
        AS supplierid,

    stage_supplier_traders_north.address
        AS address,

    stage_supplier_traders_north.city
        AS city,

    stage_supplier_traders_north.region
        AS region,

    stage_supplier_traders_north.postalcode
        AS postalcode,

    stage_supplier_traders_north.dss_change_hash_supplier_lroc_traders_north
        AS dss_change_hash,

    stage_supplier_traders_north.dss_record_source
        AS dss_record_source,

    stage_supplier_traders_north.dss_load_date
        AS dss_load_date,

    CURRENT_TIMESTAMP()
        AS dss_start_date,

    {% if is_incremental() %}

        COALESCE(current_rows.dss_version, 0) + 1

    {% else %}

        1

    {% endif %}
        AS dss_version,

    CURRENT_TIMESTAMP()
        AS dss_create_time

FROM {{ ref('stage_supplier_traders_north') }}
    AS stage_supplier_traders_north

LEFT JOIN current_rows
    ON stage_supplier_traders_north.hk_h_supplier
        = current_rows.hk_h_supplier

{% if is_incremental() %}

WHERE NOT EXISTS (

    SELECT 1

    FROM {{ this }}
        AS s_supplier_lroc_traders_north

    WHERE stage_supplier_traders_north.hk_h_supplier
            = s_supplier_lroc_traders_north.hk_h_supplier

        AND stage_supplier_traders_north.dss_change_hash_supplier_lroc_traders_north
            = s_supplier_lroc_traders_north.dss_change_hash

        AND current_rows.dss_start_date
            = s_supplier_lroc_traders_north.dss_start_date

)

{% endif %}