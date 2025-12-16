#ifndef ORDER_H
#define ORDER_H

#include <string>
#include <vector>

class Order {
private:
    int id;
    int clientId;
    std::string date;
    std::vector<int> serviceIds;

public:
    // Конструкторы
    Order();
    Order(int id, int clientId, const std::string& date);

    // Геттеры
    int getId() const;
    int getClientId() const;
    std::string getDate() const;
    std::vector<int> getServiceIds() const;

    // Сеттеры
    void setClientId(int clientId);
    void setDate(const std::string& date);

    // Добавление услуги
    void addService(int serviceId);
    void removeService(int serviceId);

    // Метод для отображения
    std::string toString() const;
};

#endif // ORDER_H