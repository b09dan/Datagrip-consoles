DROP TABLE IF EXISTS bogdan_temp_valeriia_fb;
CREATE TABLE bogdan_temp_valeriia_fb AS
SELECT
  user_id,
  deal_amount,
  win_amount,
  to_timestamp(exp_time),
  active_id,
  option_type_id,
  registration_platform,
  'train' AS account_type,
  aff_id, aff_track
FROM
  stat_train_deals_data
WHERE registration_date >= '2018-03-01'
AND registration_date <= '2018-03-11'
AND aff_track IN ('mob_Facebook Ads_WW-English_iOS_WW-purchase-new_2018-03-01',
'mob_Facebook Ads_GB_iOS_2018_GB_2-100-iOS_LAL5_2018-03-06',
'mob_Facebook Ads_HK_iOS_2018_HK_2-100-iOS_LAL10_2018-03-06',
'mob_Facebook Ads_MY_iOS_2018_MY_2-100-iOS_LAL5_2018-03-06',
'mob_Facebook Ads_TH_iOS_2018_TH_2-200-iOS_LAL3_2018-03-06',
'mob_Facebook Ads_UAE_iOS_2018_AE_2-100-iOS_LAL10_2018-03-06',
'mob_Facebook Ads_ZA_iOS_2018_ZA_2-100-iOS_LAL5_2018-03-06')

UNION ALL

SELECT
  user_id,
  deal_amount,
  win_amount,
  exp_time,
  active_id,
  option_type_id,
  registration_platform,
  'train' AS account_type,
  aff_id, aff_track
FROM
  stat_train_deals_data_instruments
WHERE registration_date >= '2018-03-01'
AND registration_date <= '2018-03-11'
AND aff_track IN ('mob_Facebook Ads_WW-English_iOS_WW-purchase-new_2018-03-01',
'mob_Facebook Ads_GB_iOS_2018_GB_2-100-iOS_LAL5_2018-03-06',
'mob_Facebook Ads_HK_iOS_2018_HK_2-100-iOS_LAL10_2018-03-06',
'mob_Facebook Ads_MY_iOS_2018_MY_2-100-iOS_LAL5_2018-03-06',
'mob_Facebook Ads_TH_iOS_2018_TH_2-200-iOS_LAL3_2018-03-06',
'mob_Facebook Ads_UAE_iOS_2018_AE_2-100-iOS_LAL10_2018-03-06',
'mob_Facebook Ads_ZA_iOS_2018_ZA_2-100-iOS_LAL5_2018-03-06')

UNION ALL

SELECT
  user_id,
  deal_amount,
  win_amount,
  exp_time,
  active_id,
  option_type_id,
  registration_platform,
  'demo' AS account_type,
  aff_id, aff_track
FROM
  stat_demo_instruments
WHERE registration_date >= '2018-03-01'
AND registration_date <= '2018-03-11'
AND aff_track IN ('mob_Facebook Ads_WW-English_iOS_WW-purchase-new_2018-03-01',
'mob_Facebook Ads_GB_iOS_2018_GB_2-100-iOS_LAL5_2018-03-06',
'mob_Facebook Ads_HK_iOS_2018_HK_2-100-iOS_LAL10_2018-03-06',
'mob_Facebook Ads_MY_iOS_2018_MY_2-100-iOS_LAL5_2018-03-06',
'mob_Facebook Ads_TH_iOS_2018_TH_2-200-iOS_LAL3_2018-03-06',
'mob_Facebook Ads_UAE_iOS_2018_AE_2-100-iOS_LAL10_2018-03-06',
'mob_Facebook Ads_ZA_iOS_2018_ZA_2-100-iOS_LAL5_2018-03-06')

UNION ALL

SELECT
  user_id,
  deal_amount,
  win_amount,
  to_timestamp(exp_time),
  active_id,
  option_type_id,
  registration_platform,
  'demo' AS account_type,
  aff_id, aff_track
FROM
  stat_demo_deals_only_data
WHERE registration_date >= '2018-03-01'
AND registration_date <= '2018-03-11'
AND aff_track IN ('mob_Facebook Ads_WW-English_iOS_WW-purchase-new_2018-03-01',
'mob_Facebook Ads_GB_iOS_2018_GB_2-100-iOS_LAL5_2018-03-06',
'mob_Facebook Ads_HK_iOS_2018_HK_2-100-iOS_LAL10_2018-03-06',
'mob_Facebook Ads_MY_iOS_2018_MY_2-100-iOS_LAL5_2018-03-06',
'mob_Facebook Ads_TH_iOS_2018_TH_2-200-iOS_LAL3_2018-03-06',
'mob_Facebook Ads_UAE_iOS_2018_AE_2-100-iOS_LAL10_2018-03-06',
'mob_Facebook Ads_ZA_iOS_2018_ZA_2-100-iOS_LAL5_2018-03-06')
;

SELECT * FROM users WHERE user_id = 3432211