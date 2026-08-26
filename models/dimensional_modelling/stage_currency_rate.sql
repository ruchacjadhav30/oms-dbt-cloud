{{ config(
    materialized='table'
) }}

SELECT
      load_currency_rate.originating_currency_code
    , load_currency_rate.destination_currency_code
    , load_currency_rate.effective_from_date
    , load_currency_rate.thru_date
    , load_currency_rate.exchange_rate
    , load_currency_rate.exchange_rate_multiplier
    , load_currency_rate.creating_employee_id
    , load_currency_rate.created_datetime
    , load_currency_rate.last_change_employee_id
    , load_currency_rate.last_change_datetime
    , CURRENT_TIMESTAMP() AS dss_create_time
    , CURRENT_TIMESTAMP() AS dss_update_time

FROM {{ source('dimensional_raw', 'LOAD_CURRENCY_RATE') }} load_currency_rate