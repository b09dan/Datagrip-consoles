--Сравниваем 168 по stat_adwords_geo
SELECT
  SUM(stat_adwords_geo.cost / 1000000) AS aff_cost
FROM stat_adwords_geo
LEFT JOIN adwords_country_criteria_id
  ON stat_adwords_geo.countrycriteriaid = adwords_country_criteria_id.criteria_id
WHERE stat_adwords_geo.date > '12-01-2017'
  AND stat_adwords_geo.date < '12-31-2017'
  AND accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname NOT LIKE '%1%';

--Сравниваем 168 по stat_temp_g & stat_temp_g_uac
SELECT SUM(aff_cost) FROM
  (SELECT
    stat_temp_g.cost / 1000000 AS aff_cost
  FROM stat_temp_g
  WHERE stat_temp_g.date > '12-01-2017'
  AND stat_temp_g.date < '12-31-2017'
  AND accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname NOT LIKE '%1%'
  UNION ALL
  SELECT
    stat_temp_g_uac.cost / 1000000 AS aff_cost
  FROM stat_temp_g_uac
  WHERE stat_temp_g_uac.date > '12-01-2017'
  AND stat_temp_g_uac.date < '12-31-2017'
  AND accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname NOT LIKE '%1%'
  ) as stat_temp_g_all
;

------------------------------- Теперь сравниваем более детатльно -------------------------------
SELECT * FROM(
  SELECT
    stat_adwords_geo.campaignname,
    SUM(stat_adwords_geo.cost / 1000000) AS aff_cost
  FROM stat_adwords_geo
  WHERE stat_adwords_geo.date >= '12-01-2017'
    AND stat_adwords_geo.date <= '12-31-2017'
    AND accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname NOT LIKE '%1%'
  GROUP BY campaignname) AS stat_adwords_geo_one_company
FULL OUTER JOIN (
  SELECT campaignname, SUM(aff_cost) FROM(
    SELECT
    stat_temp_g.campaignname,
      stat_temp_g.cost / 1000000 AS aff_cost
    FROM stat_temp_g
    WHERE stat_temp_g.date > '12-01-2017'
    AND stat_temp_g.date < '12-31-2017'
    AND accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname NOT LIKE '%1%'
    UNION ALL
    SELECT
    stat_temp_g_uac.campaignname,
      stat_temp_g_uac.cost / 1000000 AS aff_cost
    FROM stat_temp_g_uac
    WHERE stat_temp_g_uac.date >= '12-01-2017'
    AND stat_temp_g_uac.date <= '12-31-2017'
    AND accountdescriptivename = 'RED: WEB SEARCH' AND campaignname LIKE '%MDweb%' AND campaignname NOT LIKE '%1%'
    ) as stat_temp_g_all
  GROUP BY campaignname) AS stat_temp_g_one_company ON stat_adwords_geo_one_company.campaignname = stat_temp_g_one_company.campaignname;



------------------------------- Теперь сравниваем более детатльно (campaignname = 'MDweb__All_ENG_6-Cryptocurrency_Search_WEB')-------------------------------
SELECT * FROM(
  SELECT
    stat_adwords_geo.campaignname,
    stat_adwords_geo.cost / 1000000 AS aff_cost
  FROM stat_adwords_geo
  WHERE stat_adwords_geo.date >= '12-01-2017'
    AND stat_adwords_geo.date <= '12-31-2017'
    AND campaignname = 'MDweb__All_ENG_6-Cryptocurrency_Search_WEB'
             ) AS stat_adwords_geo_one_company
FULL OUTER JOIN (
  SELECT campaignname, aff_cost FROM(
    SELECT
    stat_temp_g.campaignname,
      stat_temp_g.cost / 1000000 AS aff_cost
    FROM stat_temp_g
    WHERE stat_temp_g.date > '12-01-2017'
    AND stat_temp_g.date < '12-31-2017'
    AND campaignname = 'MDweb__All_ENG_6-Cryptocurrency_Search_WEB'
    UNION ALL
    SELECT
    stat_temp_g_uac.campaignname,
      stat_temp_g_uac.cost / 1000000 AS aff_cost
    FROM stat_temp_g_uac
    WHERE stat_temp_g_uac.date >= '12-01-2017'
    AND stat_temp_g_uac.date <= '12-31-2017'
    AND campaignname = 'MDweb__All_ENG_6-Cryptocurrency_Search_WEB'
    ) as stat_temp_g_all
                ) AS stat_temp_g_one_company ON stat_adwords_geo_one_company.campaignname = stat_temp_g_one_company.campaignname