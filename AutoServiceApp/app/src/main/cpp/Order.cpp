#include "Order.h"
#include <sstream>
#include <algorithm>

Order::Order() : id(0), clientId(0) {}

Order::Order(int id, int clientId, const std::string& date)
        : id(id), clientId(clientId), date(date) {}

int Order::getId() const {
    return id;
}

int Order::getClientId() const {
    return clientId;
}

std::string Order::getDate() const {
    return date;
}

std::vector<int> Order::getServiceIds() const {
    return serviceIds;
}

void Order::setClientId(int clientId) {
    this->clientId = clientId;
}

void Order::setDate(const std::string& date) {
    this->date = date;
}

void Order::addService(int serviceId) {
    serviceIds.push_back(serviceId);
}

void Order::removeService(int serviceId) {
    serviceIds.erase(std::remove(serviceIds.begin(), serviceIds.end(), serviceId), serviceIds.end());
}

std::string Order::toString() const {
    std::ostringstream oss;
    oss << "ID заказа: " << id
        << ", ID клиента: " << clientId
        << ", Дата: " << date
        << ", Количество услуг: " << serviceIds.size();
    return oss.str();
}