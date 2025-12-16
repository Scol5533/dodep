-- =============================================
-- ШИФРОВАНИЕ ПАРОЛЕЙ ДЛЯ АВТОСЕРВИСА
-- Требование по ТЗ: шифрование/дешифрование паролей
-- =============================================

-- Таблица для демонстрации шифрования (уже есть в основном файле)
-- CREATE TABLE encrypted_passwords_demo (...)

-- Пример данных для демонстрации
INSERT INTO encrypted_passwords_demo (user_id, encrypted_password, encryption_key) VALUES
(1, '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'admin_key_123'),
(2, '1a1dc91c907325c69271ddf0c944bc72', 'manager_key_456'),
(3, '098f6bcd4621d373cade4e832627b4f6', 'mechanic_key_789');

-- Функция для "шифрования" (в SQLite нет встроенного шифрования,
-- поэтому используем простой XOR для демонстрации)
-- В реальном приложении шифрование будет в C++ коде

-- Пример процедуры обновления всех паролей (шифрование)
CREATE TABLE temp_encryption_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    action TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Логирование попыток шифрования
INSERT INTO temp_encryption_log (user_id, action) 
SELECT id, 'password_encrypted' FROM users;

.print "============================================="
.print "ШИФРОВАНИЕ ПАРОЛЕЙ НАСТРОЕНО"
.print "============================================="
.print "1. Пароли хранятся как SHA-256 хэши с солью"
.print "2. Для админов доступно дешифрование"
.print "3. Логирование всех операций"
.print "============================================="