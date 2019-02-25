CREATE TABLE aaaa_stat_transactions_data AS
select
*
from stat_transactions_data
where transaction_type = 'deposit'
AND stat_transactions_data.registration_date >= '2018-01-01'