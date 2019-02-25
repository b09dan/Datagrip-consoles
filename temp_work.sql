SELECT
  aff_id,
  country_name,
  SUM(cost)
FROM bogdan_temp_countries
GROUP BY aff_id, country_name;

----------------------------- Заготовка по инкремент -----------------------------
SELECT
  *
FROM bogdan_temp_countries
JOIN bogdan_temp_pnl
ON bogdan_temp_countries.aff_id = bogdan_temp_pnl.aff_id
WHERE bogdan_temp_countries.date >= '2017-12-01'
AND bogdan_temp_pnl.aff_id IN (1, 150, 162, 166, 168)
AND bogdan_temp_countries.date <= '2017-12-02' ---- CURRENT DATE
AND bogdan_temp_pnl.trade_date >= '2017-12-01'
LIMIT 10;


-----------------------------
SELECT
  DISTINCT bogdan_stat_real_deals_data.aff_track,
  bogdan_temp_countries.country_name,
  bogdan_temp_countries.campaignname,
  bogdan_stat_real_deals_data.aff_id,
  bogdan_temp_countries.creativetrackingurltemplate,
  bogdan_temp_countries.creativefinalurls,
  bogdan_temp_countries.accountdescriptivename
FROM bogdan_temp_countries
RIGHT OUTER JOIN bogdan_stat_real_deals_data
  ON bogdan_stat_real_deals_data.aff_id = bogdan_temp_countries.aff_id
WHERE bogdan_stat_real_deals_data.aff_id IN (1, 150, 162, 166, 168)
AND country_name ISNULL
;


SELECT COUNT(*)
FROM bogdan_temp_ad_comp_country;

TRUNCATE bogdan_temp_ad_comp_country;

SELECT DISTINCT bogdan_temp_ad_comp_country.account_id
FROM bogdan_temp_ad_comp_country;

SELECT DISTINCT bogdan_temp_ad_comp_country.campaignname
FROM bogdan_temp_ad_comp_country;


SELECT *
FROM bogdan_temp_ad_comp_country
WHERE bogdan_temp_ad_comp_country.campaignid = 615341219;
------------

-- Countries costs groupping
SELECT
  bogdan_temp_countries.country_name,
  aff_id,
  SUM(bogdan_temp_countries.cost)
FROM bogdan_temp_countries
WHERE aff_id NOTNULL
GROUP BY bogdan_temp_countries.country_name, bogdan_temp_countries.aff_id
ORDER BY country_name ASC;

--All Aff tracks
CREATE TABLE bogdan_temp_unique_aff_tracks AS
SELECT DISTINCT aff_track
FROM stat_real_deals_data
UNION
SELECT DISTINCT aff_track
FROM stat_real_deals_data_instruments;



-- Normalizing values from margin (Скрипт для Tableau)
SELECT
  't' AS margin_total_sum,
  country_name,
  aff_id,
  cost_sum,
  tail_pnl_sum,
  body_pnl_sum,
  margin,
  (margin - margin_total_avg)/(margin_total_max - margin_total_min) AS margin_normalized
FROM temp_b_margin_from_pnl
LEFT JOIN (
SELECT
  't' AS margin_join,
  SUM(margin) as margin_total_sum,
  MAX(margin) as margin_total_max,
  MIN(margin) as margin_total_min,
  AVG(margin) as margin_total_avg
FROM temp_b_margin_from_pnl
GROUP BY margin_join) AS margin_total_sum_table
ON margin_total_sum_table.margin_join = 't';


--Набор уникальных compaingname
SELECT DISTINCT campaignname
FROM stat_temp_g
-- WHERE campaignname NOT ILIKE '%android%'
-- AND campaignname NOT ILIKE '%android%'
-- AND campaignname NOT ILIKE '%ios%'

WHERE
campaignname NOT ILIKE '%ios%'
AND campaignname NOT ILIKE '%android%'
AND campaignname NOT ILIKE 'GAD_S_%' -- 168
AND campaignname NOT ILIKE 'GAD_GDN%' -- 150
AND campaignname NOT ILIKE '%Android: adwords_%' --166
AND campaignname NOT ILIKE '%iOS: mob_adwords_%' --162
-- AND campaignname NOT ILIKE '%MDweb_%' AND campaignname NOT ILIKE '%_WEB%' -- 168 и 154 одновременно,
AND campaignname NOT ILIKE '%MDweb_%' AND campaignname NOT ILIKE '%_Mob%' -- 164 у некоторых 164 прям есть 164 в названии
AND stat_temp_g.date >= '2017-01-01';
-- LIMIT 10000000


-- Select last available date
SELECT (max(bogdan_temp_pnl.trade_date) - INTERVAL '1 WEEK')::date as MaxDate FROM bogdan_temp_pnl;  -- Change to exp_create_date


--Current date - one week
SELECT current_date  - INTERVAL '1 WEEK'


--New aggregate
SELECT
  lower(bogdan_temp_pnl_with_clt_type_new.country_name) AS country_name,
  bogdan_temp_pnl_with_clt_type_new.aff_id,
  tail_pnl,
  body_pnl,
  -- coalesce(tail_pnl , 0) AS tail_pnl_sum,
  -- coalesce(body_pnl , 0) AS body_pnl_sum,
  cost
FROM
  (
    SELECT
      bogdan_temp_pnl_with_clt_type.country_name,
      bogdan_temp_pnl_with_clt_type.aff_id,
      SUM(tail_pnl) AS tail_pnl,
      SUM(body_pnl) AS body_pnl
    FROM
      (
        SELECT
          bogdan_temp_pnl_countries.country_name,
          aff_id,
          (CASE
           WHEN tail_or_body_new = 'tail'
             THEN SUM(pnl)
           END) AS tail_pnl,
          (CASE
           WHEN tail_or_body_new = 'body'
             THEN SUM(pnl)
           END) AS body_pnl
        FROM bogdan_temp_pnl_countries
        GROUP BY aff_id, country_name, tail_or_body_new
      ) AS bogdan_temp_pnl_with_clt_type
    WHERE aff_id IN (1, 150, 162, 166, 168)
    GROUP BY
      country_name,
      aff_id
   -- LIMIT 100
  ) AS bogdan_temp_pnl_with_clt_type_new
JOIN bogdan_temp_countries
  ON bogdan_temp_pnl_with_clt_type_new.country_name = bogdan_temp_countries.country_name
  AND bogdan_temp_pnl_with_clt_type_new.aff_id = bogdan_temp_countries.aff_id
WHERE bogdan_temp_countries.aff_id IN (1, 150, 162, 166, 168)
  -- AND bogdan_temp_countries.date >= date_start
  -- AND bogdan_temp_countries.date <= date_end
-- GROUP BY
--   bogdan_temp_pnl_with_clt_type_new.country_name,
--   bogdan_temp_pnl_with_clt_type_new.aff_id,
--   tail_pnl,
--   body_pnl
ORDER BY country_name ASC;


-- Скрипт для вывода "плохих стран" в соответствии с аналитикой маржи по странам
SELECT
  country_name,
  campaignname,
  aff_id,
  SUM(cost)
FROM bogdan_temp_countries
WHERE bogdan_temp_countries.country_name IN ('south africa', 'singapore', 'vietnam', 'new zealand', 'india')
AND bogdan_temp_countries.aff_id IN (166, 168)
GROUP BY
  bogdan_temp_countries.country_name,
  bogdan_temp_countries.campaignname,
  bogdan_temp_countries.aff_id
;






-- Для обновления таблицы bogdan_temp_countries
SELECT
  DISTINCT to_char(date, 'YYYY-MM-01')::DATE AS date_month_year,
  date AS table_date,
  current_date,
  ('now'::timestamp - '1 month'::interval)::DATE as skslsl
FROM bogdan_temp_countries
--WHERE date >= current_date -1
ORDER BY date;

--------------------------------------
-- Удалить все данные, которые позже полностью заполненного месяца
BEGIN;
DELETE FROM bogdan_temp_countries
WHERE date > (SELECT max(date::TIMESTAMP - '3 day'::interval)::DATE AS last_fully_filled_month
FROM bogdan_temp_countries
ORDER BY last_fully_filled_month DESC
LIMIT 1);
SELECT COUNT(*)
FROM bogdan_temp_countries;
ROLLBACK;

SELECT COUNT(*)
FROM bogdan_temp_countries;

-- Добавить новые данные по последние загруженные
(
  (
    SELECT
      campaignname,
      accountdescriptivename,
      (stat_temp_g_uac.cost / 1000000) AS cost,
      stat_temp_g_uac.date,
      'stat_temp_g_uac' AS data_type,
      NULL AS creativefinalurls,
      NULL AS creativetrackingurltemplate
    FROM stat_temp_g_uac
    WHERE stat_temp_g_uac.date >
          (SELECT max(date::TIMESTAMP - '3 day'::interval)::DATE AS last_fully_filled_month
           FROM bogdan_temp_countries
           ORDER BY last_fully_filled_month DESC
          )
  UNION ALL
  (
    SELECT
      campaignname,
      accountdescriptivename,
      (stat_temp_g.cost / 1000000) AS cost,
      stat_temp_g.date,
      'stat_temp_g' AS data_type,
      creativefinalurls,
      creativetrackingurltemplate
    FROM stat_temp_g
    WHERE stat_temp_g.date >
          (SELECT max(date::TIMESTAMP - '3 day'::interval)::DATE AS last_fully_filled_month
           FROM bogdan_temp_countries
           ORDER BY last_fully_filled_month DESC
          )
  )
) AS adv_companies_none_country;


-- Удалить заполненные неполностью
BEGIN;
DELETE FROM bogdan_temp_pnl
WHERE reg_date > (SELECT max(reg_date::TIMESTAMP - '3 day'::interval)::DATE AS last_fully_filled_month
FROM bogdan_temp_pnl
ORDER BY last_fully_filled_month DESC
LIMIT 1);
SELECT COUNT(*)
FROM bogdan_temp_pnl;
ROLLBACK;

SELECT COUNT(*)
FROM bogdan_temp_pnl;

-- Взять последние по прибыли
SELECT
  aff_id,
  option_type_id,
  stat_real_deals_data.deal_amount - stat_real_deals_data.win_amount AS pnl,
  DATE_TRUNC('MONTH', stat_real_deals_data.buy_time)::DATE AS trade_date,
  DATE_TRUNC('MONTH', stat_real_deals_data.registration_date)::DATE AS reg_date,
  stat_real_deals_data.aff_track,
  to_timestamp(stat_real_deals_data.exp_time::double precision)::date AS exp_create_date
FROM
  stat_real_deals_data
  WHERE stat_real_deals_data.registration_date >
          (SELECT max(reg_date::TIMESTAMP - '3 month'::interval)::DATE AS last_fully_filled_month
           FROM bogdan_temp_pnl_countries
           ORDER BY last_fully_filled_month DESC
          )
--   WHERE
--   to_timestamp(stat_real_deals_data.exp_time::double precision)::date >= date_start
--   AND to_timestamp(stat_real_deals_data.exp_time::double precision)::date <= date_end
LIMIT 500;


---- Обновить данные по странам в одной таблице вместо того, чтобы создавать новую таблицу
--Создаём тестовую таблицу
DROP TABLE IF EXISTS bogdan_temp__test_pnl_countries;
CREATE TABLE bogdan_temp__test_pnl_countries AS
SELECT *
FROM bogdan_temp_pnl
WHERE bogdan_temp_pnl.aff_id IN (1, 150, 162, 166, 168)
  LIMIT 10000;


SELECT COUNT(*)
FROM bogdan_temp_pnl;

SELECT email FROM temp_emails
LEFT JOIN users
  ON users.user_id = temp_emails.user_id
WHERE is_blocked = FALSE;


SELECT
  temp_emails.user_id,
  gclid,
  email
FROM
  user_adwords_click_history
LEFT JOIN temp_emails
  ON temp_emails.user_id = user_adwords_click_history.user_id
;




--Проверка расхождений по costs стран

SELECT aff_id, country_name, SUM(cost)
FROM
  bogdan_temp_countries
WHERE aff_id NOT IN (1, 162, 166)
GROUP BY aff_id, country_name;


SELECT
  aff_id,
      date,SUM(cost)
FROM
  (
    SELECT
      (
        CASE
        WHEN campaignname LIKE 'GAD\_S\_%'
          THEN 168
        WHEN accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname NOT LIKE '%1%'
          THEN 168
        END) AS aff_id,
      date,
      cost / 1000000 as cost
    FROM stat_temp_g_uac
    WHERE date >= '2018-01-01'
          AND date <= '2018-01-31'



    UNION ALL
    SELECT
      (
        CASE
        WHEN campaignname LIKE 'GAD\_S\_%'
          THEN 168
        WHEN accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname NOT LIKE '%1%'
          THEN 168
        END) AS aff_id,
      date,
      cost / 1000000 as cost
    FROM stat_temp_g
    WHERE date >= '2018-01-01'
          AND date <= '2018-01-31'
  ) AS aff_168
WHERE aff_id NOTNULL
GROUP BY aff_id,
      date;
