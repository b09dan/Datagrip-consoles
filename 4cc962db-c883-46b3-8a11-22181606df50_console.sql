SELECT * FROM data.positions;



SELECT
  leverage,
  instrument_type,
  create_at,
  position_type,
  instrument_active_id,
  instrument_id
FROM data.positions;







SELECT
  user_id,
  update_at::DATE AS transaction_date,
  buy_amount_enrolled / (1000000.0 * leverage) AS in_amount,
  sell_amount_enrolled / (1000000.0 * leverage) AS out_amount,
  instrument_currency AS currency, -- ??? Или instrument_underlying
  user_balance_id AS balance_type,
  instrument_id AS action_type
FROM data.positions;



select
date(create_at) as date,
--instrument_type,
count(distinct user_id) as users,
count(*) as deals,

sum(case when position_type = 'long' then buy_count when position_type = 'short' then sell_count end) as coin_count,
sum(case when position_type = 'long' then buy_amount_enrolled / (1000000.0 * leverage)
          when position_type = 'short' then sell_amount_enrolled / (1000000.0 * leverage)  end) as invest_amount_enrolled--,
--((margin::numeric * currency_rate::numeric) / (currency_unit*1000000.00)) AS volume

from data.positions
where user_balance_type = 1 and instrument_type in (''crypto'')
  and create_at >= now() -  interval '3 months'
--group by date(create_at)--, instrument_type
--order by date(create_at) desc




SELECT
  user_id,
  create_at             AS action_start_date,
  null                  AS action_end_date,
  (CASE
   WHEN position_type = 'short'
     THEN sell_amount_enrolled / (1000000.0 * leverage)
   WHEN position_type = 'long'
     THEN buy_amount_enrolled / (1000000.0 * leverage)
   END)                 AS in_amount,
  0                     AS out_amount,
  (CASE
   WHEN user_balance_type = 1
     THEN 'real'::TEXT
   WHEN user_balance_type = 4
     THEN 'train'::TEXT
   END)                 AS balance_type,
  instrument_type       AS action_type,
  instrument_id :: text AS asset
FROM data.positions
