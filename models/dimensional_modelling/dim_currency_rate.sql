{{
    config(
        materialized        = 'incremental',
        incremental_strategy = 'merge',
        unique_key           = ['originating_currency_code',
                                 'destination_currency_code',
                                 'effective_from_date'],
        merge_exclude_columns = ['dss_create_time']
    )
}}

with stage_currency_rate as (

    select
        originating_currency_code,
        destination_currency_code,
        effective_from_date,
        thru_date,
        exchange_rate,
        exchange_rate_multiplier,
        creating_employee_id,
        created_datetime,
        last_change_employee_id,
        last_change_datetime
    FROM {{ ref('stage_currency_rate') }} stage_currency_rate

)

{% if is_incremental() %}

, dim_currency_rate as (

    select
        originating_currency_code,
        destination_currency_code,
        effective_from_date,
        thru_date,
        exchange_rate,
        exchange_rate_multiplier,
        creating_employee_id,
        created_datetime,
        last_change_employee_id,
        last_change_datetime
    from {{ this }}

)

, changes as (

    -- mirrors the original: only rows in stage that differ from
    -- (or don't yet exist in) the target are candidates for merge
    select * from stage_currency_rate
    except
    select * from dim_currency_rate

)

{% endif %}

select
    originating_currency_code,
    destination_currency_code,
    effective_from_date,
    thru_date,
    exchange_rate,
    exchange_rate_multiplier,
    creating_employee_id,
    created_datetime,
    last_change_employee_id,
    last_change_datetime,
    cast('{{ run_started_at }}' as timestamp_ntz) as dss_create_time,
    cast('{{ run_started_at }}' as timestamp_ntz) as dss_update_time

from
    {% if is_incremental() %}
        changes
    {% else %}
        stage_currency_rate
    {% endif %}