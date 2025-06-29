#!/bin/bash
echo "Ожидание готовности Consul..."
timeout=60
count=0
until curl -s http://localhost:8500/v1/status/leader | grep -q '"' || [ $count -eq $timeout ]; do
  echo "Consul не готов, ожидание... ($count/$timeout)"
  sleep 5
  count=$((count+5))
done

if [ $count -eq $timeout ]; then
  echo "Timeout: Consul не готов после $timeout секунд"
  exit 1
fi
echo "Consul готов!"

echo "Проверка доступности PostgreSQL..."
count=0
until pg_isready -h 192.168.56.30 -p 5432 -U postgres || [ $count -eq $timeout ]; do
  echo "PostgreSQL не готов, ожидание... ($count/$timeout)"
  sleep 5
  count=$((count+5))
done

if [ $count -eq $timeout ]; then
  echo "Warning: PostgreSQL не доступен после $timeout секунд, продолжаем..."
else
  echo "PostgreSQL готов!"
fi

echo "Ожидание регистрации сервиса postgres в Consul..."
count=0
until curl -s http://localhost:8500/v1/catalog/service/postgres | jq -e '. | length > 0' >/dev/null 2>&1 || [ $count -eq $timeout ]; do
  echo "Сервис postgres не зарегистрирован в Consul, ожидание... ($count/$timeout)"
  sleep 5
  count=$((count+5))
done

if [ $count -eq $timeout ]; then
  echo "Warning: Сервис postgres не найден в Consul после $timeout секунд, продолжаем..."
else
  echo "Сервис postgres найден в Consul!"
fi
