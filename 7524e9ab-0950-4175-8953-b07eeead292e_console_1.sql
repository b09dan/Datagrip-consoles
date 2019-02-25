-- установки - регистрации - конверсия в демо/треин - конверсия в заход в апп - конверсия в депозит - сумма депозитов
SELECT *
FROM bogdan_temp_valeriia_fb
JOIN stat_tags
  ON stat_tags.user_id = bogdan_temp_valeriia_fb.user_id;


-- Сколько вообще пользователей
SELECT
  COUNT(DISTINCT user_id)
FROM bogdan_temp_valeriia_fb;


SELECT
  aff_track,
  account_type,
  count(user_id)
FROM bogdan_temp_valeriia_fb
GROUP BY aff_track, account_type;


SELECT
  bogdan_temp_valeriia_fb.user_id,
  is_demo,
  is_trial,
  SUM(profit) AS profit_sum,
  SUM(profit_enrolled) AS profit_enrolled_sum
FROM bogdan_temp_valeriia_fb
JOIN users
  ON users.user_id = bogdan_temp_valeriia_fb.user_id
GROUP BY
  bogdan_temp_valeriia_fb.user_id,
  is_demo,
  is_trial
;


SELECT DISTINCT user_id FROM bogdan_temp_valeriia_fb;


SELECT stat_users_data.user_id FROM stat_users_data WHERE user_id = 32896851
;

SELECT
  aff_track,
  date,
  SUM(spend) as spend_sum
FROM
(
  SELECT
  'mob_Facebook Ads_' || campaign_name || '_' || adset_name AS aff_track,
  date,
  stat_temp_f.spend
  FROM stat_temp_f
) AS stat_temp_f_aff_tracks
WHERE aff_track LIKE 'mob_Facebook Ads_WW-English_iOS_WW-purchase-new_2018-03-01'
  OR aff_track LIKE 'mob_Facebook Ads_GB_iOS_2018_GB_2-100-iOS_LAL5_2018-03-06'
  OR aff_track LIKE 'mob_Facebook Ads_HK_iOS_2018_HK_2-100-iOS_LAL10_2018-03-06'
  OR aff_track LIKE 'mob_Facebook Ads_MY_iOS_2018_MY_2-100-iOS_LAL5_2018-03-06'
  OR aff_track LIKE 'mob_Facebook Ads_TH_iOS_2018_TH_2-200-iOS_LAL3_2018-03-06'
  OR aff_track LIKE 'mob_Facebook Ads_UAE_iOS_2018_AE_2-100-iOS_LAL10_2018-03-06'
  OR aff_track LIKE 'mob_Facebook Ads_ZA_iOS_2018_ZA_2-100-iOS_LAL5_2018-03-06'
AND date >= '2018-03-01'
AND date <= '2018-03-11'
GROUP BY
  aff_track,
  date
  ;



SELECT
  aff_track,
  to_timestamp::DATE,
  name,
  count(stat_tags.user_id)
FROM bogdan_temp_valeriia_fb
JOIN stat_tags
  ON stat_tags.user_id = bogdan_temp_valeriia_fb.user_id
GROUP BY
  aff_track,
  to_timestamp,
  name;

-------------
SELECT
  bogdan_temp_valeriia_fb.user_id,
  bogdan_temp_valeriia_fb.account_type,
  users.is_trial,
  users.is_demo--,
  --SUM(stat_transactions_data.transaction_sum)
FROM
  bogdan_temp_valeriia_fb
RIGHT JOIN users
  ON bogdan_temp_valeriia_fb.user_id = users.user_id
-- RIGHT JOIN stat_transactions_data
--     ON bogdan_temp_valeriia_fb.user_id = stat_transactions_data.user_id
-- WHERE users.aff_track IN ('mob_Facebook Ads_WW-English_iOS_WW-purchase-new_2018-03-01',
-- 'mob_Facebook Ads_GB_iOS_2018_GB_2-100-iOS_LAL5_2018-03-06',
-- 'mob_Facebook Ads_HK_iOS_2018_HK_2-100-iOS_LAL10_2018-03-06',
-- 'mob_Facebook Ads_MY_iOS_2018_MY_2-100-iOS_LAL5_2018-03-06',
-- 'mob_Facebook Ads_TH_iOS_2018_TH_2-200-iOS_LAL3_2018-03-06',
-- 'mob_Facebook Ads_UAE_iOS_2018_AE_2-100-iOS_LAL10_2018-03-06',
-- 'mob_Facebook Ads_ZA_iOS_2018_ZA_2-100-iOS_LAL5_2018-03-06')
--
-- AND stat_transactions_data.aff_track IN ('mob_Facebook Ads_WW-English_iOS_WW-purchase-new_2018-03-01',
-- 'mob_Facebook Ads_GB_iOS_2018_GB_2-100-iOS_LAL5_2018-03-06',
-- 'mob_Facebook Ads_HK_iOS_2018_HK_2-100-iOS_LAL10_2018-03-06',
-- 'mob_Facebook Ads_MY_iOS_2018_MY_2-100-iOS_LAL5_2018-03-06',
-- 'mob_Facebook Ads_TH_iOS_2018_TH_2-200-iOS_LAL3_2018-03-06',
-- 'mob_Facebook Ads_UAE_iOS_2018_AE_2-100-iOS_LAL10_2018-03-06',
-- 'mob_Facebook Ads_ZA_iOS_2018_ZA_2-100-iOS_LAL5_2018-03-06')

GROUP BY
  bogdan_temp_valeriia_fb.user_id,
  bogdan_temp_valeriia_fb.account_type,
  users.is_trial,
  users.is_demo



--теги по популярности
SELECT
  name,
  count(stat_tags.name)
FROM
  stat_tags
WHERE
  stat_tags.tag_time >= '2017-09-01 00:00:00.00'
AND name IN (
    'used historical prices',
    'tried to change asset',
    'changed deal amount manualy',
    'visit_traderoom',
    'button deposit page',
    'visited withdrawal page',
    'added technical analysis',
    'changed chart type'
  )
  OR name LIKE 'trading indicator added%'
GROUP BY
  name
;


-- Наши теги
SELECT
  aff_track,
  to_timestamp::date as day,
  bogdan_temp_valeriia_fb.user_id,
  stat_tags.name
FROM bogdan_temp_valeriia_fb
JOIN stat_tags
  ON stat_tags.user_id = bogdan_temp_valeriia_fb.user_id
WHERE name IN (
    'used historical prices',
    'tried to change asset',
    'changed deal amount manualy',
    'visit_traderoom',
    'button deposit page',
    'visited withdrawal page',
    'added technical analysis',
    'changed chart type'
  )
  OR name LIKE 'trading indicator added%'
GROUP BY
  aff_track,
  day,
  bogdan_temp_valeriia_fb.user_id,
  stat_tags.name;

-- кол-во пользователей по aff_track'ам
SELECT
  aff_track,
  --apps_flyer.install_time::DATE AS install_day,
  first_connected_user
FROM apps_flyer
WHERE aff_track IN ('mob_Facebook Ads_WW-English_iOS_WW-purchase-new_2018-03-01',
'mob_Facebook Ads_GB_iOS_2018_GB_2-100-iOS_LAL5_2018-03-06',
'mob_Facebook Ads_HK_iOS_2018_HK_2-100-iOS_LAL10_2018-03-06',
'mob_Facebook Ads_MY_iOS_2018_MY_2-100-iOS_LAL5_2018-03-06',
'mob_Facebook Ads_TH_iOS_2018_TH_2-200-iOS_LAL3_2018-03-06',
'mob_Facebook Ads_UAE_iOS_2018_AE_2-100-iOS_LAL10_2018-03-06',
'mob_Facebook Ads_ZA_iOS_2018_ZA_2-100-iOS_LAL5_2018-03-06')
AND apps_flyer.install_time >= '2018-03-01 00:00:00.000000'
AND apps_flyer.install_time <= '2018-03-11 00:00:00.000000'
AND apps_flyer.first_connected_user NOTNULL
-- GROUP BY
--     aff_track,
--     install_day
;


-- Все уникальные пользователи по нужным нам aff_track'ам
SELECT
  DISTINCT first_connected_user
FROM apps_flyer
WHERE aff_track IN ('mob_Facebook Ads_WW-English_iOS_WW-purchase-new_2018-03-01',
'mob_Facebook Ads_GB_iOS_2018_GB_2-100-iOS_LAL5_2018-03-06',
'mob_Facebook Ads_HK_iOS_2018_HK_2-100-iOS_LAL10_2018-03-06',
'mob_Facebook Ads_MY_iOS_2018_MY_2-100-iOS_LAL5_2018-03-06',
'mob_Facebook Ads_TH_iOS_2018_TH_2-200-iOS_LAL3_2018-03-06',
'mob_Facebook Ads_UAE_iOS_2018_AE_2-100-iOS_LAL10_2018-03-06',
'mob_Facebook Ads_ZA_iOS_2018_ZA_2-100-iOS_LAL5_2018-03-06')
AND apps_flyer.install_time >= '2018-03-01 00:00:00.000000'
AND apps_flyer.install_time <= '2018-03-11 00:00:00.000000'
AND apps_flyer.first_connected_user NOTNULL;

-- Зарагавшиеся пользователи по aff_track
SELECT
  aff_track,
  COUNT(DISTINCT first_connected_user)
FROM apps_flyer
WHERE aff_track IN ('mob_Facebook Ads_WW-English_iOS_WW-purchase-new_2018-03-01',
'mob_Facebook Ads_GB_iOS_2018_GB_2-100-iOS_LAL5_2018-03-06',
'mob_Facebook Ads_HK_iOS_2018_HK_2-100-iOS_LAL10_2018-03-06',
'mob_Facebook Ads_MY_iOS_2018_MY_2-100-iOS_LAL5_2018-03-06',
'mob_Facebook Ads_TH_iOS_2018_TH_2-200-iOS_LAL3_2018-03-06',
'mob_Facebook Ads_UAE_iOS_2018_AE_2-100-iOS_LAL10_2018-03-06',
'mob_Facebook Ads_ZA_iOS_2018_ZA_2-100-iOS_LAL5_2018-03-06')
AND apps_flyer.install_time >= '2018-03-01 00:00:00.000000'
AND apps_flyer.install_time <= '2018-03-11 00:00:00.000000'
AND apps_flyer.first_connected_user NOTNULL
GROUP BY aff_track
;

SELECT
  aff_track,
  count(bogdan_temp_valeriia_fb.user_id)
FROM bogdan_temp_valeriia_fb
GROUP BY
aff_track
;

SELECT
  *
FROM users
WHERE user_id = 3432211
;



--- Активность по торгам
SELECT
  aff_track,
  active_id,
  user_id,
  AVG(deal_amount) AS deal_amount_avg,
  SUM(deal_amount) AS deal_amount_sum,
  COUNT(user_id)
FROM
  bogdan_temp_valeriia_fb
GROUP BY
  aff_track,
  active_id,
  user_id
;


---
SELECT
  aff_track,
  to_timestamp::date as day,
  bogdan_temp_valeriia_fb.user_id,
  COUNT(DISTINCT stat_tags.name)
FROM bogdan_temp_valeriia_fb
RIGHT JOIN stat_tags
  ON stat_tags.user_id = bogdan_temp_valeriia_fb.user_id
WHERE name IN (
    'used historical prices',
    'tried to change asset',
    'changed deal amount manualy',
    'visit_traderoom',
    'button deposit page',
    'visited withdrawal page',
    'added technical analysis',
    'changed chart type'
  )
  OR name LIKE 'trading indicator added%'
GROUP BY
  aff_track,
  day,
  bogdan_temp_valeriia_fb.user_id;



-- Просто все уникальные пользователи за наш период
CREATE TABLE bogdan_temp_distinct_users AS
SELECT
  DISTINCT user_id
FROM
(
  SELECT
    users.user_id
  FROM users
  WHERE aff_track IN ('mob_Facebook Ads_WW-English_iOS_WW-purchase-new_2018-03-01',
  'mob_Facebook Ads_GB_iOS_2018_GB_2-100-iOS_LAL5_2018-03-06',
  'mob_Facebook Ads_HK_iOS_2018_HK_2-100-iOS_LAL10_2018-03-06',
  'mob_Facebook Ads_MY_iOS_2018_MY_2-100-iOS_LAL5_2018-03-06',
  'mob_Facebook Ads_TH_iOS_2018_TH_2-200-iOS_LAL3_2018-03-06',
  'mob_Facebook Ads_UAE_iOS_2018_AE_2-100-iOS_LAL10_2018-03-06',
  'mob_Facebook Ads_ZA_iOS_2018_ZA_2-100-iOS_LAL5_2018-03-06')
  AND  users.created >= '2018-03-01 00:00:00.000000'
  AND users.created <= '2018-03-11 00:00:00.000000'
) AS apps_flyer_distinct_users
;


-- User_id, которые не производили никаких действий в интерфейсе
CREATE TABLE bogdan_temp_distinct_not_interf_users AS
SELECT
  user_id
FROM bogdan_temp_distinct_users
WHERE user_id NOT IN (
  SELECT
    DISTINCT stat_tags.user_id
  FROM bogdan_temp_valeriia_fb
  JOIN stat_tags
    ON stat_tags.user_id = bogdan_temp_valeriia_fb.user_id
  WHERE name IN (
      'used historical prices',
      'tried to change asset',
      'changed deal amount manualy',
      'visit_traderoom',
      'button deposit page',
      'visited withdrawal page',
      'added technical analysis',
      'changed chart type'
    )
    OR name LIKE 'trading indicator added%'
)
;

-- Те, кто ничего не жад в разбивке по aff_track
SELECT
  aff_track,
  COUNT(bogdan_temp_distinct_not_interf_users.user_id)
FROM users
JOIN bogdan_temp_distinct_not_interf_users
  ON bogdan_temp_distinct_not_interf_users.user_id = users.user_id
GROUP BY aff_track;


SELECT
  aff_track,
  COUNT(users.user_id)
FROM users
WHERE aff_track IN ('mob_Facebook Ads_WW-English_iOS_WW-purchase-new_2018-03-01',
'mob_Facebook Ads_GB_iOS_2018_GB_2-100-iOS_LAL5_2018-03-06',
'mob_Facebook Ads_HK_iOS_2018_HK_2-100-iOS_LAL10_2018-03-06',
'mob_Facebook Ads_MY_iOS_2018_MY_2-100-iOS_LAL5_2018-03-06',
'mob_Facebook Ads_TH_iOS_2018_TH_2-200-iOS_LAL3_2018-03-06',
'mob_Facebook Ads_UAE_iOS_2018_AE_2-100-iOS_LAL10_2018-03-06',
'mob_Facebook Ads_ZA_iOS_2018_ZA_2-100-iOS_LAL5_2018-03-06')
AND  users.created >= '2018-03-01 00:00:00.000000'
AND users.created <= '2018-03-11 00:00:00.000000'
GROUP BY aff_track
;


-- Отчёт в разбивке по aff_track, who did something, did nothing -> if did something what and how often
SELECT
  users.aff_track,
  count(user_id)
FROM
  stat_tags
JOIN bogdan_temp_distinct_users
  ON bogdan_temp_distinct_users.user_id = stat_tags.user_id
JOIN users
  ON users.user_id = bogdan_temp_distinct_users.user_id

