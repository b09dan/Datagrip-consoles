
----------------------------- Тут начинается вычленение типа клиента body/tail -----------------------------
SELECT
  aff_id,
  option_type_id,
  pnl,
  trade_date,
  reg_date,
  (CASE
    WHEN month_from_reg > 1  THEN 'tail'
    WHEN month_from_reg <= 1  THEN 'body'
  END) AS tail_or_body_new,
  month_from_reg
FROM(
  SELECT
    aff_id,
    option_type_id,
    pnl,
    trade_date,
    reg_date,
    (DATE_PART('year', trade_date::date) - DATE_PART('year', reg_date::date)) * 12 +
    (DATE_PART('month', trade_date::date) - DATE_PART('month', reg_date::date)) AS month_from_reg
  FROM(
    ----------------------------- Тут начинается сочленение типов активов -----------------------------
    (
      SELECT
        aff_id,
        option_type_id,
        stat_real_deals_data.deal_amount - stat_real_deals_data.win_amount AS pnl,
        DATE(DATE_TRUNC('MONTH', stat_real_deals_data.buy_time)) AS trade_date,
        DATE(DATE_TRUNC('MONTH', stat_real_deals_data.registration_date)) AS reg_date
      FROM
        stat_real_deals_data
        -- WHERE
        -- to_timestamp(stat_real_deals_data.exp_time::double precision)::date >= '12-01-2017'
        -- AND to_timestamp(stat_real_deals_data.exp_time::double precision)::date <= '12-31-2017'
      LIMIT 100
    )
    UNION ALL
    (
      SELECT
        aff_id,
        option_type_id,
        stat_real_deals_data_instruments.deal_amount - stat_real_deals_data_instruments.win_amount AS pnl,
        DATE(DATE_TRUNC('MONTH', stat_real_deals_data_instruments.exp_time)) AS trade_date,
        DATE(DATE_TRUNC('MONTH', stat_real_deals_data_instruments.registration_date)) AS reg_date
      FROM
        stat_real_deals_data_instruments
      WHERE
        stat_real_deals_data_instruments.option_type_id <> 10
        -- AND stat_real_deals_data_instruments.exp_time::date >= '12-01-2017'
        -- AND stat_real_deals_data_instruments.exp_time::date <= '12-31-2017'
      LIMIT 100
    )
    UNION ALL
    (
      SELECT
        aff_id,
        667 as option_type_id,
        temp_orders.commission_amount_enrolled_without_token AS pnl,
        DATE(DATE_TRUNC('MONTH', temp_orders.create_at)) AS trade_date,
        DATE(DATE_TRUNC('MONTH', u.created)) AS reg_date
      FROM
        temp_orders
      JOIN
        users u on temp_orders.user_id=u.user_id
      WHERE
        temp_orders.user_balance_type = 1
        AND temp_orders.status = 'filled'::text
        -- AND temp_orders.create_at::date >= '12-01-2017'
        -- AND temp_orders.create_at::date <= '12-31-2017'
      LIMIT 100
    )
    UNION ALL
    (
      SELECT
        aff_id,
        666 as option_type_id,
        temp_orders_archive.commission_amount_enrolled_without_token AS pnl,
        DATE(DATE_TRUNC('MONTH', temp_orders_archive.create_at)) AS trade_date,
        DATE(DATE_TRUNC('MONTH', u.created)) AS reg_date
      FROM
        temp_orders_archive
      JOIN
        users u on temp_orders_archive.user_id=u.user_id
      WHERE
        temp_orders_archive.user_balance_type = 1
        AND temp_orders_archive.status = 'filled'::text
        AND temp_orders_archive.client_platform_id <> 0 --
        AND temp_orders_archive.instrument_type in ('crypto','cfd')
        -- AND temp_orders_archive.create_at::date >= '12-01-2017'
        -- AND temp_orders_archive.create_at::date <= '12-31-2017'
      LIMIT 100
    )
    ----------------------------- Тут заканчивается сочленение типов активов -----------------------------
    ) AS stat_real_deals_data_pnl) AS stat_real_deals_data_pnl_new
----------------------------- Тут заканчивается вычленение типа клиента body/tail -----------------------------