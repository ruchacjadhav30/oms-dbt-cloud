{{ config(
    materialized='table'
) }}

SELECT
      stage_country.name AS name
    , stage_country.alpha_2 AS alpha_2
    , stage_country.alpha_3 AS alpha_3
    , stage_country.country_code AS country_code
    , stage_country.iso_3166_2 AS iso_3166_2
    , stage_country.region AS region
    , stage_country.sub_region AS sub_region
    , stage_country.region_code AS region_code
    , stage_country.sub_region_code AS sub_region_code
    , stage_country.dss_record_source AS dss_record_source
    , stage_country.dss_load_date AS dss_load_date
    , CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('stage_country') }} stage_country