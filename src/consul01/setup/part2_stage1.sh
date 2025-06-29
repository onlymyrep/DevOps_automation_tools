#!/bin/bash
# Подключение утилит
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
source "${SCRIPT_DIR}/utilities.sh"

if ! command -v vagrant >/dev/null 2>&1; then
    log_warning "⚠️  Vagrant не установлен"
    exit 1
fi

if ! command -v newman >/dev/null 2>&1; then
    log_warning "⚠️  Newman не установлен"
    exit 1
fi

log_section "Part 2. Развертывание Consul и Ansible - СТАДИЯ 1"

log_info "🗑️ Удаление всех образов..."
vagrant destroy -f

log_info "Запуск Vagrant"
if ! vagrant up; then
    log_error "Не удалось запустить виртуальные машины"
    exit 1
fi
check_result "Виртуальные машины запущены"

log_info "🔄 Проверка статуса кластера..."
vagrant status
check_result "Статус машин проверен"

log_info "Ожидание загрузки машин..."
wait_with_progress 30

log_section "ОТЧЁТ О ВЫПОЛНЕННОЙ РАБОТЕ"
echo -e "\n${BLUE}🎉 Part 2. Развертывание Consul и Ansible - СТАДИЯ 1 - ЗАВЕРШЕНА!${NC}"
