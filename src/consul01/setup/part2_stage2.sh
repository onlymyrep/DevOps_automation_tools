#!/bin/bash
# Подключение утилит
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
source "${SCRIPT_DIR}/utilities.sh"

log_section "Part 2. Развертывание Consul и Ansible - СТАДИЯ 2"

log_section "Подготовка manager как управляющей станции"

log_info "Проверка доступности manager..."
vagrant status manager
check_result "Manager доступен"

log_info "Проверка подключения к узлам через ssh по приватной сети..."
vagrant ssh manager -c "ping -c 3 192.168.56.10"
check_result "Сетевая связность с consul_server"

vagrant ssh manager -c "ping -c 3 192.168.56.20"
check_result "Сетевая связность с api"

vagrant ssh manager -c "ping -c 3 192.168.56.30"
check_result "Сетевая связность с db"

log_info "Установка Ansible на manager..."
vagrant ssh manager -c "
    sudo apt update -qq
    sudo apt install -y ansible
"
check_result "Ansible установлен"

log_info "Создание директорий на manager..."
vagrant ssh manager -c "mkdir -p ~/ansible/{files,consul01} ~/consul01"
check_result "Директории созданы"

log_info "Копирование файлов ansible02 на manager..."
if [ -d "../ansible02" ]; then
    tar -czf - -C ../ ansible02 | vagrant ssh manager -c "cd ~ && tar -xzf -"
    check_result "Файлы ansible02 скопированы"
else
    log_error "Директория ../ansible02 не найдена"
    exit 1
fi

log_info "Копирование конфигураций consul на manager..."
if [ -f "consul_server.hcl" ] && [ -f "consul_client.hcl" ]; then
    tar -czf - consul_server.hcl consul_client.hcl | vagrant ssh manager -c "cd ~/consul01 && tar -xzf -"
    check_result "Конфигурации consul скопированы"
else
    log_error "Конфигурационные файлы consul не найдены"
    exit 1
fi

log_info "Копирование сервисов на manager..."
if [ -d "../../src/services" ]; then
    tar -czf - -C ../.. src/services | vagrant ssh manager -c "cd ~/ansible/files && tar -xzf -"
    check_result "Сервисы скопированы"
else
    log_error "Директория ../../src/services не найдена"
    exit 1
fi

log_info "Копирование ключей доступа на manager..."
if [ -d ".vagrant" ]; then
    tar -czf - .vagrant | vagrant ssh manager -c "cd ~/ansible02 && tar -xzf -"
    check_result "Ключи доступа скопированы"
else
    log_error "Директория .vagrant не найдена"
    exit 1
fi

log_info "Настройка прав доступа на manager..."
vagrant ssh manager -c "
    sudo chown -R vagrant:vagrant ~/ansible02 ~/consul01 ~/ansible
    chmod -R 600 ~/ansible02/.vagrant/machines/*/virtualbox/private_key
"
check_result "Права доступа настроены"

log_info "Проверка подключения через Ansible (модуль ping)..."
vagrant ssh manager -c "cd ~/ansible02 && ANSIBLE_HOST_KEY_CHECKING=False ansible all -i inventory -m ping"
check_result "Ping всех узлов через Ansible успешен"

log_section "Запуск развертывания через Ansible"

log_info "Запуск Ansible плейбука с manager..."
vagrant ssh manager -c "cd ~/ansible02 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory ansible-playbook.yml -v"
check_result "Ansible плейбук выполнен"

log_info "Ожидание запуска всех сервисов..."
wait_with_progress 60

log_section "ОТЧЁТ О ВЫПОЛНЕННОЙ РАБОТЕ"
echo -e "\n${BLUE}🎉 Part 2. Развертывание Consul и Ansible - СТАДИЯ 2 - ЗАВЕРШЕНА!${NC}"
