-- Задание от наташи
SELECT DISTINCT transaction_type
FROM
(
  SELECT transaction_type
  FROM stat_transactions_data
  LIMIT 10000000
) as dkdkkd;

SELECT *
FROM stat_transactions_data
LIMIT 10;

SELECT *
FROM stat_users_data
LIMIT 10;


SELECT
  country, aff_id, SUM(transaction_sum)
FROM(
SELECT
*
FROM stat_transactions_data
LIMIT 100000) AS skksk
GROUP BY country, aff_id;


--сгруппировать по неделям
--По месяцам
-- по aff_id
--по платформам
--Коррелирует ли размер денег с платформой
-- Хвост / тело



--------------
SELECT
  reg_month,
  week_number,
  aff_id,
  --country,
  SUM(tail_transaction_sum),
  SUM(body_transaction_sum)
FROM
  (
    SELECT
      reg_month,
      week_number,
      aff_id,
      country,
      (CASE
       WHEN tail_or_body_new = 'tail'
         THEN SUM(transaction_sum)
       END) AS tail_transaction_sum,
      (CASE
       WHEN tail_or_body_new = 'body'
         THEN SUM(transaction_sum)
       END) AS body_transaction_sum
    FROM
      (
        SELECT
          aff_id,
          country,
          initcap((to_char(to_timestamp((EXTRACT(MONTH FROM transaction_date)) :: TEXT, 'MM'), 'TMmon'))) || ' ' ||
          EXTRACT(YEAR FROM transaction_date) AS reg_month,
          EXTRACT(WEEK FROM transaction_date) AS week_number,
          (CASE
           WHEN month_from_reg >= 1
             THEN 'tail'
           WHEN month_from_reg = 0
             THEN 'body'
           END)                               AS tail_or_body_new,
          transaction_sum
        FROM
          (
            SELECT
              country,
              registration_date,
              transaction_date,
              (DATE_PART('year', transaction_date :: DATE) - DATE_PART('year', registration_date :: DATE)) * 12 +
              (DATE_PART('month', transaction_date :: DATE) -
               DATE_PART('month', registration_date :: DATE)) AS month_from_reg,
              aff_id,
              transaction_sum
            FROM
              bogdan_temp_stat_transactions_data
            --LIMIT 1064214 --100000
          ) AS stat_transactions_data_limited
      ) AS countries_and_affs_with_money
    GROUP BY
      reg_month,
      week_number,
      aff_id,
      country,
      tail_or_body_new
  ) AS grouped_by_tail_body
GROUP BY
  reg_month,
  week_number,
  aff_id--,
  --country
ORDER BY
  reg_month,
  week_number,
  aff_id--,
  --country

;
------------------------------------------
--Сколько задепонировали в первую неделю, во вторую и т.д.
SELECT
  --country,
  --registration_date,
  --transaction_date,
  EXTRACT(WEEK FROM registration_date) AS reg_week_number,
  EXTRACT(WEEK FROM transaction_date) AS trans_week_number,
  --aff_id,
  SUM(transaction_sum)
FROM
  bogdan_temp_stat_transactions_data
WHERE transaction_type = 'deposit' --'order_commission', 'withdraw' (вывод)
  GROUP BY reg_week_number, trans_week_number
--LIMIT 10000 --100000







--------------
SELECT
  users_deposits_through_weeks.user_id,
  bogdan_temp_stat_transactions_data.aff_id,
  bogdan_temp_stat_transactions_data.country,
  reg_week_number,
  trans_week_number,
  AVG(transaction_sum_sum) AS transaction_sum_sum

FROM
  (
    SELECT
      regs.user_id,
      reg_week_number,
      trans_week_number,
      transaction_sum_sum
    FROM
      (
        SELECT
          DISTINCT
          user_id,
          date_trunc('week', registration_date) :: DATE AS reg_week_number
        FROM
          bogdan_temp_stat_transactions_data
        WHERE transaction_type = 'deposit' --'order_commission', 'withdraw' (вывод)
      ) AS regs
      JOIN
      (
        SELECT
          user_id,
          date_trunc('week', transaction_date) :: DATE AS trans_week_number,
          SUM(transaction_sum)                         AS transaction_sum_sum
        FROM
          bogdan_temp_stat_transactions_data
        WHERE transaction_type = 'deposit' --'order_commission', 'withdraw' (вывод)
        GROUP BY
          user_id,
          trans_week_number
      ) AS transactions
        ON regs.user_id = transactions.user_id
  ) AS users_deposits_through_weeks
LEFT JOIN bogdan_temp_stat_transactions_data
  ON bogdan_temp_stat_transactions_data.user_id = users_deposits_through_weeks.user_id
GROUP BY
  users_deposits_through_weeks.user_id,
  aff_id,
  bogdan_temp_stat_transactions_data.country,
  reg_week_number,
  trans_week_number
ORDER BY aff_id, users_deposits_through_weeks.user_id, reg_week_number, trans_week_number;

-----------------------------------------------------------------------------------------
-- 2. Как отличается топ 10 стран в начале и в конце февраля по сумме депозитов (aff_id = 166, 168)
-- Табличка со странами в начале и в конце отличается

SELECT
  stat_users_data.aff_id,
  stat_users_data.country,
  --registration_date :: DATE,
  SUM(CASE
   WHEN stat_users_data.day_0 <> 0
     THEN stat_users_data.day_0
   END) AS day_1_sum_first_half,
  COUNT (CASE
   WHEN stat_users_data.day_0 <> 0
     THEN stat_users_data.user_id
   END) AS count_reg_second_half,
  COUNT(DISTINCT stat_users_data.user_id) AS count_depo_first_half
FROM
  bogdan_temp_stat_transactions_data
RIGHT JOIN stat_users_data
    ON stat_users_data.user_id = bogdan_temp_stat_transactions_data.user_id
WHERE transaction_type = 'deposit'
      AND registration_date >= '2018-02-01'
      AND registration_date <= '2018-02-07'
      AND registration_date :: DATE = transaction_date :: DATE
GROUP BY
  stat_users_data.aff_id,
  stat_users_data.country
  --registration_date
ORDER BY
  aff_id,
  country
  --registration_date
;------------------------




SELECT
  (case
    when registration_date >= '2018-02-01' and  registration_date < '2018-02-08'
      then '1st period'
    when registration_date >= '2018-02-21' and  registration_date < '2018-02-28'
      then '2nd period'
    else 'others'
  end),
  aff_id,
  country,
  COUNT(DISTINCT user_id) AS count_depo_first_half,
  count(distinct case
         when transaction_sum > 0 AND registration_date::DATE = transaction_date::DATE
           then user_id
       end) payers_1st_day,
  sum(case
        when transaction_sum >= 0 AND registration_date::DATE = transaction_date::DATE
          then transaction_sum else 0
      end) payements_1st_day
FROM bogdan_temp_stat_transactions_data
RIGHT JOIN stat_users_data
  ON stat_users_data.aff_id
where registration_date >= '2018-02-01'
  and registration_date < '2018-03-01' and (aff_id = 166 OR aff_id = 168)
 group by
   (case
      when registration_date >= '2018-02-01' and  registration_date < '2018-02-08'
        then '1st period'
      when registration_date >= '2018-02-21' and  registration_date < '2018-02-28'
        then '2nd period'
      else 'others'
    end), aff_id, country



;



 select
     (case when created >= '2018-02-01' and  created < '2018-02-08' then '1st period'
              when created >= '2018-02-21' and  created < '2018-02-28' then '2nd period'
              else 'others' end) as period,
     aff_id,
     country,
     count(distinct user_id) users,
     count(distinct case when day_0 > 0 then user_id end) payers_1st_day,
     sum(case when day_0 > 0 then day_0 else 0 end) payements_1st_day

 from stat_users_data
 where created >= '2018-02-01' and  created < '2018-03-01' and (aff_id = 166 or aff_id = 168)
 group by (case when created >= '2018-02-01' and  created < '2018-02-08' then '1st period'
              when created >= '2018-02-21' and  created < '2018-02-28' then '2nd period'
              else 'others' end), aff_id, country
;


SELECT
  stat_users_data.aff_id,
  stat_users_data.country,
  --registration_date::DATE,
  SUM(CASE
   WHEN stat_users_data.day_0 <> 0
     THEN stat_users_data.day_0
   END) AS day_1_sum_second_half,
  COUNT (CASE
   WHEN stat_users_data.day_0 <> 0
     THEN stat_users_data.user_id
   END) AS count_reg_second_half,
  COUNT(DISTINCT stat_users_data.user_id) AS count_depo_first_half
FROM
  bogdan_temp_stat_transactions_data
RIGHT JOIN stat_users_data
  ON stat_users_data.user_id = bogdan_temp_stat_transactions_data.user_id
WHERE transaction_type = 'deposit'
  AND registration_date >= '2018-02-08'
  AND registration_date <= '2018-02-28'
  AND stat_users_data.day_0 <> 0
GROUP BY
  stat_users_data.aff_id,
  stat_users_data.country
  --registration_date
ORDER BY
  aff_id,
  country
  --registration_date
;

