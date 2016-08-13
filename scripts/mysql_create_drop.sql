SELECT CONCAT('drop table placeHolder.', table_name, ';') FROM information_schema.tables WHERE TABLE_SCHEMA LIKE "placeHolder";
