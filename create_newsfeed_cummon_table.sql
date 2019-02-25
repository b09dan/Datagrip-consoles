--------------------------------- create_newsfeed_common_table ---------------------------------
-- DROP TABLE IF EXISTS bogdan_temp_newsfeed_common_table;
-- CREATE TABLE bogdan_temp_newsfeed_common_table AS

DROP TABLE IF EXISTS bogdan_temp_newsfeed_common_table_agg;
CREATE TABLE bogdan_temp_newsfeed_common_table_agg AS
SELECT
  user_id,
  date_trunc('week', action_start_date)::DATE AS action_start__week,
  date_part('day',age(action_start_date, action_end_date)) AS action_duration,
  balance_type,
  action_type,
  asset,
  COUNT(action_start_date) AS deals_count,
  SUM(in_amount) AS in_amount_sum,
  SUM(out_amount) AS out_amount_sum,
  AVG(in_amount) AS in_amount_avg,
  AVG(out_amount) AS out_amount_avg,
  percentile_cont(.50) within group (order by in_amount) AS in_amount_median,
  percentile_cont(.50) within group (order by out_amount) AS out_amount_median
FROM
(
  SELECT
    user_id,
    transaction_date AS action_start_date,
    transaction_date AS action_end_date,
    transaction_sum AS in_amount,
    0 AS out_amount,
    (CASE
      WHEN balance_type = 5
      THEN 'crypto' ELSE 'real'
    END) AS balance_type,
    transaction_type::TEXT AS action_type,
    currency::text AS asset
  FROM
    stat_transactions_data
  WHERE
    registration_date > '2017-12-31 00:00:00.00'

  UNION ALL

  SELECT
    user_id,
    buy_time AS action_start_date,
    to_timestamp(exp_time) AS action_end_date,
    deal_amount AS in_amount,
    win_amount AS out_amount,
    'real' AS balance_type,
    (CASE
      WHEN option_type_id = 3
        THEN 'turbo'
      WHEN option_type_id = 1
        THEN 'binary'
      ELSE option_type_id::TEXT
     END) AS action_type,
    assets.name::text AS asset
  FROM
  stat_real_deals_data
  JOIN assets
    ON assets.id = stat_real_deals_data.active_id
  WHERE
    registration_date > '2017-12-31 00:00:00.00'

  UNION ALL

  SELECT
    user_id,
    buy_time AS action_start_date,
    exp_time AS action_end_date,
    deal_amount AS in_amount,
    win_amount AS out_amount,
    'real' AS balance_type,
    (CASE
      WHEN option_type_id = 7
        THEN 'do'
      WHEN option_type_id = 8
        THEN 'cfd'
      WHEN option_type_id = 9
        THEN 'forex'
      WHEN option_type_id = 10
        THEN 'crypto'
      ELSE option_type_id::TEXT
     END) AS action_type,
    assets.name::text AS asset
  FROM stat_real_deals_data_instruments
  JOIN assets
    ON assets.id = stat_real_deals_data_instruments.active_id
  WHERE
    registration_date > '2017-12-31 00:00:00.00'

  UNION ALL

  SELECT
    users.user_id,
    action_start_date,
    action_end_date,
    in_amount,
    out_amount,
    balance_type,
    action_type,
    asset
      FROM public.dblink('host=10.0.30.44 dbname=option_trading user=o_readonly password=jieghu9ke3OonoKe port=5432',
  '
  SELECT * FROM
  (
    SELECT
      user_id,
      create_at             AS action_start_date,
      null                  AS action_end_date,
      (CASE
       WHEN position_type = ''short''
         THEN sell_amount_enrolled / (1000000.0 * leverage)
       WHEN position_type = ''long''
         THEN buy_amount_enrolled / (1000000.0 * leverage)
       END)                 AS in_amount,
      0                     AS out_amount,
      (CASE
       WHEN user_balance_type = 1
         THEN ''real''::TEXT
       WHEN user_balance_type = 4
         THEN ''train''::TEXT
       END)                 AS balance_type,
      instrument_type       AS action_type,
      instrument_id :: text AS asset
    FROM data.positions
  ) as t
  ')
  AS temp_positions(user_id bigint, action_start_date TIMESTAMP, action_end_date TIMESTAMP,
           in_amount numeric, out_amount numeric, balance_type TEXT, action_type TEXT,  asset TEXT)
  INNER JOIN users
    ON users.user_id = temp_positions.user_id
  WHERE users.created > '2017-12-31 00:00:00.00'
) AS bogdan_temp_newsfeed_common_table
GROUP BY
  user_id,
  action_start__week,
  action_duration,
  balance_type,
  action_type,
  asset
;


-- Weekly aggregation
;

  bogdan_temp_newsfeed_common_table

;
DROP TABLE IF EXISTS bogdan_temp_newsfeed_common_table;








-- stat_demo_instruments - !!!не вставлять!!!
-- SELECT
--   user_id,
--   exp_time::DATE,
--   deal_amount AS in_amount,
--   win_amount AS out_amount,
--   '2' AS balance_type, -- ??? Везде ставить train, потому что таблица у нас по demo-акаунтам? или есть Какой-то другой id именно для demo
--   active_id AS action_type,
--   currency_id AS asset --???
-- FROM stat_demo_instruments
-- LIMIT 100





-- Checking number of rows
SELECT
  count(*)
FROM
  bogdan_temp_newsfeed_common_table_agg
--3513670
;



SELECT
  count(*)
FROM bogdan_temp_newsfeed_common_table
;