SELECT CONCAT('drop table coca_dev.', table_name, ';') FROM information_schema.tables WHERE TABLE_SCHEMA LIKE "coca_dev";
