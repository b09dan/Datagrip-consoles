----------------------------- Тут начинаются объяснения с первого дня -----------------------------
--SELECT * FROM users LIMIT 100;

--aff_id: traffic
--aff_track: traffic source
--group_id риски

SELECT * FROM stat_users_data LIMIT 100;

--day_* сколько задепонировал к этому дню

--withdraw_sum - вывел
--client_platform

SELECT * FROM stat_real_deals_data  LIMIT 100;

--active_id - валютная пара, бинарка, крипта
--active_id джойнить с asset

--option type_id, 3 - турбо, 1 - опционы долгие
--роботы - автоматизация торговли

--buyback = sold

--EUR/DOllar = 1.18 * 1000000 (buy_value) курс на время покупки, exp -эксперации

SELECT * FROM stat_train_deals_data  LIMIT 100; --есть e-mail


SELECT * FROM stat_demo_deals_only_data LIMIT 100;  -- нет e-mail

SELECT * FROM stat_real_deals_data_instruments LIMIT 100;

--option_type_id = тип инструмента, 7 - дигитальные 8 - cfd, 9 - forex, 10 крипта
--default - продажа до экспирации

SELECT * FROM adwords_country_criteria_id LIMIT 100;



SELECT * FROM stat_temp_f LIMIT 100;
SELECT * FROM stat_temp_g LIMIT 100;

SELECT * FROM stat_temp_g_uac LIMIT 100;


--проблема в соотношении affec_id
SELECT * FROM LIMIT 100;

SELECT * FROM stat_temp_g LIMIT 100;
----------------------------- Тут заканчиваются объяснения с первого дня -----------------------------

----------------------------- Тут начинается запрос про вычленение aff_id и costs -----------------------------
SELECT
  country.name AS country_name,
  --stat_real_deals_data.country_id AS country_id,
  stat_real_deals_data.aff_id,
  stat_real_deals_data.deal_amount - stat_real_deals_data.win_amount AS user_profit,
  temp_costs.costs_sum
FROM stat_real_deals_data
LEFT JOIN
  (
    SELECT
      (CASE WHEN accountdescriptivename = 'RED: MOB (first open)' AND campaignname ILIKE '%android%'
        THEN 166
       WHEN accountdescriptivename = 'RED: MOB (first open)' AND campaignname ILIKE '%ios%'
         THEN 162
       END) AS aff_id,
      SUM(cost) / 1000000.0 AS costs_sum
    FROM stat_temp_g_uac
    WHERE EXTRACT(YEAR FROM stat_temp_g_uac.date) = 2018
      --AND EXTRACT(MONTH FROM stat_temp_g_uac.date) = 1
    GROUP BY (CASE WHEN accountdescriptivename = 'RED: MOB (first open)' AND campaignname ILIKE '%android%'
      THEN 166
              WHEN accountdescriptivename = 'RED: MOB (first open)' AND campaignname ILIKE '%ios%'
                THEN 162 END)
    UNION
    SELECT
      (CASE WHEN accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND
                 campaignname NOT LIKE '%1%'
        THEN 168
       WHEN accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname LIKE '%1%'
         THEN 1
       WHEN (accountdescriptivename = 'RED: WEB GDN' AND campaignname LIKE '%MDweb%' AND campaignname LIKE '%GDN%')
            OR (accountdescriptivename = 'RED: Forex' AND campaignname ILIKE '%forex%')
         THEN 150
       END) AS aff_id,
      SUM(cost) / 1000000.0 AS costs_sum
    FROM stat_temp_g
    WHERE EXTRACT(YEAR FROM stat_temp_g.date) = 2018
      --AND EXTRACT(MONTH FROM stat_temp_g.date) = 1
    GROUP BY (CASE WHEN accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND
                        campaignname NOT LIKE '%1%'
      THEN 168
              WHEN accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND
                   campaignname LIKE '%1%'
                THEN 1
              WHEN
                (accountdescriptivename = 'RED: WEB GDN' AND campaignname LIKE '%MDweb%' AND campaignname LIKE '%GDN%')
                OR (accountdescriptivename = 'RED: Forex' AND campaignname ILIKE '%forex%')
                THEN 150
              END)
  ) AS temp_costs
  ON temp_costs.aff_id = stat_real_deals_data.aff_id
LEFT JOIN country ON stat_real_deals_data.country_id = country.id
WHERE costs_sum <> 0
  AND EXTRACT(YEAR FROM stat_real_deals_data.registration_date) = 2018
  AND EXTRACT(MONTH FROM stat_real_deals_data.registration_date) = 1
--GROUP BY country_name, stat_real_deals_data.aff_id
LIMIT 1000;
----------------------------- Тут заканчивается запрос про вычленение aff_id и costs -----------------------------

----------------------------- Тут начинается поиск по наименованию таблицы -----------------------------
SELECT table_name
  FROM information_schema.tables
 WHERE table_schema='options_analytics'
   AND table_name like '%temp%';
----------------------------- Тут заканчивается поиск по наименованию таблицы -----------------------------

----------------------------- Тут начинается анализ "слабых мест" запроса -----------------------------
EXPLAIN ANALYSE;
----------------------------- Тут заканчивается анализ "слабых мест" запроса -----------------------------

----------------------------- Тут начинается что-то вроде менеджера задач -----------------------------
SELECT
  application_name,
  pid AS Process_ID_of_this_backend,
  client_addr,
  to_char(current_timestamp - query_start, 'HH24:MI:SS') AS query_executing_time,
  pg_stat_activity.query,
  state,
  wait_event_type
FROM  pg_stat_activity
WHERE application_name LIKE '%bogdan%'
ORDER BY application_name, query_start ASC;
SELECT * FROM pg_stat_activity;
select pg_cancel_backend(11974); -- cancel pid
select pg_terminate_backend(106118); -- terminate unless cancel helps
----------------------------- Тут заканчивается что-то вроде менеджера задач -----------------------------

----------------------------- Тут начинается как взять все колонки -----------------------------
SELECT *
FROM information_schema.columns
WHERE table_schema = 'options_analytics'
  AND table_name   = 'temp_orders_archive';
----------------------------- Тут заканчивается как взять все колонки -----------------------------

----------------------------- Тут начинается один из вариантов кода для аналитики маржи по старанам в tableau -----------------------------
SELECT
  't' AS margin_total_sum,
  country_name,
  aff_id,
  temp_b_margin_from_pnl.date_month_year,
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
----------------------------- Тут заканчивается один из вариантов кода для аналитики маржи по старанам в tableau -----------------------------


----------------------------- Тут начинается соотненсение aff_id и команд в компании -----------------------------
SELECT
  DISTINCT unnest(string_to_array(afftrack_group.affs, ','::text))::bigint AS aff_id,
  afftrack_group.name AS traffic_name
FROM
  afftrack_group
WHERE
  afftrack_group.name::text = ANY (ARRAY[
  'Red team (main group)'::character varying::text,
  'Black team (партнерка)'::character varying::text,
  'Blue Team'::character varying::text
  ]);
----------------------------- Тут заканчивается соотненсение aff_id и команд в компании -----------------------------

----------------------------- Тут начинается отображение исходника функции -----------------------------
select proname,prosrc from pg_proc where proname='calculate_margin';
----------------------------- Тут заканчивается отображение исходника функции -----------------------------


