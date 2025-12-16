#ifndef AUTOSERVICE_DATABASEMANAGER_H
#define AUTOSERVICE_DATABASEMANAGER_H

#include <string>
#include <vector>
#include <functional>

// Структуры данных
struct Client {
    int id;
    std::string name;
    std::string phone;
    std::string email;
};

struct Service {
    int id;
    std::string name;
    std::string description;
    double price;
};

struct Order {
    int id;
    int clientId;
    std::string date;
    std::string status;
    double total;
};

class DatabaseManager {
private:
    void* db; // Указатель на SQLite базу данных
    static DatabaseManager* instance;
    DatabaseManager() : db(nullptr) {}

    bool executeQueryInternal(const std::string& sql);
    std::vector<std::vector<std::string>> executeSelect(const std::string& sql);

public:
    static DatabaseManager& getInstance() {
        static DatabaseManager instance;
        return instance;
    }

    DatabaseManager(const DatabaseManager&) = delete;
    DatabaseManager& operator=(const DatabaseManager&) = delete;

    // Основные методы
    bool open(const std::string& dbPath);
    void close();
    bool isOpen() const { return db != nullptr; }

    // Авторизация
    bool registerUser(const std::string& username,
                      const std::string& password,
                      const std::string& fullName,
                      const std::string& role = "mechanic");

    int authenticateUser(const std::string& username,
                         const std::string& password);

    // Клиенты
    bool addClient(const std::string& name,
                   const std::string& phone,
                   const std::string& email = "");

    std::vector<Client> getAllClients();
    bool updateClient(int id, const std::string& name,
                      const std::string& phone, const std::string& email);
    bool deleteClient(int id);

    // Услуги
    bool addService(const std::string& name,
                    const std::string& description,
                    double price);

    std::vector<Service> getAllServices();

    // Заказы
    bool createOrder(int clientId, const std::string& date);
    bool addServiceToOrder(int orderId, int serviceId, int quantity = 1);
    std::vector<Order> getAllOrders();

    // Представления
    std::vector<std::vector<std::string>> getOrderDetails();
    std::vector<std::vector<std::string>> getLowStockParts();
    std::vector<std::vector<std::string>> getTopClients();

    // Хранимые процедуры (реализация на C++)
    double calculateOrderTotal(int orderId);
    std::string generateMonthlyReport();

    // Резервное копирование
    bool backupDatabase(const std::string& backupPath);

    // Вспомогательные методы
    int getLastInsertId();
    bool tableExists(const std::string& tableName);
};

#endif // AUTOSERVICE_DATABASEMANAGER_H