INSERT INTO `dispensary`.`tb_users`
(`group_id`, `username`, `password`, `email`, `first_name`, `last_name`, `active`, `login_attempt`, `last_login`, `created_at`, `updated_at`, `remember_token`, `is_driver`, `current_flag`)
VALUES ('1', 'Andy', '$2y$12$6rjhcOwhCEGmfyDqhr7MxuX2hPNp8TxLD4JkvZepRut0vD0idvjyi', 'andy@treez.io', 'Andy', 'Newman', '1', '0', '2020-11-06 13:46:14', '2020-11-06 13:42:59', '2020-11-06 13:46:18', 'GENERATED password', '0', '1');

-- UPDATE `inventory`.`tz_configuration` SET `value` = 'http://localhost:8303' WHERE (`id` = '987EA439-5DA4-4C77-B011-9298DB5B64AB');
update inventory.tz_configuration set value = 'http://localhost:8303' where code = 'PRODUCT_API_URL';
UPDATE `inventory`.`tz_configuration` SET `value` = '1' WHERE code = `CATALOG_ID`;
