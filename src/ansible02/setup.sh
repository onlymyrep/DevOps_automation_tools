#!/bin/bash

# Генерация SSH-ключа на manager
echo "Generating SSH key on manager..."
vagrant ssh manager --command "ssh-keygen -t rsa -b 4096 -f /home/vagrant/.ssh/id_rsa -N \"\""

# Экспорт публичного ключа
echo "Exporting manager's public key..."
vagrant ssh manager --command "cat /home/vagrant/.ssh/id_rsa.pub" > manager.pub

# Распространение ключа на все ноды
nodes=("manager" "api" "db" "consul_server")
for node in "${nodes[@]}"; do
    echo "Configuring SSH access for $node..."
    vagrant ssh "$node" --command "mkdir -p /home/vagrant/.ssh && chmod 700 /home/vagrant/.ssh && cat >> /home/vagrant/.ssh/authorized_keys && chmod 600 /home/vagrant/.ssh/authorized_keys" < manager.pub
done



# Очистка временных файлов
rm -f manager.pub
echo "Setup completed!"
