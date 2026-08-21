{{
    config(
        materialized='incremental'
    )
}}

SELECT DISTINCT
    stage_supplier_traders_south.hk_h_supplier
        AS hk_h_supplier,

    stage_supplier_traders_south.contactname
        AS contactname,

    stage_supplier_traders_south.contacttitle
        AS contacttitle,

    stage_supplier_traders_south.phone
        AS phone,

    stage_supplier_traders_south.fax
        AS fax,

    stage_supplier_traders_south.dss_change_hash_supplier_mroc_traders_south
        AS dss_change_hash,

    stage_supplier_traders_south.dss_record_source
        AS dss_record_source,

    stage_supplier_traders_south.dss_load_date
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

FROM {{ ref('stage_supplier_traders_south') }}
    AS stage_supplier_traders_south

{% if is_incremental() %}

LEFT OUTER JOIN (

    SELECT
        hk_h_supplier,
        MAX(dss_start_date) AS dss_start_date,
        MAX(dss_version) AS dss_version

    FROM {{ this }}

    GROUP BY hk_h_supplier

) AS current_rows

    ON stage_supplier_traders_south.hk_h_supplier
        = current_rows.hk_h_supplier

WHERE NOT EXISTS (

    SELECT 1

    FROM {{ this }} AS s_supplier_mroc_traders_south

    WHERE stage_supplier_traders_south.hk_h_supplier
            = s_supplier_mroc_traders_south.hk_h_supplier

      AND stage_supplier_traders_south.dss_change_hash_supplier_mroc_traders_south
            = s_supplier_mroc_traders_south.dss_change_hash

      AND current_rows.dss_start_date
            = s_supplier_mroc_traders_south.dss_start_date

)

{% endif %}