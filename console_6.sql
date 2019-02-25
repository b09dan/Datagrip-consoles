SELECT * FROM (
------------------------- stat_adwords_geo -------------------------
SELECT
  LOWER(adwords_country_criteria_id.canonical_name) as country_name,
  -- account_id,
  -- stat_adwords_geo.accountdescriptivename,
  stat_adwords_geo.cost / 1000000 AS cost,
  (
  CASE
    WHEN accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname LIKE '%1%'
      THEN 1
    WHEN (accountdescriptivename = 'RED: WEB GDN' AND campaignname LIKE '%MDweb%' AND campaignname LIKE '%GDN%')
          OR (accountdescriptivename = 'RED: Forex' AND campaignname ILIKE '%forex%')
      THEN 150
    WHEN accountdescriptivename = 'RED: MOB (first open)' AND campaignname ILIKE '%ios%'
      THEN 162
    WHEN accountdescriptivename = 'RED: MOB (first open)' AND campaignname ILIKE '%android%'
      THEN 166
    WHEN accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname NOT LIKE '%1%'
      THEN 168
  END) AS aff_id
FROM stat_adwords_geo
LEFT JOIN adwords_country_criteria_id
  ON stat_adwords_geo.countrycriteriaid = adwords_country_criteria_id.criteria_id
-- LIMIT 100;
UNION




SELECT
--   LOWER(adwords_country_criteria_id.canonical_name) as country_name,
  -- account_id,
  -- stat_adwords_geo.accountdescriptivename,
  SUM(stat_adwords_geo.cost / 1000000) AS aff_cost,
  (
  CASE
    WHEN accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname LIKE '%1%'
      THEN 1
    WHEN (accountdescriptivename = 'RED: WEB GDN' AND campaignname LIKE '%MDweb%' AND campaignname LIKE '%GDN%')
          OR (accountdescriptivename = 'RED: Forex' AND campaignname ILIKE '%forex%')
      THEN 150
    WHEN accountdescriptivename = 'RED: MOB (first open)' AND campaignname ILIKE '%ios%'
      THEN 162
    WHEN accountdescriptivename = 'RED: MOB (first open)' AND campaignname ILIKE '%android%'
      THEN 166
    WHEN accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname NOT LIKE '%1%'
      THEN 168
  END) AS aff_id
FROM stat_adwords_geo
LEFT JOIN adwords_country_criteria_id
  ON stat_adwords_geo.countrycriteriaid = adwords_country_criteria_id.criteria_id
WHERE stat_adwords_geo.date > '12-01-2017'
  AND stat_adwords_geo.date < '12-31-2017'
GROUP BY aff_id
;
-- LIMIT 100;

-- Пересечения компаний 759 строк
SELECT
  stat_temp_g_uac.accountdescriptivename,
  stat_temp_g_uac.campaignname,
  adwords_exceptions.campaignname,
  (
  CASE
    WHEN accountdescriptivename = 'RED: WEB SEARCH' AND stat_temp_g_uac.campaignname LIKE '%MDweb%' AND stat_temp_g_uac.campaignname LIKE '%1%'
      THEN 1
    WHEN (accountdescriptivename = 'RED: WEB GDN' AND stat_temp_g_uac.campaignname LIKE '%MDweb%' AND stat_temp_g_uac.campaignname LIKE '%GDN%')
          OR (accountdescriptivename = 'RED: Forex' AND stat_temp_g_uac.campaignname ILIKE '%forex%')
      THEN 150
    WHEN accountdescriptivename = 'RED: MOB (first open)' AND stat_temp_g_uac.campaignname ILIKE '%ios%'
      THEN 162
    WHEN accountdescriptivename = 'RED: MOB (first open)' AND stat_temp_g_uac.campaignname ILIKE '%android%'
      THEN 166
    WHEN accountdescriptivename = 'RED: WEB SEARCH' AND stat_temp_g_uac.campaignname LIKE '%MDweb%' AND stat_temp_g_uac.campaignname NOT LIKE '%1%'
      THEN 168
  END) AS aff_id
FROM (
  SELECT stat_temp_g.campaignname
  FROM stat_temp_g
  EXCEPT
  SELECT stat_adwords_geo.campaignname
  FROM stat_adwords_geo
  UNION
  SELECT stat_temp_g_uac.campaignname
  FROM stat_temp_g_uac
  EXCEPT
  SELECT stat_adwords_geo.campaignname
  FROM stat_adwords_geo) AS adwords_exceptions
LEFT JOIN stat_temp_g_uac
ON stat_temp_g_uac.campaignname = adwords_exceptions.campaignname;



SELECT SUM(aff_cost), aff_id FROM
  (SELECT
    stat_temp_g.cost / 1000000 AS aff_cost,
    (
    CASE
      WHEN accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname LIKE '%1%'
        THEN 1
      WHEN (accountdescriptivename = 'RED: WEB GDN' AND campaignname LIKE '%MDweb%' AND campaignname LIKE '%GDN%')
            OR (accountdescriptivename = 'RED: Forex' AND campaignname ILIKE '%forex%')
        THEN 150
      WHEN accountdescriptivename = 'RED: MOB (first open)' AND campaignname ILIKE '%ios%'
        THEN 162
      WHEN accountdescriptivename = 'RED: MOB (first open)' AND campaignname ILIKE '%android%'
        THEN 166
      WHEN accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname NOT LIKE '%1%'
        THEN 168
    END) AS aff_id
  FROM stat_temp_g
  WHERE stat_temp_g.date > '12-01-2017'
  AND stat_temp_g.date < '12-31-2017'
  UNION ALL
  SELECT
    stat_temp_g_uac.cost / 1000000 AS aff_cost,
    (
    CASE
      WHEN accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname LIKE '%1%'
        THEN 1
      WHEN (accountdescriptivename = 'RED: WEB GDN' AND campaignname LIKE '%MDweb%' AND campaignname LIKE '%GDN%')
            OR (accountdescriptivename = 'RED: Forex' AND campaignname ILIKE '%forex%')
        THEN 150
      WHEN accountdescriptivename = 'RED: MOB (first open)' AND campaignname ILIKE '%ios%'
        THEN 162
      WHEN accountdescriptivename = 'RED: MOB (first open)' AND campaignname ILIKE '%android%'
        THEN 166
      WHEN accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname NOT LIKE '%1%'
        THEN 168
    END) AS aff_id
  FROM stat_temp_g_uac
  WHERE stat_temp_g_uac.date > '12-01-2017'
  AND stat_temp_g_uac.date < '12-31-2017'
  ) as stat_temp_g_all
GROUP BY aff_id
;




SELECT stat_temp_g.campaignname, SUM(stat_temp_g.cost) / 1000000 as sum_cost
FROM stat_temp_g
WHERE stat_temp_g.campaignname = '15_SNG_RU_1_A_Search_Web'
  AND stat_temp_g.date > '12-01-2017'
  AND stat_temp_g.date < '12-31-2017'
GROUP BY campaignname;



SELECT DISTINCT(campaignname)
FROM stat_temp_g_uac;




SELECT DISTINCT(adwords_country_criteria_id.canonical_name)
FROM adwords_country_criteria_id;