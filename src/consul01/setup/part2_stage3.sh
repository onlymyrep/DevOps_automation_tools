#!/bin/bash
# Подключение утилит
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
source "${SCRIPT_DIR}/utilities.sh"

log_section "Part 2. Развертывание Consul и Ansible - СТАДИЯ 3"

log_section "Проверка развернутых сервисов"
newman run ./tests/application_tests.postman_collection.json
check_result "Тесты Postman выполнены"

log_section "ОТЧЁТ О ВЫПОЛНЕННОЙ РАБОТЕ"
echo -e "\n${BLUE}🎉 Part 2. Развертывание Consul и Ansible - СТАДИЯ 3 - ЗАВЕРШЕНА!${NC}"
echo -e "${GREEN}📋 Результаты развертывания:${NC}"
echo -e "   • consul_server: Consul сервер (192.168.56.10)"
echo -e "   • manager: Consul UI (http://localhost:8500)"
echo -e "   • api: Hotels API (http://localhost:8082)"
echo -e "   • db: PostgreSQL (192.168.56.30:5432)"
echo -e "\n${GREEN}🔗 Ссылки:${NC}"
echo -e "   • Consul UI: http://91.219.189.29:8500"
echo -e "   • Hotels API: http://91.219.189.29:8082/api/v1/hotels"
