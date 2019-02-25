DROP INDEX options_analytics.bogdan_temp_demo_vs_train_user_id_index RESTRICT;
DROP INDEX options_analytics.bogdan_temp_demo_vs_train_to_timestamp_index RESTRICT;
DROP INDEX options_analytics.bogdan_temp_demo_vs_train_registration_platform_index RESTRICT;
DROP INDEX options_analytics.bogdan_temp_demo_vs_train_aff_id_index RESTRICT;


CREATE TABLE bogdan_temp_demo_vs_train_v2 AS
SELECT
  user_id,
  deal_amount,
  win_amount,
  to_timestamp,
  active_id,
  option_type_id,
  registration_platform,
  account_type,
  aff_id,
  aff_track,
  (CASE
    WHEN to_timestamp >= TIMESTAMP '2017-05-01 00:00:00.000000' AND to_timestamp <= TIMESTAMP '2017-05-31 00:00:00.000000'
      THEN 'period_may'
    WHEN to_timestamp >= TIMESTAMP '2017-10-01 00:00:00.000000' AND to_timestamp <= TIMESTAMP '2017-10-31 00:00:00.000000'
     THEN 'period_october'
    WHEN to_timestamp >= TIMESTAMP '2018-02-01 00:00:00.000000' AND to_timestamp <= TIMESTAMP '2018-03-21 00:00:00.000000'
     THEN 'period_now'
   END) AS period
FROM bogdan_temp_demo_vs_train;




CREATE INDEX bogdan_temp_demo_vs_train_user_id_index ON options_analytics.bogdan_temp_demo_vs_train (user_id);
CREATE INDEX bogdan_temp_demo_vs_train_to_timestamp_index ON options_analytics.bogdan_temp_demo_vs_train (to_timestamp);
CREATE INDEX bogdan_temp_demo_vs_train_aff_id_index ON options_analytics.bogdan_temp_demo_vs_train (aff_id);
CREATE INDEX bogdan_temp_demo_vs_train_registration_platform_index ON options_analytics.bogdan_temp_demo_vs_train (registration_platform);
CREATE INDEX bogdan_temp_demo_vs_train_period_index ON options_analytics.bogdan_temp_demo_vs_train (period);


CREATE INDEX bogdan_temp_demo_vs_train_light_user_id_index ON options_analytics.bogdan_temp_demo_vs_train_light (user_id);
CREATE INDEX bogdan_temp_demo_vs_train_light_date_trading_start_index ON options_analytics.bogdan_temp_demo_vs_train_light (date_trading_start);
CREATE INDEX bogdan_temp_demo_vs_train_light_date_trading_end_index ON options_analytics.bogdan_temp_demo_vs_train_light (date_trading_end);
CREATE INDEX bogdan_temp_demo_vs_train_light_aff_id_index ON options_analytics.bogdan_temp_demo_vs_train_light (aff_id);
CREATE INDEX bogdan_temp_demo_vs_train_light_registration_platform_index ON options_analytics.bogdan_temp_demo_vs_train_light (registration_platform);
CREATE INDEX bogdan_temp_demo_vs_train_light_registration_date_index ON options_analytics.bogdan_temp_demo_vs_train_light (registration_date);
CREATE INDEX bogdan_temp_demo_vs_train_light_period_index ON options_analytics.bogdan_temp_demo_vs_train_light (period);
CREATE INDEX bogdan_temp_demo_vs_train_light_account_type_index ON options_analytics.bogdan_temp_demo_vs_train_light (acwcount_type);


SELECT COUNT(*) FROM bogdan_temp_demo_vs_train;


SELECT * FROM bogdan_temp_demo_vs_train_light;





-- Добавить поле
ALTER TABLE bogdan_temp_demo_vs_train
ADD period CHAR(14);
UPDATE bogdan_temp_demo_vs_train
  SET period = CASE
    WHEN to_timestamp >= TIMESTAMP '2017-05-01 00:00:00.000000' AND to_timestamp <= TIMESTAMP '2017-05-31 00:00:00.000000'
      THEN 'period_may'
    WHEN to_timestamp >= TIMESTAMP '2017-10-01 00:00:00.000000' AND to_timestamp <= TIMESTAMP '2017-10-31 00:00:00.000000'
     THEN 'period_october'
    WHEN to_timestamp >= TIMESTAMP '2018-02-01 00:00:00.000000' AND to_timestamp <= TIMESTAMP '2018-03-21 00:00:00.000000'
     THEN 'period_now'
  END
;
