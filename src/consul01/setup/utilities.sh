#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
# Без цвета
NC='\033[0m'

# Функция для форматирования времени
format_time() {
    printf "%02d:%02d:%02d" $((SECONDS/3600)) $((SECONDS%3600/60)) $((SECONDS%60))
}

# Функции для логирования
log_info() {
    echo -e "$(format_time) ${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "$(format_time) ${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "$(format_time) ${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "$(format_time) ${RED}[ERROR]${NC} $1"
}

log_section() {
    echo -e "\n$(format_time) ${YELLOW}=== $1 ===${NC}"
}

# Функция для проверки успешности команды
check_result() {
    if [ $? -eq 0 ]; then
        log_success "$1"
    else
        log_error "$1"
        exit 1
    fi
}

# Функция для ожидания с отображением прогресса
wait_with_progress() {
    local DEFAULT_WAIT_SECONDS=10
    local total_seconds=${1:-$DEFAULT_WAIT_SECONDS}
    local interval=10
    local iterations=$((total_seconds/interval))
    
    log_info "Ожидание $total_seconds секунд..."
    for i in $(seq 1 $iterations); do
        log_info "Прошло $((i*interval)) секунд из $total_seconds..."
        sleep $interval
    done
}
