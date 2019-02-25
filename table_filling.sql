DROP TABLE IF EXISTS bogdan_temp_stat_transactions_data;
CREATE TABLE bogdan_temp_stat_transactions_data AS
SELECT
  country,
  user_id,
  transaction_date,
  registration_date,
  aff_id,
  transaction_sum,
  transaction_type
FROM
  stat_transactions_data
WHERE transaction_date >= '2018-01-01'
--AND registration_date >= '2017-12-01'
;


SELECT count(*)
FROM bogdan_temp_stat_transactions_data