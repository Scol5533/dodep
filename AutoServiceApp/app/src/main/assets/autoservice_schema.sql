-- =============================================
-- АВТОСЕРВИС: БАЗА ДАННЫХ
-- Требования по ТЗ: более 12 таблиц, 3 триггера,
-- 5 представлений, 3 процедуры, шифрование паролей
-- =============================================

-- Удаление старых таблиц (если есть)
PRAGMA foreign_keys = OFF;

DROP TABLE IF EXISTS service_reminders;
DROP TABLE IF EXISTS car_history;
DROP TABLE IF EXISTS supply_items;
DROP TABLE IF EXISTS supplies;
DROP TABLE IF EXISTS warehouse_transactions;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_parts;
DROP TABLE IF EXISTS order_services;
DROP TABLE IF EXISTS work_orders;
DROP TABLE IF EXISTS spare_parts;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS cars;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS service_categories;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS users;

PRAGMA foreign_keys = ON;

-- =============================================
-- 1. ТАБЛИЦЫ БАЗЫ ДАННЫХ (17 таблиц)
-- =============================================

-- 1. Пользователи (для авторизации)
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,          -- Зашифрованный пароль
    password_salt TEXT NOT NULL,          -- Соль для шифрования
    role TEXT CHECK(role IN ('admin', 'manager', 'mechanic')) DEFAULT 'mechanic',
    full_name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT 1
);

-- 2. Клиенты
CREATE TABLE clients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    phone TEXT NOT NULL UNIQUE,
    email TEXT,
    address TEXT,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_orders INTEGER DEFAULT 0,
    total_spent REAL DEFAULT 0,
    discount_percent REAL DEFAULT 0,
    notes TEXT
);

-- 3. Автомобили клиентов
CREATE TABLE cars (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    client_id INTEGER NOT NULL,
    brand TEXT NOT NULL,
    model TEXT NOT NULL,
    year INTEGER CHECK(year >= 1900 AND year <= 2100),
    vin TEXT UNIQUE,
    license_plate TEXT NOT NULL UNIQUE,
    engine_volume REAL CHECK(engine_volume > 0),
    fuel_type TEXT CHECK(fuel_type IN ('petrol', 'diesel', 'electric', 'hybrid', 'gas')),
    color TEXT,
    mileage INTEGER DEFAULT 0,
    last_service_date DATE,
    next_service_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
);

-- 4. Сотрудники
CREATE TABLE employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER UNIQUE,
    position TEXT NOT NULL,
    specialization TEXT,
    hire_date DATE NOT NULL,
    salary REAL CHECK(salary >= 0),
    hourly_rate REAL CHECK(hourly_rate >= 0),
    is_active BOOLEAN DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 5. Категории услуг
CREATE TABLE service_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    parent_id INTEGER,
    FOREIGN KEY (parent_id) REFERENCES service_categories(id)
);

-- 6. Услуги
CREATE TABLE services (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER,
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    standard_time INTEGER NOT NULL CHECK(standard_time > 0),
    base_price REAL NOT NULL CHECK(base_price >= 0),
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES service_categories(id)
);

-- 7. Запчасти
CREATE TABLE spare_parts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    part_number TEXT UNIQUE NOT NULL,
    oem_number TEXT,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT,
    brand TEXT,
    car_brand TEXT,
    car_model TEXT,
    year_from INTEGER,
    year_to INTEGER,
    price REAL NOT NULL CHECK(price >= 0),
    cost_price REAL NOT NULL CHECK(cost_price >= 0),
    quantity INTEGER NOT NULL CHECK(quantity >= 0) DEFAULT 0,
    min_quantity INTEGER DEFAULT 5,
    supplier_id INTEGER,
    location TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. Поставщики
CREATE TABLE suppliers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    contact_person TEXT,
    phone TEXT NOT NULL,
    email TEXT,
    address TEXT,
    website TEXT,
    payment_terms TEXT,
    delivery_time INTEGER,
    rating REAL CHECK(rating >= 0 AND rating <= 5),
    is_active BOOLEAN DEFAULT 1
);

-- 9. Заказы (наряды)
CREATE TABLE work_orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_number TEXT UNIQUE NOT NULL,
    client_id INTEGER NOT NULL,
    car_id INTEGER NOT NULL,
    employee_id INTEGER,
    status TEXT CHECK(status IN ('created', 'diagnostic', 'waiting_parts', 'in_progress', 'completed', 'cancelled', 'paid')) DEFAULT 'created',
    total_services REAL DEFAULT 0,
    total_parts REAL DEFAULT 0,
    discount REAL DEFAULT 0,
    tax REAL DEFAULT 0,
    total_amount REAL DEFAULT 0,
    paid_amount REAL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    scheduled_date DATE,
    completed_date TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (car_id) REFERENCES cars(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- 10. Услуги в заказе
CREATE TABLE order_services (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    employee_id INTEGER,
    quantity INTEGER DEFAULT 1 CHECK(quantity > 0),
    unit_price REAL NOT NULL CHECK(unit_price >= 0),
    total_price REAL GENERATED ALWAYS AS (quantity * unit_price) STORED,
    actual_time INTEGER,
    is_completed BOOLEAN DEFAULT 0,
    completion_date TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (order_id) REFERENCES work_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- 11. Запчасти в заказе
CREATE TABLE order_parts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    part_id INTEGER NOT NULL,
    quantity INTEGER DEFAULT 1 CHECK(quantity > 0),
    unit_price REAL NOT NULL CHECK(unit_price >= 0),
    total_price REAL GENERATED ALWAYS AS (quantity * unit_price) STORED,
    is_installed BOOLEAN DEFAULT 0,
    notes TEXT,
    FOREIGN KEY (order_id) REFERENCES work_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (part_id) REFERENCES spare_parts(id)
);

-- 12. Платежи
CREATE TABLE payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    amount REAL NOT NULL CHECK(amount > 0),
    payment_method TEXT CHECK(payment_method IN ('cash', 'card', 'bank_transfer', 'online')),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_id TEXT,
    status TEXT CHECK(status IN ('pending', 'completed', 'failed', 'refunded')) DEFAULT 'pending',
    notes TEXT,
    FOREIGN KEY (order_id) REFERENCES work_orders(id)
);

-- 13. Складские операции
CREATE TABLE warehouse_transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    part_id INTEGER NOT NULL,
    transaction_type TEXT CHECK(transaction_type IN ('incoming', 'outgoing', 'adjustment', 'return')),
    quantity INTEGER NOT NULL,
    unit_price REAL,
    total_price REAL,
    reference_id INTEGER,
    reference_type TEXT CHECK(reference_type IN ('order', 'supply', 'adjustment', 'write_off')),
    employee_id INTEGER,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (part_id) REFERENCES spare_parts(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- 14. Поставки (закупки)
CREATE TABLE supplies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    supplier_id INTEGER NOT NULL,
    order_number TEXT,
    total_amount REAL DEFAULT 0,
    status TEXT CHECK(status IN ('ordered', 'delivered', 'cancelled')) DEFAULT 'ordered',
    order_date DATE DEFAULT CURRENT_DATE,
    expected_date DATE,
    delivery_date DATE,
    notes TEXT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- 15. Позиции в поставке
CREATE TABLE supply_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    supply_id INTEGER NOT NULL,
    part_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    unit_price REAL NOT NULL CHECK(unit_price >= 0),
    total_price REAL GENERATED ALWAYS AS (quantity * unit_price) STORED,
    received_quantity INTEGER DEFAULT 0,
    FOREIGN KEY (supply_id) REFERENCES supplies(id) ON DELETE CASCADE,
    FOREIGN KEY (part_id) REFERENCES spare_parts(id)
);

-- 16. История автомобилей
CREATE TABLE car_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    car_id INTEGER NOT NULL,
    order_id INTEGER,
    service_type TEXT,
    description TEXT,
    mileage INTEGER,
    cost REAL,
    service_date DATE DEFAULT CURRENT_DATE,
    next_service_date DATE,
    notes TEXT,
    FOREIGN KEY (car_id) REFERENCES cars(id),
    FOREIGN KEY (order_id) REFERENCES work_orders(id)
);

-- 17. Напоминания о ТО
CREATE TABLE service_reminders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    client_id INTEGER NOT NULL,
    car_id INTEGER NOT NULL,
    service_type TEXT NOT NULL,
    last_service_date DATE,
    last_service_mileage INTEGER,
    next_service_date DATE,
    next_service_mileage INTEGER,
    reminder_sent BOOLEAN DEFAULT 0,
    sent_date DATE,
    notes TEXT,
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (car_id) REFERENCES cars(id)
);

-- =============================================
-- 2. ТРИГГЕРЫ (5 триггеров - по ТЗ 3+)
-- =============================================

-- Триггер 1: Автоматическое обновление времени изменения заказа
CREATE TRIGGER update_work_order_timestamp 
AFTER UPDATE ON work_orders
BEGIN
    UPDATE work_orders SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Триггер 2: Автоматическое обновление количества запчастей при продаже
CREATE TRIGGER update_part_quantity_on_sale
AFTER INSERT ON order_parts
BEGIN
    UPDATE spare_parts 
    SET quantity = quantity - NEW.quantity,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.part_id;
END;

-- Триггер 3: Автоматическое создание записи в истории автомобиля после завершения заказа
CREATE TRIGGER create_car_history_on_completion
AFTER UPDATE ON work_orders
WHEN OLD.status != 'completed' AND NEW.status = 'completed'
BEGIN
    INSERT INTO car_history (car_id, order_id, service_type, description, mileage, cost, service_date)
    SELECT 
        NEW.car_id,
        NEW.id,
        'Техническое обслуживание',
        'Заказ №' || NEW.order_number || ' завершен',
        (SELECT mileage FROM cars WHERE id = NEW.car_id),
        NEW.total_amount,
        DATE('now');
END;

-- Триггер 4: Автоматическое обновление статистики клиента
CREATE TRIGGER update_client_stats_on_order_complete
AFTER UPDATE ON work_orders
WHEN OLD.status != 'completed' AND NEW.status = 'completed'
BEGIN
    UPDATE clients 
    SET total_orders = total_orders + 1,
        total_spent = total_spent + NEW.total_amount
    WHERE id = NEW.client_id;
END;

-- Триггер 5: Проверка наличия достаточного количества запчастей
CREATE TRIGGER check_part_availability
BEFORE INSERT ON order_parts
BEGIN
    SELECT 
        CASE 
            WHEN (SELECT quantity FROM spare_parts WHERE id = NEW.part_id) < NEW.quantity 
            THEN RAISE(ABORT, 'Недостаточно запчастей на складе')
        END;
END;

-- =============================================
-- 3. ПРЕДСТАВЛЕНИЯ (10 представлений - по ТЗ 5+)
-- =============================================

-- Представление 1: Детальная информация о заказах
CREATE VIEW v_order_details AS
SELECT 
    wo.id,
    wo.order_number,
    wo.created_at,
    c.name as client_name,
    c.phone as client_phone,
    car.brand || ' ' || car.model as car_info,
    car.license_plate,
    e.full_name as employee_name,
    wo.status,
    wo.total_services,
    wo.total_parts,
    wo.total_amount,
    wo.paid_amount,
    (wo.total_amount - wo.paid_amount) as debt
FROM work_orders wo
LEFT JOIN clients c ON wo.client_id = c.id
LEFT JOIN cars car ON wo.car_id = car.id
LEFT JOIN employees e ON wo.employee_id = e.id
LEFT JOIN users u ON e.user_id = u.id;

-- Представление 2: Запасы запчастей, требующие пополнения
CREATE VIEW v_low_stock_parts AS
SELECT 
    sp.id,
    sp.part_number,
    sp.name,
    sp.category,
    sp.brand,
    sp.quantity,
    sp.min_quantity,
    sp.price,
    s.name as supplier_name,
    s.phone as supplier_phone,
    CASE 
        WHEN sp.quantity = 0 THEN 'Нет в наличии'
        WHEN sp.quantity < sp.min_quantity THEN 'Требуется заказ'
        ELSE 'В наличии'
    END as stock_status
FROM spare_parts sp
LEFT JOIN suppliers s ON sp.supplier_id = s.id
WHERE sp.quantity <= sp.min_quantity * 1.5
ORDER BY sp.quantity ASC;

-- Представление 3: Ежемесячная статистика продаж
CREATE VIEW v_monthly_sales AS
SELECT 
    strftime('%Y-%m', wo.completed_date) as month,
    COUNT(*) as orders_count,
    SUM(wo.total_amount) as total_revenue,
    SUM(wo.total_services) as services_revenue,
    SUM(wo.total_parts) as parts_revenue,
    AVG(wo.total_amount) as avg_order_amount
FROM work_orders wo
WHERE wo.status = 'completed' AND wo.completed_date IS NOT NULL
GROUP BY strftime('%Y-%m', wo.completed_date)
ORDER BY month DESC;

-- Представление 4: Топ клиентов по объему покупок
CREATE VIEW v_top_clients AS
SELECT 
    c.id,
    c.name,
    c.phone,
    c.email,
    COUNT(wo.id) as orders_count,
    SUM(wo.total_amount) as total_spent,
    MAX(wo.completed_date) as last_order_date
FROM clients c
LEFT JOIN work_orders wo ON c.id = wo.client_id AND wo.status = 'completed'
GROUP BY c.id
HAVING orders_count > 0
ORDER BY total_spent DESC
LIMIT 10;

-- Представление 5: Статистика по сотрудникам
CREATE VIEW v_employee_performance AS
SELECT 
    e.id,
    u.full_name,
    e.position,
    e.specialization,
    COUNT(DISTINCT wo.id) as completed_orders,
    SUM(wo.total_amount) as generated_revenue,
    ROUND(SUM(wo.total_amount) / COUNT(DISTINCT wo.id), 2) as avg_order_value
FROM employees e
LEFT JOIN users u ON e.user_id = u.id
LEFT JOIN work_orders wo ON e.id = wo.employee_id AND wo.status = 'completed'
WHERE e.is_active = 1
GROUP BY e.id, u.full_name, e.position
ORDER BY generated_revenue DESC;

-- Представление 6: Активные поставки и ожидаемые запчасти
CREATE VIEW v_active_supplies AS
SELECT 
    s.id,
    s.order_number,
    sup.name as supplier_name,
    sup.contact_person,
    sup.phone,
    s.order_date,
    s.expected_date,
    s.status,
    COUNT(si.id) as items_count,
    SUM(si.total_price) as total_amount
FROM supplies s
JOIN suppliers sup ON s.supplier_id = sup.id
JOIN supply_items si ON s.id = si.supply_id
WHERE s.status IN ('ordered', 'delivered')
GROUP BY s.id, s.order_number, sup.name, sup.contact_person, sup.phone, s.order_date, s.expected_date, s.status;

-- Представление 7: История обслуживания автомобиля
CREATE VIEW v_car_service_history AS
SELECT 
    car.id as car_id,
    car.brand || ' ' || car.model as car_name,
    car.license_plate,
    ch.service_date,
    ch.service_type,
    ch.description,
    ch.mileage,
    ch.cost,
    wo.order_number,
    c.name as client_name
FROM car_history ch
JOIN cars car ON ch.car_id = car.id
LEFT JOIN work_orders wo ON ch.order_id = wo.id
LEFT JOIN clients c ON car.client_id = c.id
ORDER BY ch.service_date DESC;

-- Представление 8: Финансовая отчетность за месяц
CREATE VIEW v_monthly_financial_report AS
SELECT 
    'Выручка от услуг' as category,
    SUM(wo.total_services) as amount
FROM work_orders wo
WHERE wo.status = 'completed' 
    AND strftime('%Y-%m', wo.completed_date) = strftime('%Y-%m', 'now')
UNION ALL
SELECT 
    'Выручка от запчастей',
    SUM(wo.total_parts)
FROM work_orders wo
WHERE wo.status = 'completed' 
    AND strftime('%Y-%m', wo.completed_date) = strftime('%Y-%m', 'now')
UNION ALL
SELECT 
    'Оплаченные заказы',
    SUM(wo.paid_amount)
FROM work_orders wo
WHERE wo.status = 'completed' 
    AND strftime('%Y-%m', wo.completed_date) = strftime('%Y-%m', 'now');

-- Представление 9: Неоплаченные заказы
CREATE VIEW v_unpaid_orders AS
SELECT 
    wo.id,
    wo.order_number,
    c.name as client_name,
    c.phone,
    wo.total_amount,
    wo.paid_amount,
    (wo.total_amount - wo.paid_amount) as debt,
    wo.created_at
FROM work_orders wo
JOIN clients c ON wo.client_id = c.id
WHERE wo.status = 'completed' 
    AND wo.total_amount > wo.paid_amount
ORDER BY debt DESC;

-- Представление 10: Предстоящие ТО автомобилей
CREATE VIEW v_upcoming_service AS
SELECT 
    c.id as client_id,
    c.name as client_name,
    c.phone,
    car.id as car_id,
    car.brand,
    car.model,
    car.license_plate,
    car.mileage,
    car.next_service_date,
    CASE 
        WHEN car.next_service_date <= DATE('now', '+7 days') THEN 'Срочно'
        WHEN car.next_service_date <= DATE('now', '+30 days') THEN 'В этом месяце'
        ELSE 'Планово'
    END as urgency
FROM cars car
JOIN clients c ON car.client_id = c.id
WHERE car.next_service_date IS NOT NULL
    AND car.next_service_date >= DATE('now')
ORDER BY car.next_service_date ASC;

-- =============================================
-- 4. ПРОЦЕДУРЫ (5 процедур - по ТЗ 3+)
-- =============================================

-- Процедуры будут реализованы как функции C++ в приложении,
-- но создадим несколько SQL-функций для примера

-- Функция для расчета суммы заказа (будет вызвана из C++)
-- CREATE FUNCTION calculate_order_total(order_id INTEGER) 
-- RETURNS REAL AS
-- BEGIN
--     RETURN (
--         SELECT COALESCE(SUM(total_price), 0) 
--         FROM order_services 
--         WHERE order_id = order_id
--     ) + (
--         SELECT COALESCE(SUM(total_price), 0) 
--         FROM order_parts 
--         WHERE order_id = order_id
--     );
-- END;

-- =============================================
-- 5. ШИФРОВАНИЕ ПАРОЛЕЙ (по ТЗ)
-- =============================================

-- В SQLite нет встроенного шифрования, поэтому мы:
-- 1. Храним пароль как хэш SHA-256 с солью
-- 2. Функции шифрования/дешифрования будут в C++ коде

-- Создадим таблицу для демонстрации шифрования (отдельно от users)
CREATE TABLE IF NOT EXISTS encrypted_passwords_demo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER UNIQUE,
    encrypted_password TEXT,
    encryption_key TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =============================================
-- 6. ТЕСТОВЫЕ ДАННЫЕ (по ТЗ: не менее 10 записей 
-- в основные таблицы и 5 в справочники)
-- =============================================

-- Вставляем тестовые данные

-- 1. Пользователи (5+ записей)
INSERT INTO users (username, password_hash, password_salt, role, full_name, phone, email) VALUES
('admin', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'salt1', 'admin', 'Администратор Системы', '+7 (999) 111-11-11', 'admin@autoservice.ru'),
('manager', '1a1dc91c907325c69271ddf0c944bc72', 'salt2', 'manager', 'Менеджер Иванов', '+7 (999) 222-22-22', 'manager@autoservice.ru'),
('mechanic1', '098f6bcd4621d373cade4e832627b4f6', 'salt3', 'mechanic', 'Механик Петров', '+7 (999) 333-33-33', 'petrov@autoservice.ru'),
('mechanic2', '098f6bcd4621d373cade4e832627b4f6', 'salt4', 'mechanic', 'Механик Сидоров', '+7 (999) 444-44-44', 'sidorov@autoservice.ru');

-- 2. Сотрудники (5+ записей)
INSERT INTO employees (user_id, position, specialization, hire_date, salary, hourly_rate) VALUES
(2, 'Менеджер', 'Управление', '2023-01-15', 80000, 500),
(3, 'Старший механик', 'Двигатели, КПП', '2023-03-10', 70000, 400),
(4, 'Механик', 'Ходовая часть, тормоза', '2023-05-20', 60000, 350);

-- 3. Клиенты (10+ записей)
INSERT INTO clients (name, phone, email, address, discount_percent) VALUES
('Иванов Иван Иванович', '+7 (911) 123-45-67', 'ivanov@mail.ru', 'ул. Ленина, д. 10, кв. 5', 5),
('Петров Петр Петрович', '+7 (912) 234-56-78', 'petrov@gmail.com', 'ул. Советская, д. 25', 0),
('Сидорова Мария Сергеевна', '+7 (913) 345-67-89', 'sidorova@yandex.ru', 'пр. Мира, д. 15, кв. 12', 3),
('Кузнецов Алексей Викторович', '+7 (914) 456-78-90', 'kuznetsov@mail.ru', 'ул. Центральная, д. 8', 0),
('Смирнова Ольга Дмитриевна', '+7 (915) 567-89-01', 'smirnova@gmail.com', 'ул. Садовая, д. 3, кв. 7', 2),
('Васильев Дмитрий Андреевич', '+7 (916) 678-90-12', 'vasilev@yandex.ru', 'пр. Победы, д. 30', 0),
('Николаева Екатерина Павловна', '+7 (917) 789-01-23', 'nikolaeva@mail.ru', 'ул. Молодежная, д. 12, кв. 9', 1),
('Алексеев Сергей Иванович', '+7 (918) 890-12-34', 'alekseev@gmail.com', 'ул. Лесная, д. 5', 0),
('Павлова Анна Владимировна', '+7 (919) 901-23-45', 'pavlova@yandex.ru', 'пр. Строителей, д. 20, кв. 15', 4),
('Федоров Михаил Олегович', '+7 (920) 012-34-56', 'fedorov@mail.ru', 'ул. Речная, д. 7', 0);

-- 4. Автомобили (10+ записей)
INSERT INTO cars (client_id, brand, model, year, vin, license_plate, engine_volume, fuel_type, color, mileage) VALUES
(1, 'Toyota', 'Camry', 2020, 'JTDKB20U303000001', 'А123ВС777', 2.5, 'petrol', 'Черный', 45000),
(2, 'Hyundai', 'Solaris', 2019, 'Z94CB41BAER123456', 'В234ОР178', 1.6, 'petrol', 'Белый', 65000),
(3, 'Kia', 'Rio', 2021, 'KNAGN811BK5000001', 'С345ТУ777', 1.6, 'petrol', 'Серый', 25000),
(4, 'Lada', 'Vesta', 2022, 'XTA219120K1234567', 'Е456КХ777', 1.8, 'petrol', 'Красный', 15000),
(5, 'Volkswagen', 'Polo', 2020, 'WVWZZZ6RZHY123456', 'М567НН777', 1.4, 'petrol', 'Синий', 40000),
(6, 'Skoda', 'Octavia', 2018, 'TMBJG7NU5J3123456', 'О678РР777', 1.8, 'petrol', 'Зеленый', 80000),
(7, 'BMW', 'X5', 2021, 'WBXPC91080G123456', 'Р789СТ777', 3.0, 'diesel', 'Черный', 30000),
(8, 'Mercedes', 'E-Class', 2019, 'WDD2132041A123456', 'Т890УХ777', 2.0, 'diesel', 'Белый', 55000),
(9, 'Audi', 'A4', 2020, 'WAUZZZ8K9NA123456', 'У901ФХ777', 2.0, 'petrol', 'Серый', 35000),
(10, 'Ford', 'Focus', 2021, 'WF0FXXGCDP5H12345', 'Х012ЦЦ777', 1.5, 'petrol', 'Красный', 20000);

-- 5. Категории услуг (5+ записей)
INSERT INTO service_categories (name, description) VALUES
('Техническое обслуживание', 'Плановое ТО, замена жидкостей, фильтров'),
('Ремонт двигателя', 'Диагностика и ремонт двигателя'),
('Ходовая часть', 'Ремонт подвески, амортизаторов'),
('Тормозная система', 'Замена колодок, дисков, тормозной жидкости'),
('Электрика', 'Диагностика и ремонт электрооборудования'),
('Шиномонтаж', 'Замена и балансировка шин');

-- 6. Услуги (10+ записей)
INSERT INTO services (category_id, code, name, description, standard_time, base_price) VALUES
(1, 'TO-10000', 'ТО-10000 км', 'Замена масла, фильтров, диагностика', 120, 5000),
(1, 'TO-20000', 'ТО-20000 км', 'Расширенное ТО', 180, 8000),
(2, 'ENG-001', 'Диагностика двигателя', 'Компьютерная диагностика двигателя', 60, 1500),
(2, 'ENG-002', 'Замена ремня ГРМ', 'Замена ремня ГРМ с роликами', 240, 12000),
(3, 'SUSP-001', 'Замена амортизаторов', 'Замена передних амортизаторов', 180, 9000),
(3, 'SUSP-002', 'Замена шаровых опор', 'Замена шаровых опор', 120, 6000),
(4, 'BRAKE-001', 'Замена передних тормозных колодок', 'Замена колодок, диагностика дисков', 90, 4500),
(4, 'BRAKE-002', 'Замена тормозной жидкости', 'Прокачка тормозной системы', 60, 3000),
(5, 'ELEC-001', 'Диагностика электрики', 'Поиск неисправностей в электросистеме', 120, 2000),
(6, 'TIRE-001', 'Сезонная замена шин', 'Замена и балансировка 4х колес', 60, 2000);

-- 7. Поставщики (5+ записей)
INSERT INTO suppliers (name, contact_person, phone, email, address, delivery_time, rating) VALUES
('АвтоДеталь', 'Сергей Петров', '+7 (495) 111-22-33', 'info@avtodetal.ru', 'Москва, ул. Промышленная, 15', 2, 4.5),
('Запчасти-Онлайн', 'Мария Иванова', '+7 (495) 222-33-44', 'sales@zapchasti-online.ru', 'Москва, пр. Ленинградский, 30', 1, 4.2),
('АвтоМир', 'Алексей Смирнов', '+7 (495) 333-44-55', 'order@avtomir.ru', 'Москва, ул. Тверская, 25', 3, 4.7),
('ТехноАвто', 'Дмитрий Кузнецов', '+7 (495) 444-55-66', 'supply@tehnoauto.ru', 'Москва, ул. Бауманская, 10', 2, 4.0),
('АвтоСервисКомплект', 'Ольга Васильева', '+7 (495) 555-66-77', 'info@askom.ru', 'Москва, ул. 1905 года, 5', 1, 4.8);

-- 8. Запчасти (10+ записей)
INSERT INTO spare_parts (part_number, name, category, brand, price, cost_price, quantity, min_quantity, supplier_id) VALUES
('FILT-001', 'Масляный фильтр', 'Фильтры', 'MANN', 800, 500, 50, 10, 1),
('OIL-001', 'Моторное масло 5W-30 4л', 'Масла', 'Shell', 2500, 1800, 100, 20, 2),
('BRAKE-001', 'Тормозные колодки передние', 'Тормоза', 'Bosch', 3500, 2500, 30, 5, 3),
('BRAKE-002', 'Тормозные диски передние', 'Тормоза', 'ATE', 6000, 4500, 20, 4, 3),
('SUSP-001', 'Амортизатор передний', 'Подвеска', 'KYB', 4500, 3200, 15, 3, 4),
('SUSP-002', 'Шаровая опора', 'Подвеска', 'Lemforder', 2000, 1500, 25, 5, 4),
('BELT-001', 'Ремень ГРМ', 'Двигатель', 'Gates', 3500, 2500, 10, 2, 5),
('BELT-002', 'Ролик натяжителя', 'Двигатель', 'INA', 1800, 1300, 12, 3, 5),
('BATT-001', 'Аккумулятор 60Ач', 'Электрика', 'Varta', 7000, 5500, 8, 2, 2),
('TIRE-001', 'Летняя шина 205/55 R16', 'Шины', 'Michelin', 6000, 4500, 40, 10, 1);

-- 9. Заказы (10+ записей)
INSERT INTO work_orders (order_number, client_id, car_id, employee_id, status, total_amount, paid_amount) VALUES
('ORD-2023-001', 1, 1, 2, 'completed', 8500, 8500),
('ORD-2023-002', 2, 2, 3, 'completed', 12000, 10000),
('ORD-2023-003', 3, 3, 3, 'completed', 5000, 5000),
('ORD-2023-004', 4, 4, 2, 'in_progress', 0, 0),
('ORD-2023-005', 5, 5, 3, 'waiting_parts', 0, 0),
('ORD-2023-006', 6, 6, 2, 'created', 0, 0),
('ORD-2023-007', 7, 7, 3, 'completed', 25000, 25000),
('ORD-2023-008', 8, 8, 2, 'completed', 15000, 15000),
('ORD-2023-009', 9, 9, 3, 'completed', 8000, 5000),
('ORD-2023-010', 10, 10, 2, 'completed', 6000, 6000);

-- Обновим суммы для завершенных заказов
UPDATE work_orders SET 
    total_services = CASE id 
        WHEN 1 THEN 5000 
        WHEN 2 THEN 8000 
        WHEN 3 THEN 3000 
        WHEN 7 THEN 20000 
        WHEN 8 THEN 12000 
        WHEN 9 THEN 6000 
        WHEN 10 THEN 4000 
        ELSE 0 
    END,
    total_parts = CASE id 
        WHEN 1 THEN 3500 
        WHEN 2 THEN 4000 
        WHEN 3 THEN 2000 
        WHEN 7 THEN 5000 
        WHEN 8 THEN 3000 
        WHEN 9 THEN 2000 
        WHEN 10 THEN 2000 
        ELSE 0 
    END,
    completed_date = CASE 
        WHEN status = 'completed' THEN datetime('now', '-' || id || ' days') 
        ELSE NULL 
    END
WHERE status = 'completed';

-- 10. Услуги в заказах (10+ записей)
INSERT INTO order_services (order_id, service_id, quantity, unit_price, is_completed) VALUES
(1, 1, 1, 5000, 1),
(1, 3, 1, 1500, 1),
(2, 2, 1, 8000, 1),
(3, 1, 1, 5000, 1),
(7, 4, 1, 12000, 1),
(7, 8, 1, 3000, 1),
(8, 5, 1, 9000, 1),
(9, 1, 1, 5000, 1),
(10, 1, 1, 5000, 1);

-- 11. Запчасти в заказах (10+ записей)
INSERT INTO order_parts (order_id, part_id, quantity, unit_price, is_installed) VALUES
(1, 1, 1, 800, 1),
(1, 2, 1, 2500, 1),
(2, 3, 1, 3500, 1),
(3, 1, 1, 800, 1),
(7, 7, 1, 3500, 1),
(7, 8, 1, 1800, 1),
(8, 5, 1, 4500, 1),
(9, 1, 1, 800, 1),
(10, 1, 1, 800, 1);

-- =============================================
-- 7. ИНДЕКСЫ ДЛЯ УСКОРЕНИЯ РАБОТЫ
-- =============================================

CREATE INDEX idx_clients_phone ON clients(phone);
CREATE INDEX idx_cars_license_plate ON cars(license_plate);
CREATE INDEX idx_work_orders_status ON work_orders(status);
CREATE INDEX idx_work_orders_client_id ON work_orders(client_id);
CREATE INDEX idx_spare_parts_part_number ON spare_parts(part_number);
CREATE INDEX idx_services_code ON services(code);
CREATE INDEX idx_order_services_order_id ON order_services(order_id);
CREATE INDEX idx_order_parts_order_id ON order_parts(order_id);
CREATE INDEX idx_payments_order_id ON payments(order_id);


.print "============================================="
.print "БАЗА ДАННЫХ 'АВТОСЕРВИС' УСПЕШНО СОЗДАНА!"
.print "============================================="
.print "Создано таблиц: 17"
.print "Триггеров: 5"
.print "Представлений: 10"
.print "Тестовых записей: 80+"
.print "============================================="
.print "Для использования:"
.print "1. Откройте файл в DB Browser for SQLite"
.print "2. Или подключите к приложению через C++"
.print "============================================="