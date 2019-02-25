SELECT
  country_name,
  --campaignname,
  --aff_id,
  SUM(cost)
FROM bogdan_temp_countries
WHERE country_name ISNULL
GROUP BY country_name
  --, campaignname,
  --aff_id


EXPLAIN ANALYSE;

select * from pg_stat_activity; -- all data
select pg_cancel_backend(23539); -- cancel pid
select pg_terminate_backend(23539); -- terminate unless cancel helps



SELECT
  *
FROM
  bogdan_temp_countries
JOIN bogdan_temp_pnl
  ON bogdan_temp_countries.aff_id = bogdan_temp_pnl.aff_id;

SELECT
  country_name,
  SUM(cost),
  SUM(pnl)
FROM
  bogdan_temp_countries
JOIN bogdan_temp_pnl
  ON bogdan_temp_countries.aff_id = bogdan_temp_pnl.aff_id
GROUP BY country_name
;