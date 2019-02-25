%iq_option
SELECT
  users_installs.period,
  users_installs.aff_id,
  users_installs.distinct_installs_count,
  users_demo.distinct_demo_count,
  round(users_demo.distinct_demo_count::NUMERIC/users_installs.distinct_installs_count::NUMERIC*100, 2)::TEXT || '%' AS inst_demo_conversion
FROM
(
  SELECT
    (CASE
     WHEN install_time >= TIMESTAMP '2017-05-01 00:00:00.000000' AND install_time <= TIMESTAMP '2017-05-31 00:00:00.000000'
      THEN 'period_may'
     WHEN install_time >= TIMESTAMP '2017-10-01 00:00:00.000000' AND install_time <= TIMESTAMP '2017-10-31 00:00:00.000000'
      THEN 'period_october'
     WHEN install_time >= TIMESTAMP '2018-02-01 00:00:00.000000' AND install_time <= TIMESTAMP '2018-03-21 00:00:00.000000'
      THEN 'period_now'
     END) AS period,
    aff_id,
    COUNT(DISTINCT id) AS distinct_installs_count
  FROM apps_flyer
    WHERE (install_time >= TIMESTAMP '2017-05-01 00:00:00.000000'
    AND install_time <= TIMESTAMP '2017-05-31 00:00:00.000000')
    OR (install_time >= TIMESTAMP '2017-10-01 00:00:00.000000'
    AND install_time <= TIMESTAMP '2017-10-31 00:00:00.000000')
    OR (install_time >= TIMESTAMP '2018-02-01 00:00:00.000000'
    AND install_time <= TIMESTAMP '2018-03-21 00:00:00.000000')
  GROUP BY
    period,
    aff_id
  ORDER BY
    distinct_installs_count DESC
) AS users_installs
LEFT JOIN
(
  SELECT
    (CASE
     WHEN to_timestamp >= TIMESTAMP '2017-05-01 00:00:00.000000' AND to_timestamp <= TIMESTAMP '2017-05-31 00:00:00.000000'
      THEN 'period_may'
     WHEN to_timestamp >= TIMESTAMP '2017-10-01 00:00:00.000000' AND to_timestamp <= TIMESTAMP '2017-10-31 00:00:00.000000'
      THEN 'period_october'
     WHEN to_timestamp >= TIMESTAMP '2018-02-01 00:00:00.000000' AND to_timestamp <= TIMESTAMP '2018-03-21 00:00:00.000000'
      THEN 'period_now'
     END) AS period,
    aff_id,
    COUNT(DISTINCT user_id) AS distinct_demo_count
  FROM bogdan_temp_demo_vs_train
  WHERE account_type = 'demo'
  GROUP BY
    period,
    aff_id
  ORDER BY
    period,
    aff_id ASC,
    distinct_demo_count DESC
) AS users_demo
ON users_installs.period = users_demo.period
AND users_installs.aff_id = users_demo.aff_id
;

















--%iq_option
SELECT
  users_installs.period,
  users_installs.aff_id,
  users_installs.distinct_installs_count,
  users_train.distinct_train_count,
  round(users_train.distinct_train_count::NUMERIC/users_installs.distinct_installs_count::NUMERIC*100, 2)::TEXT || '%' AS inst_train_conversion
FROM
(
  SELECT
    (CASE
     WHEN install_time >= TIMESTAMP '2017-05-01 00:00:00.000000' AND install_time <= TIMESTAMP '2017-05-31 00:00:00.000000'
      THEN 'period_may'
     WHEN install_time >= TIMESTAMP '2017-10-01 00:00:00.000000' AND install_time <= TIMESTAMP '2017-10-31 00:00:00.000000'
      THEN 'period_october'
     WHEN install_time >= TIMESTAMP '2018-02-01 00:00:00.000000' AND install_time <= TIMESTAMP '2018-03-21 00:00:00.000000'
      THEN 'period_now'
     END) AS period,
    aff_id,
    COUNT(DISTINCT id) AS distinct_installs_count
  FROM apps_flyer
    WHERE (install_time >= TIMESTAMP '2017-05-01 00:00:00.000000'
    AND install_time <= TIMESTAMP '2017-05-31 00:00:00.000000')
    OR (install_time >= TIMESTAMP '2017-10-01 00:00:00.000000'
    AND install_time <= TIMESTAMP '2017-10-31 00:00:00.000000')
    OR (install_time >= TIMESTAMP '2018-02-01 00:00:00.000000'
    AND install_time <= TIMESTAMP '2018-03-21 00:00:00.000000')
  GROUP BY
    period,
    aff_id
) AS users_installs
LEFT JOIN
(
  SELECT
    period,
    aff_id,
    COUNT(DISTINCT user_id) AS distinct_train_count
  FROM bogdan_temp_demo_vs_train
  WHERE account_type = 'train'
  AND registration_platform IN (12, 3, 2)
  GROUP BY
    period,
    aff_id
) AS users_train
ON users_installs.period = users_train.period
AND users_installs.aff_id = users_train.aff_id
ORDER BY
  users_installs.period,
  users_installs.aff_id
;




EXPLAIN
SELECT
    (CASE
     WHEN registration_date >= TIMESTAMP '2017-05-01 00:00:00.000000' AND registration_date <= TIMESTAMP '2017-05-31 00:00:00.000000'
      THEN 'period_may'
     WHEN registration_date >= TIMESTAMP '2017-10-01 00:00:00.000000' AND registration_date <= TIMESTAMP '2017-10-31 00:00:00.000000'
      THEN 'period_october'
     WHEN registration_date >= TIMESTAMP '2018-02-01 00:00:00.000000' AND registration_date <= TIMESTAMP '2018-03-21 00:00:00.000000'
      THEN 'period_now'
     END) AS period_pay,
    stat_transactions_data.aff_id,
    COUNT(DISTINCT stat_transactions_data.user_id) AS all_first_day_payers_count
  FROM stat_transactions_data
  LEFT JOIN bogdan_temp_demo_vs_train
   ON stat_transactions_data.user_id = bogdan_temp_demo_vs_train.user_id
  WHERE
  (
    transaction_date >= TIMESTAMP '2017-05-01 00:00:00.000000'
    AND transaction_date <= TIMESTAMP '2017-06-01 00:00:00.000000'
    AND registration_date >= TIMESTAMP '2017-05-01 00:00:00.000000'
    AND registration_date <= TIMESTAMP '2017-05-31 00:00:00.000000'
  )
  OR
  (
    transaction_date >= TIMESTAMP '2017-10-01 00:00:00.000000'
    AND transaction_date <= TIMESTAMP '2017-11-01 00:00:00.000000'
    AND registration_date >= TIMESTAMP '2017-10-01 00:00:00.000000'
    AND registration_date <= TIMESTAMP '2017-10-31 00:00:00.000000'
  )

  OR
  (
    transaction_date >= TIMESTAMP '2018-02-01 00:00:00.000000'
    AND transaction_date <= TIMESTAMP '2018-03-22 00:00:00.000000'
    AND registration_date >= TIMESTAMP '2018-02-01 00:00:00.000000'
    AND registration_date <= TIMESTAMP '2018-03-21 00:00:00.000000'
  )
  AND DATE_PART('day', stat_transactions_data.transaction_date - stat_transactions_data.registration_date) <= 1
  AND bogdan_temp_demo_vs_train.user_id ISNULL
  GROUP BY
    period_pay,
    stat_transactions_data.aff_id