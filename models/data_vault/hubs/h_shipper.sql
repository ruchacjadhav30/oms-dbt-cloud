{{ config(
    materialized='incremental'
) }}

WITH source_shippers AS (

    SELECT DISTINCT
        hk_h_shipper,
        shipper_name,
        dss_record_source,
        dss_load_date,
        CURRENT_TIMESTAMP() AS dss_create_time
    FROM {{ ref('stage_shipper_traders_south') }}

    UNION ALL

    SELECT DISTINCT
        hk_h_shipper,
        shipper_name,
        dss_record_source,
        dss_load_date,
        CURRENT_TIMESTAMP() AS dss_create_time
    FROM {{ ref('stage_shipper_traders_north') }}

),

deduplicated AS (

    SELECT
        hk_h_shipper,
        shipper_name,
        dss_record_source,
        dss_load_date,
        dss_create_time

    FROM source_shippers

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY shipper_name
        ORDER BY dss_load_date
    ) = 1

)

SELECT
    hk_h_shipper,
    shipper_name,
    dss_record_source,
    dss_load_date,
    dss_create_time

FROM deduplicated

{% if is_incremental() %}

WHERE NOT EXISTS (
    SELECT 1
    FROM {{ this }} AS h
    WHERE deduplicated.shipper_name = h.shipper_name
)

{% endif %}