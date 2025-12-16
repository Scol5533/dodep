package com.example.autoserviceapp;

import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;

public class MainActivity extends AppCompatActivity {

    private TextView tvStatus;
    private EditText etUsername, etPassword, etClientName, etClientPhone;
    private EditText etServiceName, etServicePrice, etOrderClientId;
    private Button btnLogin, btnRegister, btnAddClient, btnShowClients;
    private Button btnAddService, btnShowServices, btnCreateOrder, btnShowOrders;
    private Button btnGetStatistics, btnBackup, btnExit;

    private String dbPath;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        initViews();
        copyDatabase();
        initDatabase();
        setupListeners();
    }

    private void initViews() {
        tvStatus = findViewById(R.id.tvStatus);

        // Авторизация
        etUsername = findViewById(R.id.etUsername);
        etPassword = findViewById(R.id.etPassword);
        btnLogin = findViewById(R.id.btnLogin);
        btnRegister = findViewById(R.id.btnRegister);

        // Клиенты
        etClientName = findViewById(R.id.etClientName);
        etClientPhone = findViewById(R.id.etClientPhone);
        btnAddClient = findViewById(R.id.btnAddClient);
        btnShowClients = findViewById(R.id.btnShowClients);

        // Услуги
        etServiceName = findViewById(R.id.etServiceName);
        etServicePrice = findViewById(R.id.etServicePrice);
        btnAddService = findViewById(R.id.btnAddService);
        btnShowServices = findViewById(R.id.btnShowServices);

        // Заказы
        etOrderClientId = findViewById(R.id.etOrderClientId);
        btnCreateOrder = findViewById(R.id.btnCreateOrder);
        btnShowOrders = findViewById(R.id.btnShowOrders);

        // Статистика и управление
        btnGetStatistics = findViewById(R.id.btnGetStatistics);
        btnBackup = findViewById(R.id.btnBackup);
        btnExit = findViewById(R.id.btnExit);
    }

    private void copyDatabase() {
        try {
            // Путь к базе данных во внутреннем хранилище
            File dbFile = getDatabasePath("autoservice.db");
            dbPath = dbFile.getAbsolutePath();

            // Если базы нет, копируем из assets
            if (!dbFile.exists()) {
                dbFile.getParentFile().mkdirs();

                InputStream is = getAssets().open("autoservice.db");
                OutputStream os = new FileOutputStream(dbFile);

                byte[] buffer = new byte[1024];
                int length;
                while ((length = is.read(buffer)) > 0) {
                    os.write(buffer, 0, length);
                }

                os.flush();
                os.close();
                is.close();

                tvStatus.setText("База данных скопирована");
            } else {
                tvStatus.setText("База данных уже существует");
            }
        } catch (Exception e) {
            tvStatus.setText("Ошибка копирования БД: " + e.getMessage());
        }
    }

    private void initDatabase() {
        if (NativeBridge.initDatabase(dbPath)) {
            tvStatus.setText("База данных инициализирована");
        } else {
            tvStatus.setText("Ошибка инициализации БД");
        }
    }

    private void setupListeners() {
        // Авторизация
        btnLogin.setOnClickListener(v -> loginUser());
        btnRegister.setOnClickListener(v -> registerUser());

        // Клиенты
        btnAddClient.setOnClickListener(v -> addClient());
        btnShowClients.setOnClickListener(v -> showClients());

        // Услуги
        btnAddService.setOnClickListener(v -> addService());
        btnShowServices.setOnClickListener(v -> showServices());

        // Заказы
        btnCreateOrder.setOnClickListener(v -> createOrder());
        btnShowOrders.setOnClickListener(v -> showOrders());

        // Статистика и управление
        btnGetStatistics.setOnClickListener(v -> getStatistics());
        btnBackup.setOnClickListener(v -> backupDatabase());
        btnExit.setOnClickListener(v -> finish());
    }

    private void loginUser() {
        String username = etUsername.getText().toString();
        String password = etPassword.getText().toString();

        if (username.isEmpty() || password.isEmpty()) {
            Toast.makeText(this, "Введите логин и пароль", Toast.LENGTH_SHORT).show();
            return;
        }

        int userId = NativeBridge.authenticateUser(username, password);
        if (userId > 0) {
            tvStatus.setText("Вход выполнен. ID пользователя: " + userId);
            Toast.makeText(this, "Добро пожаловать!", Toast.LENGTH_SHORT).show();
        } else {
            tvStatus.setText("Ошибка входа. Неверный логин или пароль");
        }
    }

    private void registerUser() {
        String username = etUsername.getText().toString();
        String password = etPassword.getText().toString();

        if (username.isEmpty() || password.isEmpty()) {
            Toast.makeText(this, "Введите логин и пароль", Toast.LENGTH_SHORT).show();
            return;
        }

        if (NativeBridge.registerUser(username, password, username, "client")) {
            tvStatus.setText("Пользователь зарегистрирован: " + username);
            Toast.makeText(this, "Регистрация успешна!", Toast.LENGTH_SHORT).show();
        } else {
            tvStatus.setText("Ошибка регистрации");
        }
    }

    private void addClient() {
        String name = etClientName.getText().toString();
        String phone = etClientPhone.getText().toString();

        if (name.isEmpty() || phone.isEmpty()) {
            Toast.makeText(this, "Введите имя и телефон", Toast.LENGTH_SHORT).show();
            return;
        }

        if (NativeBridge.addClient(name, phone, "")) {
            tvStatus.setText("Клиент добавлен: " + name);
            etClientName.setText("");
            etClientPhone.setText("");
            Toast.makeText(this, "Клиент успешно добавлен", Toast.LENGTH_SHORT).show();
        } else {
            tvStatus.setText("Ошибка добавления клиента");
        }
    }

    private void showClients() {
        String[] clients = NativeBridge.getAllClients();
        StringBuilder sb = new StringBuilder();
        sb.append("Список клиентов:\n");

        if (clients != null && clients.length > 0) {
            for (String client : clients) {
                sb.append(client).append("\n");
            }
        } else {
            sb.append("Клиентов нет");
        }

        tvStatus.setText(sb.toString());
    }

    private void addService() {
        String name = etServiceName.getText().toString();
        String priceStr = etServicePrice.getText().toString();

        if (name.isEmpty() || priceStr.isEmpty()) {
            Toast.makeText(this, "Введите название и цену услуги", Toast.LENGTH_SHORT).show();
            return;
        }

        try {
            double price = Double.parseDouble(priceStr);
            if (NativeBridge.addService(name, "Описание услуги", price)) {
                tvStatus.setText("Услуга добавлена: " + name);
                etServiceName.setText("");
                etServicePrice.setText("");
                Toast.makeText(this, "Услуга успешно добавлена", Toast.LENGTH_SHORT).show();
            } else {
                tvStatus.setText("Ошибка добавления услуги");
            }
        } catch (NumberFormatException e) {
            Toast.makeText(this, "Введите корректную цену", Toast.LENGTH_SHORT).show();
        }
    }

    private void showServices() {
        String[] services = NativeBridge.getAllServices();
        StringBuilder sb = new StringBuilder();
        sb.append("Список услуг:\n");

        if (services != null && services.length > 0) {
            for (String service : services) {
                sb.append(service).append("\n");
            }
        } else {
            sb.append("Услуг нет");
        }

        tvStatus.setText(sb.toString());
    }

    private void createOrder() {
        String clientIdStr = etOrderClientId.getText().toString();

        if (clientIdStr.isEmpty()) {
            Toast.makeText(this, "Введите ID клиента", Toast.LENGTH_SHORT).show();
            return;
        }

        try {
            int clientId = Integer.parseInt(clientIdStr);
            String date = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date());

            int orderId = NativeBridge.createOrder(clientId, date);
            if (orderId > 0) {
                tvStatus.setText("Заказ создан. ID заказа: " + orderId);
                etOrderClientId.setText("");
                Toast.makeText(this, "Заказ успешно создан", Toast.LENGTH_SHORT).show();
            } else {
                tvStatus.setText("Ошибка создания заказа");
            }
        } catch (NumberFormatException e) {
            Toast.makeText(this, "Введите корректный ID клиента", Toast.LENGTH_SHORT).show();
        }
    }

    private void showOrders() {
        String[] orders = NativeBridge.getAllOrders();
        StringBuilder sb = new StringBuilder();
        sb.append("Список заказов:\n");

        if (orders != null && orders.length > 0) {
            for (String order : orders) {
                sb.append(order).append("\n");
            }
        } else {
            sb.append("Заказов нет");
        }

        tvStatus.setText(sb.toString());
    }

    private void getStatistics() {
        String stats = NativeBridge.getStatistics();
        tvStatus.setText(stats);
    }

    private void backupDatabase() {
        String backupPath = getExternalFilesDir(null) + "/autoservice_backup.db";
        if (NativeBridge.backupDatabase(backupPath)) {
            tvStatus.setText("Резервная копия создана: " + backupPath);
            Toast.makeText(this, "Бэкап успешно создан", Toast.LENGTH_SHORT).show();
        } else {
            tvStatus.setText("Ошибка создания бэкапа");
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        NativeBridge.closeDatabase();
    }
}