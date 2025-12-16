BEGIN TRANSACTION;

-- Сохраняем текущую дату и время
CREATE TEMP TABLE backup_info (
    backup_date TEXT,
    database_name TEXT,
    record_count INTEGER
);

INSERT INTO backup_info VALUES (
    datetime('now', 'localtime'),
    'autoservice.db',
    (SELECT COUNT(*) FROM sqlite_master WHERE type='table')
);

-- Дамп всех таблиц с данными
SELECT '-- =============================================' AS '';
SELECT '-- РЕЗЕРВНАЯ КОПИЯ БАЗЫ ДАННЫХ АВТОСЕРВИСА' AS '';
SELECT '-- Создано: ' || backup_date FROM backup_info;
SELECT '-- =============================================' AS '';
SELECT '' AS '';

-- Дамп схемы
SELECT sql || ';' FROM sqlite_master 
WHERE type IN ('table', 'index', 'trigger', 'view') 
AND name NOT LIKE 'sqlite_%'
AND name NOT LIKE 'temp_%';

SELECT '' AS '';
SELECT '-- =============================================' AS '';
SELECT '-- ДАННЫЕ ИЗ ТАБЛИЦ' AS '';
SELECT '-- =============================================' AS '';
SELECT '' AS '';

-- Дамп данных (пропускаем временные таблицы и системные)
.mode insert
SELECT * FROM users;
SELECT * FROM clients;
SELECT * FROM cars;
SELECT * FROM employees;
SELECT * FROM service_categories;
SELECT * FROM services;
SELECT * FROM spare_parts;
SELECT * FROM suppliers;
SELECT * FROM work_orders;
SELECT * FROM order_services;
SELECT * FROM order_parts;
SELECT * FROM payments;
SELECT * FROM warehouse_transactions;
SELECT * FROM supplies;
SELECT * FROM supply_items;
SELECT * FROM car_history;
SELECT * FROM service_reminders;

-- Информация о бэкапе
SELECT '' AS '';
SELECT '-- =============================================' AS '';
SELECT '-- ИНФОРМАЦИЯ О РЕЗЕРВНОЙ КОПИИ' AS '';
SELECT '-- Дата создания: ' || backup_date FROM backup_info;
SELECT '-- Имя БД: ' || database_name FROM backup_info;
SELECT '-- Таблиц в БД: ' || record_count FROM backup_info;
SELECT '-- =============================================' AS '';

COMMIT;

DROP TABLE backup_info;

.print "============================================="
.print "РЕЗЕРВНАЯ КОПИЯ УСПЕШНО СОЗДАНА"
.print "============================================="
.print "Сохраните этот SQL-файл как backup_YYYYMMDD.sql"
.print "Для восстановления выполните:"
.print "sqlite3 autoservice.db < backup_YYYYMMDD.sql"
.print "============================================="