#include "Service.h"
#include <sstream>

Service::Service() : id(0), price(0.0), duration(0) {}

Service::Service(int id, const std::string& name, const std::string& description,
                 double price, int duration)
        : id(id), name(name), description(description), price(price), duration(duration) {}

int Service::getId() const {
    return id;
}

std::string Service::getName() const {
    return name;
}

std::string Service::getDescription() const {
    return description;
}

double Service::getPrice() const {
    return price;
}

int Service::getDuration() const {
    return duration;
}

void Service::setName(const std::string& name) {
    this->name = name;
}

void Service::setDescription(const std::string& description) {
    this->description = description;
}

void Service::setPrice(double price) {
    this->price = price;
}

void Service::setDuration(int duration) {
    this->duration = duration;
}

std::string Service::toString() const {
    std::ostringstream oss;
    oss << "ID: " << id
        << ", Услуга: " << name
        << ", Описание: " << description
        << ", Цена: $" << price
        << ", Длительность: " << duration << " мин";
    return oss.str();
}