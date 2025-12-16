cmake_minimum_required(VERSION 3.22.1)

project("autoservice")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Добавляем библиотеку
add_library(
        native-lib
        SHARED
        native-lib.cpp
        DatabaseManager.cpp
)

# Находим библиотеки
find_library(log-lib log)

# Линкуем библиотеки
target_link_libraries(
        native-lib
        android
        ${log-lib}
        # SQLite уже встроен в Android, поэтому не нужно явно линковать
)