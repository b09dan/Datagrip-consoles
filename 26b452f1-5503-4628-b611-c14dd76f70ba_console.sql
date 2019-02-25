----------------------------- stat_real_deals_data -----------------------------
SELECT
  user_id,
  date_month_year,
  transaction_platform,
  aff_track,
  country,
  SUM(transaction_sum) AS transaction_sum_sum
FROM (
SELECT
  user_id,
  to_char(transaction_date, 'YYYY-MM-01')::DATE AS date_month_year,
  transaction_platform,
  aff_track,
  country,
  transaction_sum
FROM
stat_transactions_data
LIMIT 100) AS djdjdj
GROUP BY
  user_id,
  date_month_year,
  transaction_platform,
  aff_track,
  country
;

SELECT *
FROM stat_transactions_data
;



SELECT
  bogdan_temp__stat_real_deals_data.user_id
FROM bogdan_temp__stat_real_deals_data
INNER JOIN bogdan_temp__stat_transactions_data
  ON bogdan_temp__stat_transactions_data.user_id = bogdan_temp__stat_real_deals_data.user_id
WHERE bogdan_temp__stat_real_deals_data.user_id IS NULL;
;


SELECT
  transaction_sum
  FROM
(
  SELECT
    transaction_sum,
    transaction_type
  FROM
  stat_transactions_data
  LIMIT 100000000
  ) AS sksksk
WHERE transaction_type IN ('withdraw', 'withdraw_crypto', 'commission', 'order_commission')
AND transaction_sum > 0
;

SELECT
  user_id,
  currency_id,
  registration_date,
  buy_time,
  buy_time::timestamp AT TIME ZONE 'Europe/Moscow' AS buy_time_with_time_zone,
  exp_time::timestamp--,
  --exp_time::timestamp AT TIME ZONE 'Europe/Moscow' AS exp_time_with_time_zone
FROM
  stat_real_deals_data
WHERE
  registration_date > buy_time
;

SELECT
  user_id,
  currency_id,
  registration_date,
  buy_time,
  buy_time::timestamp AT TIME ZONE 'Europe/Moscow' AS buy_time_with_time_zone,
  to_timestamp(exp_time) as exp_time,
  to_timestamp(exp_time)::timestamp AT TIME ZONE 'Europe/Moscow' AS exp_time_with_time_zone
FROM
  stat_real_deals_data
WHERE
  --buy_time > to_timestamp(exp_time)::timestamp AT TIME ZONE 'Europe/Moscow'
   buy_time > to_timestamp(exp_time)
;

SELECT
  user_id,
  buy_time AS action_start_date,
  exp_time AS action_end_date,
  deal_amount AS in_amount,
  win_amount AS out_amount,
  active_id::text AS asset
FROM stat_real_deals_data_instruments
WHERE
  buy_time > exp_time
;

select *, to_timestamp(exp_time):: TIMESTAMP WITH TIME ZONE
from stat_real_deals_data
where user_id = 16822874 AND buy_time >= '2017-09-27' AND buy_time < '2017-09-28'-- and buy_value = 1007504
order by buy_time desc
;