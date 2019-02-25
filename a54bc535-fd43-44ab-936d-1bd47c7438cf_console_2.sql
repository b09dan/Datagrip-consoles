SELECT
  to_char(transaction_date, 'YYYY-MM'),
  transaction_type,
  AVG(transaction_sum),
  SUM(transaction_sum)
FROM stat_transactions_data
WHERE transaction_type IN ('deposit_crypto', 'deposit', 'withdraw', 'withdraw_crypto')
  AND transaction_date >= TIMESTAMP'2017-02-01 00:00:00.00'
  AND transaction_date <= TIMESTAMP'2018-02-01 00:00:00.00'
GROUP BY transaction_type
;





SELECT DISTINCT payment_method
FROM
(
  SELECT
    payment_method
  FROM stat_billing_data
  LIMIT 10000000
) AS dkdkdk



DROP TABLE IF EXISTS bogdan_temp_billing_balabina;
CREATE TABLE bogdan_temp_billing_balabina AS
SELECT
  to_char(created, 'YYYY-MM') AS month_cards_payments,
  transaction_type,
  COUNT(stat_billing_data.id),
  SUM(stat_billing_data.enrolled_amount/1000000),
  AVG(stat_billing_data.enrolled_amount/1000000)
FROM stat_billing_data
LEFT JOIN stat_transactions_data
  ON stat_billing_data.user_id = stat_transactions_data.user_id
WHERE payment_method IN ('Visa/Mastercard Recurrent', 'Cardpay (visa/mastercard Not reg)', 'Cardpay (visa/mastercard) Recurrent')
AND stat_billing_data.created >= TIMESTAMP'2017-02-01 00:00:00.00'
AND stat_billing_data.created <= TIMESTAMP'2018-02-28 00:00:00.00'
AND transaction_type IN ('deposit_crypto', 'deposit', 'withdraw', 'withdraw_crypto')
GROUP BY month_cards_payments
;

SELECT max(created)
FROM stat_billing_data;

SELECT * FROM bogdan_temp_billing_balabina;
