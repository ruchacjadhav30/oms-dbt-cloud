{{ config(
    materialized='incremental',
    unique_key='hk_h_supplier'
) }}

WITH south_suppliers AS (

    SELECT DISTINCT
        hk_h_supplier,
        supplier_name,
        dss_record_source,
        dss_load_date,
        1 AS source_priority

    FROM {{ ref('stage_supplier_traders_south') }}

),

north_suppliers AS (

    SELECT DISTINCT
        hk_h_supplier,
        supplier_name,
        dss_record_source,
        dss_load_date,
        2 AS source_priority

    FROM {{ ref('stage_supplier_traders_north') }}

),

combined_suppliers AS (

    SELECT * FROM south_suppliers

    UNION ALL

    SELECT * FROM north_suppliers

),

deduplicated_suppliers AS (

    SELECT
        hk_h_supplier,
        supplier_name,
        dss_record_source,
        dss_load_date

    FROM combined_suppliers

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY supplier_name
        ORDER BY source_priority
    ) = 1

)

SELECT
    hk_h_supplier,
    supplier_name,
    dss_record_source,
    dss_load_date,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM deduplicated_suppliers

{% if is_incremental() %}

WHERE NOT EXISTS (

    SELECT 1
    FROM {{ this }} h_supplier

    WHERE deduplicated_suppliers.supplier_name = h_supplier.supplier_name

)

{% endif %}