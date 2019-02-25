


SELECT *
FROM data.positions;

SELECT *
FROM data.positions_archive;


SELECT *
FROM data.orders_archive;


SELECT *
FROM information_schema.columns
WHERE table_schema = 'data'
  AND table_name   = 'positions';




select
  create_at::DATE as date,
  --instrument_type,
  count(distinct user_id) as users,
  count(*) as deals,
  sum(case
      when position_type = 'long'
        then buy_count
      when position_type = 'short'
        then sell_count
      end) as coin_count,
  sum(case
      when position_type = 'long'
        then buy_amount_enrolled / (1000000.0 * leverage)
      when position_type = 'short'
        then sell_amount_enrolled / (1000000.0 * leverage)
      end) as invest_amount_enrolled
  --((margin::numeric * currency_rate::numeric) / (currency_unit*1000000.00)) AS volume
from data.positions
where user_balance_type = 1 and instrument_type in ('crypto')
    and create_at >= now() -  interval '3 months'
group by create_at::DATE;
--order by date(create_at) desc;

SELECT
        user_id,
        create_at :: DATE,
        buy_amount_enrolled,
        buy_avg_price_enrolled,
        leverage, -- Плечо с которым игрок делает ставку
        is_dma,
        instrument_id, -- Например, какая именно валютная пара используется для торговли
        position_type,
        (case
        when position_type = 'long'
          then buy_amount_enrolled / (1000000.0 * leverage)
        when position_type = 'short'
          then sell_amount_enrolled / (1000000.0 * leverage)
        end) as invest_amount_enrolled,
        (case
        when position_type = 'long'
          then (buy_amount_enrolled - sell_amount_enrolled)/ (1000000.0 * leverage)
        when position_type = 'short'
          then (sell_amount_enrolled - buy_amount_enrolled)/ (1000000.0 * leverage)
        end) as profit
      FROM
        data.positions
      WHERE instrument_type = 'forex'
      AND create_at >= '2018-01-01'::DATE;


SELECT
  user_id,
  (case
  when position_type = 'long'
    then (buy_amount_enrolled - sell_amount_enrolled)/ (1000000.0 * leverage)
  when position_type = 'short'
    then sell_amount_enrolled - buy_amount_enrolled/ (1000000.0 * leverage)
  end) as profit
FROM
  data.positions
WHERE instrument_type = 'forex'
AND create_at >= '2018-01-01'::DATE

SELECT * FROM data.positions
WHERE user_id = 30998254

