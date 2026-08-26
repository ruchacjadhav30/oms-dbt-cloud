{{
    config(
        materialized = 'table'
    )
}}

select
      load_product.product_id
    , load_product.product_code
    , load_product.product_name
    , load_product.product_description
    , load_product.product_line_code
    , load_product_line.product_line_description
    , 2 as sales_source
    , load_product.product_group_code
    , load_product_group.product_group_description
    , load_product.product_sub_group_code
    , load_product_sub_group.product_sub_group_description
    , load_product.barcode_value
    , load_product.vendor_id
    , load_product.dimension_uom
    , load_product.dimension_1
    , load_product.dimension_2
    , load_product.dimension_3
    , load_product.volume_uom
    , load_product.volume
    , load_product.weight_uom
    , load_product.weight
    , load_product.auto_reorder_flag
    , load_product.auto_reorder_amount
    , load_product.creating_employee_id
    , load_product.created_datetime
    , load_product.last_change_employee_id
    , load_product.last_change_datetime
    , cast('{{ run_started_at }}' as timestamp_ntz) as dss_create_time
    , cast('{{ run_started_at }}' as timestamp_ntz) as dss_update_time

from {{ source('dimensional_raw', 'LOAD_PRODUCT') }} load_product

join {{ source('dimensional_raw', 'LOAD_PRODUCT_LINE') }} load_product_line
    on load_product.product_line_code = load_product_line.product_line_code

join {{ source('dimensional_raw', 'LOAD_PRODUCT_GROUP') }} load_product_group
    on load_product.product_group_code = load_product_group.product_group_code

join {{ source('dimensional_raw', 'LOAD_PRODUCT_SUB_GROUP') }} load_product_sub_group
    on load_product.product_group_code = load_product_sub_group.product_group_code
   and load_product.product_sub_group_code = load_product_sub_group.product_sub_group_code