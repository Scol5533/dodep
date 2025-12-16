#ifndef SERVICE_H
#define SERVICE_H

#include <string>

class Service {
private:
    int id;
    std::string name;
    std::string description;
    double price;
    int duration; // в минутах

public:
    // Конструкторы
    Service();
    Service(int id, const std::string& name, const std::string& description,
            double price, int duration);

    // Геттеры
    int getId() const;
    std::string getName() const;
    std::string getDescription() const;
    double getPrice() const;
    int getDuration() const;

    // Сеттеры
    void setName(const std::string& name);
    void setDescription(const std::string& description);
    void setPrice(double price);
    void setDuration(int duration);

    // Метод для отображения
    std::string toString() const;
};

#endif // SERVICE_H