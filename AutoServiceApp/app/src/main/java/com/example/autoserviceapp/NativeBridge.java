package com.example.autoserviceapp;

public class NativeBridge {
    static {
        System.loadLibrary("native-lib");
    }

    // Инициализация базы данных
    public static native boolean initDatabase(String dbPath);
    public static native void closeDatabase();

    // Авторизация
    public static native boolean registerUser(String username, String password,
                                              String fullName, String role);
    public static native int authenticateUser(String username, String password);

    // Клиенты
    public static native boolean addClient(String name, String phone, String email);
    public static native String[] getAllClients();
    public static native boolean updateClient(int id, String name, String phone, String email);
    public static native boolean deleteClient(int id);

    // Услуги
    public static native boolean addService(String name, String description, double price);
    public static native String[] getAllServices();

    // Заказы
    public static native int createOrder(int clientId, String orderDate);
    public static native boolean addServiceToOrder(int orderId, int serviceId, int quantity);
    public static native String[] getAllOrders();

    // Представления (Views)
    public static native String[] getOrderDetailsView();
    public static native String[] getLowStockParts();
    public static native String[] getTopClients();

    // Хранимые процедуры
    public static native double calculateOrderTotal(int orderId);
    public static native String generateMonthlyReport();

    // Резервное копирование
    public static native boolean backupDatabase(String backupPath);
    public static native boolean restoreDatabase(String backupPath);

    // Статистика
    public static native String getStatistics();

    // Вспомогательные методы (старые, для совместимости)
    public static native void init();
    public static native String getClientInfo(int clientId);
    public static native int getClientsCount();
    public static native int getServicesCount();
    public static native String getOrderInfo(int orderId);
    public static native int getOrdersCount();
    public static native void resetAllData();
}