#!/bin/bash

# Путь к файлу списка серверов
SERVER_LIST="servers.list"

# Функция для очистки экрана
clear_screen() {
    clear
}

# Функция для подключения к серверу
connect_to_server() {
    clear_screen
    if [ ! -f $SERVER_LIST ]; then
        echo -e "\e[31mСписок серверов пуст.\e[0m"
        read -p "Нажмите любую клавишу чтобы продолжить..."
        clear_screen
        return
    fi
    
    echo -e "\e[34mСписок доступных серверов:\e[0m"
    awk -F"|" '{print "\033[32m- " $1 " (" $2 ")\033[0m"}' $SERVER_LIST
    
    read -p "Введите название сервера для подключения: " name
    server_info=$(grep "^$name|" $SERVER_LIST)
    
    if [ -n "$server_info" ]; then
        IFS='|' read -r server_name server_ip server_password <<< "$server_info"
        echo -e "\e[33mПодключение к серверу $server_name ($server_ip)...\e[0m"
        sshpass -p "$server_password" ssh -o StrictHostKeyChecking=no root@"$server_ip"
        clear_screen
    else
        echo -e "\e[31mСервер с названием $name не найден.\e[0m"
        read -p "Нажмите любую клавишу чтобы продолжить..."
        clear_screen
    fi
}

# Функция для добавления сервера в список
add_server() {
    clear_screen
    read -p "Введите название сервера: " name
    read -p "Введите IP или домен сервера: " ip
    read -sp "Введите пароль root: " password
    echo

    echo "$name|$ip|$password" >> $SERVER_LIST
    echo -e "\e[32mСервер $name добавлен в список.\e[0m"
    read -p "Нажмите любую клавишу чтобы продолжить..."
    clear_screen
}

# Функция для удаления сервера из списка
remove_server() {
    clear_screen
    if [ ! -f $SERVER_LIST ]; then
        echo -e "\e[31mСписок серверов пуст.\e[0m"
        read -p "Нажмите любую клавишу чтобы продолжить..."
        clear_screen
        return
    fi

    echo -e "\e[34mСписок доступных серверов:\e[0m"
    while IFS= read -r line
    do
        IFS='|' read -r -a server <<< "$line"
        echo -e "\e[32m- ${server[0]} (${server[1]})\e[0m"
    done < $SERVER_LIST

    read -p "Введите название сервера для удаления: " name

    if grep -q "^$name|" $SERVER_LIST; then
        grep -v "^$name|" $SERVER_LIST > $SERVER_LIST.tmp && mv $SERVER_LIST.tmp $SERVER_LIST
        echo -e "\e[32mСервер $name удалён из списка.\e[0m"
    else
        echo -e "\e[31mСервер с названием $name не найден.\e[0m"
    fi
    read -p "Нажмите любую клавишу чтобы продолжить..."
    clear_screen
}

# Функция для показа списка серверов
list_servers() {
    clear_screen
    if [ ! -f $SERVER_LIST ]; then
        echo -e "\e[31mСписок серверов пуст.\e[0m"
        read -p "Нажмите любую клавишу чтобы продолжить..."
        clear_screen
        return
    fi
    
    echo -e "\e[34mСписок доступных серверов:\e[0m"
    while IFS= read -r line
    do
        IFS='|' read -r -a server <<< "$line"
        echo -e "\e[32m- ${server[0]} (${server[1]})\e[0m"
    done < $SERVER_LIST
    
    read -p "Нажмите любую клавишу чтобы продолжить..."
    clear_screen
}

# Основное меню
while true; do
    echo -e "\e[34m1. Подключиться к серверу\e[0m"
    echo -e "\e[34m2. Добавить сервер\e[0m"
    echo -e "\e[34m3. Удалить сервер\e[0m"
    echo -e "\e[34m4. Показать список серверов\e[0m"
    echo -e "\e[34m5. Выйти\e[0m"
    read -p "Выберите опцию: " choice
    
    case $choice in
        1) connect_to_server ;;
        2) add_server ;;
        3) remove_server ;;
        4) list_servers ;;
        5) break ;;
        *) 
            echo -e "\e[31mНеверный выбор! Пожалуйста, попробуйте снова.\e[0m"
            read -p "Нажмите любую клавишу чтобы продолжить..."
            clear_screen
            ;;
    esac
done

