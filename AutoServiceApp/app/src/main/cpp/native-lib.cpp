#include <jni.h>
#include <string>
#include <vector>
#include <sstream>
#include "DatabaseManager.h"

static DatabaseManager& db = DatabaseManager::getInstance();

std::string jstringToString(JNIEnv* env, jstring jstr) {
    if (!jstr) return "";
    const char* chars = env->GetStringUTFChars(jstr, nullptr);
    std::string result(chars);
    env->ReleaseStringUTFChars(jstr, chars);
    return result;
}

jstring stringToJString(JNIEnv* env, const std::string& str) {
    return env->NewStringUTF(str.c_str());
}

extern "C" {

// Инициализация базы данных
JNIEXPORT jboolean JNICALL
Java_com_example_autoserviceapp_NativeBridge_initDatabase(
        JNIEnv* env,
        jclass clazz,
        jstring dbPath) {

    std::string path = jstringToString(env, dbPath);
    return db.open(path) ? JNI_TRUE : JNI_FALSE;
}

// Регистрация пользователя
JNIEXPORT jboolean JNICALL
Java_com_example_autoserviceapp_NativeBridge_registerUser(
        JNIEnv* env,
        jclass clazz,
        jstring username,
        jstring password,
        jstring fullName,
        jstring role) {

    std::string user = jstringToString(env, username);
    std::string pass = jstringToString(env, password);
    std::string name = jstringToString(env, fullName);
    std::string userRole = jstringToString(env, role);

    return db.registerUser(user, pass, name, userRole) ? JNI_TRUE : JNI_FALSE;
}

// Аутентификация
JNIEXPORT jint JNICALL
Java_com_example_autoserviceapp_NativeBridge_authenticateUser(
        JNIEnv* env,
        jclass clazz,
        jstring username,
        jstring password) {

    std::string user = jstringToString(env, username);
    std::string pass = jstringToString(env, password);

    return db.authenticateUser(user, pass);
}

// Добавление клиента
JNIEXPORT jboolean JNICALL
Java_com_example_autoserviceapp_NativeBridge_addClient(
        JNIEnv* env,
        jclass clazz,
        jstring name,
        jstring phone,
        jstring email) {

    std::string clientName = jstringToString(env, name);
    std::string clientPhone = jstringToString(env, phone);
    std::string clientEmail = jstringToString(env, email);

    return db.addClient(clientName, clientPhone, clientEmail) ? JNI_TRUE : JNI_FALSE;
}

// Получение всех клиентов
JNIEXPORT jobjectArray JNICALL
Java_com_example_autoserviceapp_NativeBridge_getAllClients(
        JNIEnv* env,
        jclass clazz) {

    std::vector<Client> clients = db.getAllClients();
    jclass stringClass = env->FindClass("java/lang/String");
    jobjectArray result = env->NewObjectArray(clients.size(), stringClass, nullptr);

    for (size_t i = 0; i < clients.size(); i++) {
        std::stringstream ss;
        ss << "ID: " << clients[i].id
           << ", Имя: " << clients[i].name
           << ", Телефон: " << clients[i].phone
           << ", Email: " << clients[i].email;

        env->SetObjectArrayElement(result, i, stringToJString(env, ss.str()));
    }

    return result;
}

// Добавление услуги
JNIEXPORT jboolean JNICALL
Java_com_example_autoserviceapp_NativeBridge_addService(
        JNIEnv* env,
        jclass clazz,
        jstring name,
        jstring description,
        jdouble price) {

    std::string serviceName = jstringToString(env, name);
    std::string serviceDesc = jstringToString(env, description);
    double servicePrice = static_cast<double>(price);

    return db.addService(serviceName, serviceDesc, servicePrice) ? JNI_TRUE : JNI_FALSE;
}

// Получение всех услуг
JNIEXPORT jobjectArray JNICALL
Java_com_example_autoserviceapp_NativeBridge_getAllServices(
        JNIEnv* env,
        jclass clazz) {

    std::vector<Service> services = db.getAllServices();
    jclass stringClass = env->FindClass("java/lang/String");
    jobjectArray result = env->NewObjectArray(services.size(), stringClass, nullptr);

    for (size_t i = 0; i < services.size(); i++) {
        std::stringstream ss;
        ss << "ID: " << services[i].id
           << ", Услуга: " << services[i].name
           << ", Цена: " << services[i].price
           << ", Описание: " << services[i].description;

        env->SetObjectArrayElement(result, i, stringToJString(env, ss.str()));
    }

    return result;
}

// Создание заказа
JNIEXPORT jint JNICALL
Java_com_example_autoserviceapp_NativeBridge_createOrder(
        JNIEnv* env,
        jclass clazz,
        jint clientId,
        jstring orderDate) {

    std::string date = jstringToString(env, orderDate);

    if (db.createOrder(clientId, date)) {
        return db.getLastInsertId();
    }

    return -1;
}

// Получение всех заказов
JNIEXPORT jobjectArray JNICALL
Java_com_example_autoserviceapp_NativeBridge_getAllOrders(
        JNIEnv* env,
        jclass clazz) {

    std::vector<Order> orders = db.getAllOrders();
    jclass stringClass = env->FindClass("java/lang/String");
    jobjectArray result = env->NewObjectArray(orders.size(), stringClass, nullptr);

    for (size_t i = 0; i < orders.size(); i++) {
        std::stringstream ss;
        ss << "ID: " << orders[i].id
           << ", Клиент: " << orders[i].clientId
           << ", Дата: " << orders[i].date
           << ", Статус: " << orders[i].status
           << ", Сумма: " << orders[i].total;

        env->SetObjectArrayElement(result, i, stringToJString(env, ss.str()));
    }

    return result;
}

// Получение деталей заказа (представление)
JNIEXPORT jobjectArray JNICALL
Java_com_example_autoserviceapp_NativeBridge_getOrderDetailsView(
        JNIEnv* env,
        jclass clazz) {

    auto viewData = db.getOrderDetails();
    jclass stringClass = env->FindClass("java/lang/String");
    jobjectArray result = env->NewObjectArray(viewData.size(), stringClass, nullptr);

    for (size_t i = 0; i < viewData.size(); i++) {
        std::stringstream ss;
        for (size_t j = 0; j < viewData[i].size(); j++) {
            if (j > 0) ss << " | ";
            ss << viewData[i][j];
        }

        env->SetObjectArrayElement(result, i, stringToJString(env, ss.str()));
    }

    return result;
}

// Расчет суммы заказа (хранимая процедура)
JNIEXPORT jdouble JNICALL
Java_com_example_autoserviceapp_NativeBridge_calculateOrderTotal(
        JNIEnv* env,
        jclass clazz,
        jint orderId) {

    return static_cast<jdouble>(db.calculateOrderTotal(orderId));
}

// Резервное копирование
JNIEXPORT jboolean JNICALL
Java_com_example_autoserviceapp_NativeBridge_backupDatabase(
        JNIEnv* env,
        jclass clazz,
        jstring backupPath) {

    std::string path = jstringToString(env, backupPath);
    return db.backupDatabase(path) ? JNI_TRUE : JNI_FALSE;
}

// Статистика
JNIEXPORT jstring JNICALL
Java_com_example_autoserviceapp_NativeBridge_getStatistics(
        JNIEnv* env,
        jclass clazz) {

    auto clients = db.getAllClients();
    auto services = db.getAllServices();
    auto orders = db.getAllOrders();

    std::stringstream ss;
    ss << "=== Статистика ===\n";
    ss << "Клиентов: " << clients.size() << "\n";
    ss << "Услуг: " << services.size() << "\n";
    ss << "Заказов: " << orders.size() << "\n";
    ss << "База данных: " << (db.isOpen() ? "открыта" : "закрыта");

    return stringToJString(env, ss.str());
}

} // extern "C"