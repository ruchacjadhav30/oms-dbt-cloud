{{
    config(
        materialized = 'table'
    )
}}

select
      stage_product_sales2.product_id
    , stage_product_sales2.product_code
    , stage_product_sales2.product_name
    , stage_product_sales2.product_description
    , stage_product_sales2.product_line_code
    , stage_product_sales2.product_line_description
    , stage_product_sales2.sales_source
    , stage_product_sales2.product_group_code
    , stage_product_sales2.product_group_description
    , stage_product_sales2.product_sub_group_code
    , stage_product_sales2.product_sub_group_description
    , stage_product_sales2.barcode_value
    , stage_product_sales2.vendor_id
    , stage_product_sales2.dimension_uom
    , stage_product_sales2.dimension_1
    , stage_product_sales2.dimension_2
    , stage_product_sales2.dimension_3
    , stage_product_sales2.volume_uom
    , stage_product_sales2.volume
    , stage_product_sales2.weight_uom
    , stage_product_sales2.weight
    , stage_product_sales2.auto_reorder_flag
    , stage_product_sales2.auto_reorder_amount
    , stage_product_sales2.creating_employee_id
    , stage_product_sales2.created_datetime
    , stage_product_sales2.last_change_employee_id
    , stage_product_sales2.last_change_datetime
    , cast('{{ run_started_at }}' as timestamp_ntz) as dss_create_time
    , cast('{{ run_started_at }}' as timestamp_ntz) as dss_update_time

from {{ ref('stage_product_sales2') }} stage_product_sales2

union all

select
      stage_product_sales.product_id
    , stage_product_sales.product_code
    , stage_product_sales.product_name
    , stage_product_sales.product_description
    , stage_product_sales.product_line_code
    , stage_product_sales.product_line_description
    , stage_product_sales.sales_source
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
    , cast('{{ run_started_at }}' as timestamp_ntz) as dss_create_time
    , cast('{{ run_started_at }}' as timestamp_ntz) as dss_update_time

from {{ ref('stage_product_sales') }} stage_product_sales