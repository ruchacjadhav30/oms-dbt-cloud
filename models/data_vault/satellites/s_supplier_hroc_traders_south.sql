{{
    config(
        materialized='incremental'
    )
}}

WITH stage_rows AS (

    SELECT DISTINCT
        hk_h_supplier,
        homepage,
        dss_change_hash_supplier_hroc_traders_south AS dss_change_hash,
        dss_record_source,
        dss_load_date

    FROM {{ ref('stage_supplier_traders_south') }}

),

{% if is_incremental() %}

current_rows AS (

    SELECT
        hk_h_supplier,
        MAX(dss_start_date) AS dss_start_date,
        MAX(dss_version) AS dss_version

    FROM {{ this }}

    GROUP BY hk_h_supplier

)

{% else %}

current_rows AS (

    SELECT
        CAST(NULL AS VARCHAR) AS hk_h_supplier,
        CAST(NULL AS TIMESTAMP) AS dss_start_date,
        CAST(NULL AS INTEGER) AS dss_version

    WHERE 1 = 0

)

{% endif %}

SELECT
    stage_rows.hk_h_supplier,
    stage_rows.homepage,
    stage_rows.dss_change_hash,
    stage_rows.dss_record_source,
    stage_rows.dss_load_date,

    CURRENT_TIMESTAMP() AS dss_start_date,

    COALESCE(current_rows.dss_version, 0) + 1
        AS dss_version,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM stage_rows

LEFT JOIN current_rows
    ON stage_rows.hk_h_supplier = current_rows.hk_h_supplier

{% if is_incremental() %}

WHERE NOT EXISTS (

    SELECT 1
    FROM {{ this }} s_supplier_hroc_traders_south

    WHERE stage_rows.hk_h_supplier =
            s_supplier_hroc_traders_south.hk_h_supplier

      AND stage_rows.dss_change_hash =
            s_supplier_hroc_traders_south.dss_change_hash

      AND current_rows.dss_start_date =
            s_supplier_hroc_traders_south.dss_start_date

)

{% endif %}