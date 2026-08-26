{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = [
            'product_id',
            'sales_source'
        ],
        merge_exclude_columns = ['dss_create_time']
    )
}}

with stage_product_data as (

    select
          stage_product_sales.product_id
        , stage_product_sales.product_code
        , stage_product_sales.product_name
        , stage_product_sales.product_description
        , stage_product_sales.product_line_code
        , stage_product_mrg.sales_source
        , stage_product_sales.product_line_description
        , stage_product_sales.product_group_code
        , stage_product_sales.product_group_description
        , stage_product_sales.product_sub_group_code
        , stage_product_sales.product_sub_group_description
        , stage_product_sales.barcode_value
        , stage_product_sales.vendor_id
        , stage_product_sales.dimension_uom
        , stage_product_sales.dimension_1
        , stage_product_sales.dimension_2
        , stage_product_sales.dimension_3
        , stage_product_sales.volume_uom
        , stage_product_sales.volume
        , stage_product_sales.weight_uom
        , stage_product_sales.weight
        , stage_product_sales.auto_reorder_flag
        , stage_product_sales.auto_reorder_amount
        , stage_product_sales.creating_employee_id
        , stage_product_sales.created_datetime
        , stage_product_sales.last_change_employee_id
        , stage_product_sales.last_change_datetime

    from {{ ref('stage_product_mrg') }} stage_product_mrg

    join {{ ref('stage_product_sales') }} stage_product_sales
        on stage_product_mrg.product_id = stage_product_sales.product_id

)

{% if is_incremental() %}

, dim_product as (

    select
          product_id
        , product_code
        , product_name
        , product_description
        , product_line_code
        , sales_source
        , product_line_description
        , product_group_code
        , product_group_description
        , product_sub_group_code
        , product_sub_group_description
        , barcode_value
        , vendor_id
        , dimension_uom
        , dimension_1
        , dimension_2
        , dimension_3
        , volume_uom
        , volume
        , weight_uom
        , weight
        , auto_reorder_flag
        , auto_reorder_amount
        , creating_employee_id
        , created_datetime
        , last_change_employee_id
        , last_change_datetime

    from {{ this }}

)

, changes as (

    select * from stage_product_data

    except

    select * from dim_product

)

{% endif %}

select
      product_id
    , product_code
    , product_name
    , product_description
    , product_line_code
    , sales_source
    , product_line_description
    , product_group_code
    , product_group_description
    , product_sub_group_code
    , product_sub_group_description
    , barcode_value
    , vendor_id
    , dimension_uom
    , dimension_1
    , dimension_2
    , dimension_3
    , volume_uom
    , volume
    , weight_uom
    , weight
    , auto_reorder_flag
    , auto_reorder_amount
    , creating_employee_id
    , created_datetime
    , last_change_employee_id
    , last_change_datetime
    , cast('{{ run_started_at }}' as timestamp_ntz) as dss_create_time
    , cast('{{ run_started_at }}' as timestamp_ntz) as dss_update_time

from
    {% if is_incremental() %}
        changes
    {% else %}
        stage_product_data
    {% endif %}