 select
     (case
        when created >= '2018-02-01' and  created < '2018-02-08'
          then '1st period'
        when created >= '2018-02-21' and  created < '2018-02-28'
          then '2nd period'
        else 'others'
     end) as period,
     aff_id,
     country,
     count(distinct user_id) users,
     count(distinct case when day_0 > 0 then user_id end) payers_1st_day,
     sum(case
         when day_0 > 0
          then day_0
         else 0
         end) payements_1st_day

 from stat_users_data
 where
   created >= '2018-02-01'
   and  created < '2018-03-01'
   and (aff_id = 166 or aff_id = 168)
 group by
   (case
     when created >= '2018-02-01'and  created < '2018-02-08'
       then '1st period'
     when created >= '2018-02-21' and  created < '2018-02-28'
       then '2nd period'
     else 'others'
   end),
   aff_id,
   country
;

--Data for periods
DROP TABLE IF EXISTS bogdan_temp_problem_periods;
CREATE TABLE bogdan_temp_problem_periods AS
SELECT
  --to_char(created, 'YYYY-MM-01')::DATE AS periods,
  -- EXTRACT(WEEK FROM created) AS periods,
  date_trunc('week', created)::DATE AS periods,
  aff_id,
  country,
  count(distinct user_id) users,
  count(distinct case when day_0 > 0 then user_id end) payers_1st_day,
  sum(case
   when day_0 > 0
    then day_0
   else 0
   end) payements_1st_day
FROM stat_users_data
WHERE
  created >= '2018-01-01'
GROUP BY
  periods,
  aff_id,
  country
;


SELECT
  created,
  date_trunc('week', created)::DATE
FROM stat_users_data
LIMIT 10000
 ;



DROP TABLE IF EXISTS bogdan_temp_funnel_4_google;
CREATE TABLE bogdan_temp_funnel_4_google AS
SELECT
  first_regs.registration_date__week,
  first_regs.aff_track,
  dep_in_reg_day.country,
  uniq_users_regs,
  uniq_payed_users
FROM
(
  SELECT
    date_trunc('week', created)::DATE AS registration_date__week,
    aff_track,
    country.name,
    COUNT(DISTINCT user_id) AS uniq_users_regs
  FROM users
  LEFT JOIN country
    ON users.country_id = country.id
  WHERE
    users.created >= TIMESTAMP '2018-02-01 00:00:00.000000'
  GROUP BY
    registration_date__week,
    aff_track,
    country.name
) AS first_regs

INNER JOIN
(
  SELECT
    date_trunc('week', registration_date)::DATE AS registration_date__week,
    aff_track,
    country,
    COUNT(DISTINCT user_id) AS uniq_payed_users
  FROM stat_transactions_data
  WHERE
    transaction_date::DATE = registration_date::DATE
    AND transaction_date >= TIMESTAMP '2018-02-01 00:00:00.000000'
  GROUP BY
    registration_date__week,
    aff_track,
    country
) AS dep_in_reg_day
ON dep_in_reg_day.registration_date__week = first_regs.registration_date__week
AND dep_in_reg_day.aff_track = first_regs.aff_track
AND dep_in_reg_day.country = first_regs.name
;


SELECT * FROM bogdan_temp_funnel_4_google