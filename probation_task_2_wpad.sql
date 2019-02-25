-- Подготовка аналитики по эффективности закупки трафика внутренних маркетинговых команд в разрезе определённых биржевых инструментов торговли.
-- Что там делает блю тим по форексу, откуда у них прибыль в 2 раза больше, чем у нас - разобраться?
----------------------------- Тут начинается сбор датасета для дерева решений для выявления разницы -----------------------------
DROP TABLE IF EXISTS bogdan_temp_positions_4_users;
CREATE TABLE bogdan_temp_positions_4_users AS
SELECT
  users.is_demo,
  temp_positions.*,
  affs_4_teams.traffic_name,
  affs_4_teams.aff_id,
  users.user_landing_id,
  users.is_regulated,
  users.is_trial,
  users.tz,
  users.country_id,
  EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM users.birthdate) AS user_age
FROM
  dblink(
      'host=10.0.30.44 dbname=option_trading user=o_readonly password=jieghu9ke3OonoKe port=5432',
      '
      SELECT
        user_id,
        create_at :: DATE,
        buy_amount_enrolled,
        buy_avg_price_enrolled,
        leverage, -- Плечо с которым игрок делает ставку
        is_dma,
        instrument_id, -- Например, какая именно валютная пара используется для торговли
        position_type,
        (case
        when position_type = ''long''
          then buy_amount_enrolled / (1000000.0 * leverage)
        when position_type = ''short''
          then sell_amount_enrolled / (1000000.0 * leverage)
        end) as invest_amount_enrolled,
        (case
        when position_type = ''long''
          then (buy_amount_enrolled - sell_amount_enrolled)/ (1000000.0 * leverage)
        when position_type = ''short''
          then (sell_amount_enrolled - buy_amount_enrolled)/ (1000000.0 * leverage)
        end) as profit
      FROM
        data.positions
      WHERE instrument_type = ''forex''
      AND create_at >= ''2018-01-01''::DATE
      '
  )
as temp_positions(
  user_id bigint,
  create_at date,
  buy_amount_enrolled bigint,
  buy_avg_price_enrolled bigint,
  leverage integer,
  is_dma boolean,
  instrument_id text,
  position_type text,
  invest_amount_enrolled FLOAT,
  profit FLOAT
     )
JOIN users
  ON users.id = temp_positions.user_id
JOIN
(
  --------> Get data for aff_id and marketing teams names
  SELECT
    DISTINCT
    unnest(string_to_array(afftrack_group.affs, ',' :: TEXT)) :: BIGINT AS aff_id,
    afftrack_group.name AS traffic_name
  FROM
    afftrack_group
  WHERE
    afftrack_group.name :: TEXT = ANY (ARRAY [
    'Red team (main group)' :: CHARACTER VARYING :: TEXT,
    'Black team (партнерка)' :: CHARACTER VARYING :: TEXT,
    'Blue Team' :: CHARACTER VARYING :: TEXT
    ])
  ) AS affs_4_teams
ON users.aff_id = affs_4_teams.aff_id
  --------<
WHERE traffic_name IN ('Blue Team', 'Red team (main group)')
  AND users.is_demo = FALSE
;
----------------------------- Тут заканчивается сбор датасета для дерева решений для выявления разницы -----------------------------



----------------------------- Тут начинается создание временной таблицы для сопоставления затрат на рекламные компании и прибыли с форекса -----------------------------
CREATE TABLE bogdan_temp_google_stat AS
SELECT
  account_id,
  accountdescriptivename,
  campaignid,
  campaignname,
  impressions,
  clicks,
  cost,
  averageposition,
  date
FROM stat_temp_g_uac
WHERE stat_temp_g_uac.date >= '2018-01-01'
UNION ALL
SELECT
  account_id,
  accountdescriptivename,
  campaignid,
  campaignname,
  impressions,
  clicks,
  cost,
  averageposition,
  date
FROM stat_temp_g
WHERE stat_temp_g.date >= '2018-01-01';
----------------------------- Тут заканчивается сбор датасета для дерева решений для выявления разницы -----------------------------



SELECT count(*)
FROM bogdan_temp_positions_4_users

