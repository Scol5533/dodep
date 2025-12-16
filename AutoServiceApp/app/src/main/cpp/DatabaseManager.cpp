#include "DatabaseManager.h"
#include <iostream>
#include <sstream>
#include <iomanip>  // ДОБАВЛЕНО для std::setw и std::setfill
#include <random>
#include <cstring>

// Внешние функции SQLite (Android NDK)
extern "C" {
struct sqlite3;
struct sqlite3_stmt;

int sqlite3_open(const char* filename, sqlite3** ppDb);
int sqlite3_close(sqlite3*);
int sqlite3_exec(sqlite3*, const char* sql, int (*callback)(void*,int,char**,char**), void*, char** errmsg);
int sqlite3_prepare_v2(sqlite3* db, const char* zSql, int nByte, sqlite3_stmt** ppStmt, const char** pzTail);
int sqlite3_step(sqlite3_stmt*);
int sqlite3_finalize(sqlite3_stmt*);
const char* sqlite3_column_text(sqlite3_stmt*, int iCol);
int sqlite3_column_int(sqlite3_stmt*, int iCol);
double sqlite3_column_double(sqlite3_stmt*, int iCol);
int sqlite3_column_count(sqlite3_stmt*);
long long sqlite3_last_insert_rowid(sqlite3*);
const char* sqlite3_errmsg(sqlite3*);
}

DatabaseManager* DatabaseManager::instance = nullptr;

// Генерация соли для пароля
std::string generateSalt() {
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> dis(0, 255);

    std::stringstream ss;
    for (int i = 0; i < 16; ++i) {
        ss << std::hex << std::setw(2) << std::setfill('0') << dis(gen);
    }
    return ss.str();
}

// Простое шифрование пароля (для демонстрации)
std::string encryptPassword(const std::string& password, const std::string& salt) {
    std::string combined = password + salt;
    std::stringstream ss;
    for (char c : combined) {
        ss << std::hex << std::setw(2) << std::setfill('0')
           << static_cast<int>(c ^ 0x55);
    }
    return ss.str();
}

bool DatabaseManager::open(const std::string& dbPath) {
    if (db) close();

    // Приводим путь к правильному формату для Android
    std::string androidPath = dbPath;
    if (androidPath.find("file://") == std::string::npos) {
        androidPath = "file://" + androidPath;
    }

    // В реальном проекте нужно использовать Android SQLite API
    // Это упрощенная реализация для демонстрации
    std::cout << "Opening database: " << androidPath << std::endl;

    // Здесь должна быть реальная инициализация SQLite
    // Для тестирования помечаем базу как "открытую"
    db = (void*)1; // Заглушка

    return true;
}

void DatabaseManager::close() {
    if (db) {
        db = nullptr;
    }
}

bool DatabaseManager::executeQueryInternal(const std::string& sql) {
    if (!db) return false;

    // В реальном проекте здесь выполнение SQL
    // Для демонстрации просто логируем запрос
    std::cout << "Executing SQL: " << sql << std::endl;
    return true;
}

std::vector<std::vector<std::string>> DatabaseManager::executeSelect(const std::string& sql) {
    std::vector<std::vector<std::string>> results;

    if (!db) return results;

    // Демонстрационная реализация
    // В реальном проекте здесь выполнение SELECT запроса
    std::cout << "Executing SELECT: " << sql << std::endl;

    // Заглушка с тестовыми данными
    if (sql.find("clients") != std::string::npos) {
        results.push_back({"1", "Иван Иванов", "+79111234567", "ivan@mail.ru"});
        results.push_back({"2", "Петр Петров", "+79122345678", "petr@gmail.com"});
    } else if (sql.find("services") != std::string::npos) {
        results.push_back({"1", "Замена масла", "Полная замена масла и фильтра", "5000"});
        results.push_back({"2", "Диагностика", "Компьютерная диагностика", "2000"});
    }

    return results;
}

// Реализация методов

bool DatabaseManager::registerUser(const std::string& username,
                                   const std::string& password,
                                   const std::string& fullName,
                                   const std::string& role) {
    std::string salt = generateSalt();
    std::string passwordHash = encryptPassword(password, salt);

    std::stringstream sql;
    sql << "INSERT INTO users (username, password_hash, password_salt, role, full_name) "
        << "VALUES ('" << username << "', '" << passwordHash << "', '"
        << salt << "', '" << role << "', '" << fullName << "');";

    return executeQueryInternal(sql.str());
}

int DatabaseManager::authenticateUser(const std::string& username,
                                      const std::string& password) {
    // Упрощенная проверка
    if (username == "admin" && password == "admin") return 1;
    if (username == "user" && password == "user") return 2;
    return -1;
}

bool DatabaseManager::addClient(const std::string& name,
                                const std::string& phone,
                                const std::string& email) {
    std::stringstream sql;
    sql << "INSERT INTO clients (name, phone, email, registration_date) "
        << "VALUES ('" << name << "', '" << phone << "', '"
        << email << "', datetime('now'));";

    return executeQueryInternal(sql.str());
}

std::vector<Client> DatabaseManager::getAllClients() {
    std::vector<Client> clients;

    auto rows = executeSelect("SELECT id, name, phone, email FROM clients ORDER BY name;");

    for (const auto& row : rows) {
        if (row.size() >= 4) {
            Client client;
            client.id = std::stoi(row[0]);
            client.name = row[1];
            client.phone = row[2];
            client.email = row[3];
            clients.push_back(client);
        }
    }

    return clients;
}

bool DatabaseManager::updateClient(int id, const std::string& name,
                                   const std::string& phone, const std::string& email) {
    std::stringstream sql;
    sql << "UPDATE clients SET name = '" << name << "', phone = '" << phone
        << "', email = '" << email << "' WHERE id = " << id << ";";

    return executeQueryInternal(sql.str());
}

bool DatabaseManager::deleteClient(int id) {
    std::stringstream sql;
    sql << "DELETE FROM clients WHERE id = " << id << ";";

    return executeQueryInternal(sql.str());
}

bool DatabaseManager::addService(const std::string& name,
                                 const std::string& description,
                                 double price) {
    std::stringstream sql;
    sql << "INSERT INTO services (name, description, base_price) "
        << "VALUES ('" << name << "', '" << description << "', " << price << ");";

    return executeQueryInternal(sql.str());
}

std::vector<Service> DatabaseManager::getAllServices() {
    std::vector<Service> services;

    auto rows = executeSelect("SELECT id, name, description, base_price FROM services;");

    for (const auto& row : rows) {
        if (row.size() >= 4) {
            Service service;
            service.id = std::stoi(row[0]);
            service.name = row[1];
            service.description = row[2];
            service.price = std::stod(row[3]);
            services.push_back(service);
        }
    }

    return services;
}

bool DatabaseManager::createOrder(int clientId, const std::string& date) {
    std::stringstream sql;
    sql << "INSERT INTO work_orders (client_id, created_at) "
        << "VALUES (" << clientId << ", '" << date << "');";

    return executeQueryInternal(sql.str());
}

bool DatabaseManager::addServiceToOrder(int orderId, int serviceId, int quantity) {
    std::stringstream sql;
    sql << "INSERT INTO order_services (order_id, service_id, quantity, unit_price) "
        << "SELECT " << orderId << ", " << serviceId << ", " << quantity << ", "
        << "base_price FROM services WHERE id = " << serviceId << ";";

    return executeQueryInternal(sql.str());
}

std::vector<Order> DatabaseManager::getAllOrders() {
    std::vector<Order> orders;

    auto rows = executeSelect("SELECT id, client_id, created_at, status, total_amount FROM work_orders;");

    for (const auto& row : rows) {
        if (row.size() >= 5) {
            Order order;
            order.id = std::stoi(row[0]);
            order.clientId = std::stoi(row[1]);
            order.date = row[2];
            order.status = row[3];
            order.total = std::stod(row[4]);
            orders.push_back(order);
        }
    }

    return orders;
}

std::vector<std::vector<std::string>> DatabaseManager::getOrderDetails() {
    return executeSelect("SELECT * FROM v_order_details LIMIT 10;");
}

std::vector<std::vector<std::string>> DatabaseManager::getLowStockParts() {
    return executeSelect("SELECT * FROM v_low_stock_parts LIMIT 10;");
}

std::vector<std::vector<std::string>> DatabaseManager::getTopClients() {
    return executeSelect("SELECT * FROM v_top_clients LIMIT 10;");
}

double DatabaseManager::calculateOrderTotal(int orderId) {
    // Упрощенный расчет
    return 1000.0 * orderId;
}

std::string DatabaseManager::generateMonthlyReport() {
    return "Отчет за месяц: Упрощенная реализация";
}

bool DatabaseManager::backupDatabase(const std::string& backupPath) {
    std::cout << "Backup database to: " << backupPath << std::endl;
    return true;
}

int DatabaseManager::getLastInsertId() {
    return 1; // Заглушка
}

bool DatabaseManager::tableExists(const std::string& tableName) {
    return true; // Заглушка
}