#ifndef CLIENT_H
#define CLIENT_H

#include <string>

class Client {
private:
    int id;
    std::string name;
    std::string phone;
    std::string carModel;
    std::string licensePlate;

public:
    // Конструкторы
    Client();
    Client(int id, const std::string& name, const std::string& phone,
           const std::string& carModel, const std::string& licensePlate);

    // Геттеры
    int getId() const;
    std::string getName() const;
    std::string getPhone() const;
    std::string getCarModel() const;
    std::string getLicensePlate() const;

    // Сеттеры
    void setName(const std::string& name);
    void setPhone(const std::string& phone);
    void setCarModel(const std::string& carModel);
    void setLicensePlate(const std::string& licensePlate);

    // Метод для отображения
    std::string toString() const;
};

#endif // CLIENT_H