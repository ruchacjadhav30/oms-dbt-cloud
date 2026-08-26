{{
    config(
        materialized = 'table'
    )
}}

select
      load_product_sales2.product_id
    , load_product_sales2.product_code
    , load_product_sales2.product_name
    , load_product_sales2.product_description
    , load_product_sales2.product_line_code
    , load_product_line_sales2.product_line_description
    , 3 as sales_source
    , load_product_sales2.product_group_code
    , load_product_group_sales2.product_group_description
    , load_product_sales2.product_sub_group_code
    , load_product_sub_group_sales2.product_sub_group_description
    , load_product_sales2.barcode_value
    , load_product_sales2.vendor_id
    , load_product_sales2.dimension_uom
    , load_product_sales2.dimension_1
    , load_product_sales2.dimension_2
    , load_product_sales2.dimension_3
    , load_product_sales2.volume_uom
    , load_product_sales2.volume
    , load_product_sales2.weight_uom
    , load_product_sales2.weight
    , load_product_sales2.auto_reorder_flag
    , load_product_sales2.auto_reorder_amount
    , load_product_sales2.creating_employee_id
    , load_product_sales2.created_datetime
    , load_product_sales2.last_change_employee_id
    , load_product_sales2.last_change_datetime
    , cast('{{ run_started_at }}' as timestamp_ntz) as dss_create_time
    , cast('{{ run_started_at }}' as timestamp_ntz) as dss_update_time

from {{ source('dimensional_raw', 'LOAD_PRODUCT_SALES2') }} load_product_sales2

join {{ source('dimensional_raw', 'LOAD_PRODUCT_LINE_SALES2') }} load_product_line_sales2
    on load_product_sales2.product_line_code = load_product_line_sales2.product_line_code

join {{ source('dimensional_raw', 'LOAD_PRODUCT_GROUP_SALES2') }} load_product_group_sales2
    on load_product_sales2.product_group_code = load_product_group_sales2.product_group_code

join {{ source('dimensional_raw', 'LOAD_PRODUCT_SUB_GROUP_SALES2') }} load_product_sub_group_sales2
    on load_product_sales2.product_sub_group_code = load_product_sub_group_sales2.product_sub_group_code
   and load_product_sales2.product_group_code = load_product_sub_group_sales2.product_group_code