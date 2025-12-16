#include "Client.h"
#include <sstream>

Client::Client() : id(0) {}

Client::Client(int id, const std::string& name, const std::string& phone,
               const std::string& carModel, const std::string& licensePlate)
        : id(id), name(name), phone(phone), carModel(carModel), licensePlate(licensePlate) {}

int Client::getId() const {
    return id;
}

std::string Client::getName() const {
    return name;
}

std::string Client::getPhone() const {
    return phone;
}

std::string Client::getCarModel() const {
    return carModel;
}

std::string Client::getLicensePlate() const {
    return licensePlate;
}

void Client::setName(const std::string& name) {
    this->name = name;
}

void Client::setPhone(const std::string& phone) {
    this->phone = phone;
}

void Client::setCarModel(const std::string& carModel) {
    this->carModel = carModel;
}

void Client::setLicensePlate(const std::string& licensePlate) {
    this->licensePlate = licensePlate;
}

std::string Client::toString() const {
    std::ostringstream oss;
    oss << "ID: " << id
        << ", Имя: " << name
        << ", Телефон: " << phone
        << ", Авто: " << carModel
        << ", Номер: " << licensePlate;
    return oss.str();
}