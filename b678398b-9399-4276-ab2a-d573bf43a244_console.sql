--Вывести все затраты по aff_id в разрезе периодов и aff_id
SELECT
(CASE
 WHEN date >= '2018-02-01' AND date < '2018-02-08'
   THEN '1st period'
 WHEN date >= '2018-02-21' AND date < '2018-02-28'
   THEN '2nd period'
 ELSE 'others'
 END)               AS period,
(CASE
 WHEN
   (accountdescriptivename = 'RED: MOB (first open)' AND campaignname ILIKE '%android%')
   OR campaignname ILIKE 'REM-Youtube%GDN%'
   OR campaignname ILIKE 'UK_GDN_TEST_%GDN%'
   OR campaignname ILIKE 'GDN_%GUWR%'
   OR campaignname ILIKE '%iOS: mob_adwords_%Android: adwords_%'
   THEN 166
 END)               AS aff_iddd,
SUM(cost / 1000000) AS cost
FROM stat_temp_g_uac
WHERE date >= '2018-02-01'
GROUP BY period, aff_iddd
;



-- Вывод всех затрат, кол-во регистраций, кол-во вносящих депозит, сумм депозитов по aff_id
SELECT
  costs_for_aff_id.period,
  aff_iddd,
  cost,
  SUM(users) AS users_sum,
  SUM(payements_1st_day) AS payements_1st_day_sum,
  SUM(payers_1st_day) AS payers_1st_day_sum
FROM
(
  SELECT
    (CASE
     WHEN date >= '2018-02-01' AND date < '2018-02-08'
       THEN '1st period'
     WHEN date >= '2018-02-21' AND date < '2018-02-28'
       THEN '2nd period'
     ELSE 'others'
     END)               AS period,
    (CASE
     WHEN
       (accountdescriptivename = 'RED: MOB (first open)' AND campaignname ILIKE '%android%')
       OR campaignname ILIKE 'REM-Youtube%GDN%'
       OR campaignname ILIKE 'UK_GDN_TEST_%GDN%'
       OR campaignname ILIKE 'GDN_%GUWR%'
       OR campaignname ILIKE '%iOS: mob_adwords_%Android: adwords_%'
       THEN 166
     END)               AS aff_iddd,
    SUM(cost / 1000000) AS cost
  FROM stat_temp_g_uac
  WHERE date >= '2018-02-01'
  GROUP BY period, aff_iddd
) AS costs_for_aff_id
RIGHT JOIN (
select
     (case
        when created >= '2018-02-01' and  created < '2018-02-08'
          then '1st period'
        when created >= '2018-02-21' and  created < '2018-02-28' then '2nd period'
              else 'others' end) as period,
     aff_id,
     count(distinct user_id) users,
     count(distinct case when day_0 > 0 then user_id end) payers_1st_day,
     sum(case when day_0 > 0 then day_0 else 0 end) payements_1st_day

 from stat_users_data
 where created >= '2018-02-01' and  created < '2018-03-01' and (aff_id = 166 or aff_id = 168)
 group by (case when created >= '2018-02-01' and  created < '2018-02-08' then '1st period'
              when created >= '2018-02-21' and  created < '2018-02-28' then '2nd period'
              else 'others' end), aff_id
) AS just_transaction_sums_regs
ON just_transaction_sums_regs.aff_id = aff_iddd
  AND just_transaction_sums_regs.period = costs_for_aff_id.period
GROUP BY
  costs_for_aff_id.period,
  aff_iddd,
  cost;


-- То же самое, что и выше, но с дополнительной разбивкой по кампаниям
SELECT
  costs_for_aff_id.period,
  aff_iddd,
  compaing_name_parsed,
  campaignid,
  cost,
  SUM(users) AS users_sum,
  SUM(payements_1st_day) AS payements_1st_day_sum,
  SUM(payers_1st_day) AS payers_1st_day_sum
FROM
(
  SELECT
    (CASE
     WHEN date >= '2018-02-01' AND date < '2018-02-08'
       THEN '1st period'
     WHEN date >= '2018-02-21' AND date < '2018-02-28'
       THEN '2nd period'
     ELSE 'others'
     END)               AS period,
    (CASE
     WHEN
       (accountdescriptivename = 'RED: MOB (first open)' AND campaignname ILIKE '%android%')
       OR campaignname ILIKE 'REM-Youtube%GDN%'
       OR campaignname ILIKE 'UK_GDN_TEST_%GDN%'
       OR campaignname ILIKE 'GDN_%GUWR%'
       OR campaignname ILIKE '%iOS: mob_adwords_%Android: adwords_%'
       THEN 166
     END)               AS aff_iddd,
    campaignid,
    SUM(cost / 1000000) AS cost
  FROM stat_temp_g_uac
  WHERE date >= '2018-02-01'
  GROUP BY period, aff_iddd, campaignid
) AS costs_for_aff_id



RIGHT JOIN (
select
     (case
        when created >= '2018-02-01' and  created < '2018-02-08'
          then '1st period'
        when created >= '2018-02-21' and  created < '2018-02-28' then '2nd period'
              else 'others' end) as period,
     aff_id,

    (CASE
      WHEN aff_track ILIKE 'adwords\_%'
       THEN substring(aff_track from 9 for (char_length(aff_track)-8))
      WHEN aff_track ILIKE 'mob\_adwords\_%'
       THEN substring(aff_track from 13 for (char_length(aff_track)-12))
    END)::BIGINT AS compaing_name_parsed,

     count(distinct user_id) users,
     count(distinct case when day_0 > 0 then user_id end) payers_1st_day,
     sum(case when day_0 > 0 then day_0 else 0 end) payements_1st_day

 from stat_users_data
 where created >= '2018-02-01' and  created < '2018-03-01' and (aff_id = 166 or aff_id = 168)
 group by
   (case
      when created >= '2018-02-01' and  created < '2018-02-08'
       then '1st period'
      when created >= '2018-02-21' and  created < '2018-02-28'
       then '2nd period'
      else 'others'
   end),
   aff_id,
   (CASE
      WHEN aff_track ILIKE 'adwords\_%'
       THEN substring(aff_track from 9 for (char_length(aff_track)-8))
      WHEN aff_track ILIKE 'mob\_adwords\_%'
       THEN substring(aff_track from 13 for (char_length(aff_track)-12))
    END)::BIGINT
) AS just_transaction_sums_regs
ON just_transaction_sums_regs.aff_id = aff_iddd
  AND just_transaction_sums_regs.period = costs_for_aff_id.period
  AND compaing_name_parsed = costs_for_aff_id.campaignid
GROUP BY
  costs_for_aff_id.period,
  aff_iddd,
  compaing_name_parsed,
  campaignid,
  cost;


-- Парсинг номеров кампаний из aff_track

SELECT
  DISTINCT aff_track,
  (CASE
    WHEN aff_track ILIKE 'adwords\_%'
     THEN substring(aff_track from 9 for (char_length(aff_track)-8))
    WHEN aff_track ILIKE 'mob\_adwords\_%'
     THEN substring(aff_track from 13 for (char_length(aff_track)-12))
  END) AS compaing_name_parsed
FROM
  stat_users_data
WHERE aff_id = 166
  --AND aff_track NoT LIKE '%adwords\_%'
  AND created >= '2018-02-01'
LIMIT 1000;





---Проверка 1023087100
SELECT COUNT(*)
FROM stat_users_data
WHERE aff_id = 166
  AND created >= '2018-02-21'
  AND aff_track ILIKE '%1023087100%'

