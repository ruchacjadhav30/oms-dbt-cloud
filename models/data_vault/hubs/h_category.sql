{{ config(
    materialized='incremental',
    unique_key='category_name'
) }}

WITH south_categories AS (

    SELECT DISTINCT
        hk_h_category,
        category_name,
        dss_record_source,
        dss_load_date
    FROM {{ ref('stage_category_traders_south') }}

),

north_categories AS (

    SELECT DISTINCT
        hk_h_category,
        category_name,
        dss_record_source,
        dss_load_date
    FROM {{ ref('stage_category_traders_north') }}

),

category_sources AS (

    -- South is processed first, matching the original SQL logic
    SELECT
        hk_h_category,
        category_name,
        dss_record_source,
        dss_load_date,
        1 AS source_priority
    FROM south_categories

    UNION ALL

    SELECT
        hk_h_category,
        category_name,
        dss_record_source,
        dss_load_date,
        2 AS source_priority
    FROM north_categories

),

deduplicated_categories AS (

    SELECT
        hk_h_category,
        category_name,
        dss_record_source,
        dss_load_date
    FROM category_sources

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY category_name
        ORDER BY source_priority, dss_load_date
    ) = 1

)

SELECT
    hk_h_category,
    category_name,
    dss_record_source,
    dss_load_date,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM deduplicated_categories

{% if is_incremental() %}

WHERE NOT EXISTS (
    SELECT 1
    FROM {{ this }} existing
    WHERE existing.category_name = deduplicated_categories.category_name
)

{% endif %}