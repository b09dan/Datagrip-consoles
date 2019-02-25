----------------------------- stat_transactions_data -----------------------------
DROP TABLE IF EXISTS bogdan_temp__stat_transactions_data;
CREATE TABLE bogdan_temp__stat_transactions_data AS
SELECT
  user_id,
  transaction_date,
  transaction_platform,
  aff_track,
  country
FROM stat_transactions_data
LIMIT 100000;

----------------------------- stat_transactions_data -----------------------------
DROP TABLE IF EXISTS bogdan_temp__stat_real_deals_data;
CREATE TABLE bogdan_temp__stat_real_deals_data AS
SELECT
  user_id,
  aff_track,
  deal_amount - win_amount AS pnl,
  active_id,
  buy_time
FROM stat_real_deals_data
LIMIT 100000;


SELECT * FROM stat_transactions_data
;


----------------------------- stat_real_deals_data -----------------------------
SELECT
  user_id,
  deal_amount - stat_real_deals_data.win_amount,
  active_id,
  buy_time
FROM
stat_real_deals_data;



SELECT *
FROM stat_real_deals_data


-----------------------------