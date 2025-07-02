## Part 1. Удаленное конфигурирование узла через Ansible

### 1. Создание машин и проброс портов

- Создать с помощью Vagrant три машины - manager, node01, node02. Прокинуть порты node01 на локальную машину.
   ~/DevOps_8.ID_1220167-2/src/ansible01 % `vagrant init`

   ~/DevOps_8.ID_1220167-2/src/ansible01 % `vagrant up`
![up](misc/images/vagrant_up.png)

   ~/DevOps_8.ID_1220167-2/src/ansible01 % `vagrant status`
![Статус машин](misc/images/vagrant_status.png)

- Проверить, слушает ли Vagrant эти порты
   ~/DevOps_8.ID_1220167-2/src/ansible01 % `netstat -an | grep -E "\.8080|\.8081|\.8082|\.8500"`
![listen_ports](misc/images/vagrant_listen_ports.png)

- Проброшенные порты
![forwarded_ports](misc/images/forwarded_ports.png)

- Проверка портов
   ~/DevOps_8.ID_1220167-2/src/ansible01 % `echo "Проверка портов:"; for port in 8080 8081 8082 8500; do nc -z 127.0.0.1 $port && echo "Порт $port открыт" || echo "Порт $port закрыт"; done`
![ports_check](misc/images/ports_check.png)

### 2. Подготовка manager как рабочей станции

- Проверка подключения к node01
   bartonjo@pr-i3 ansible01 % `vagrant ssh manager`
![vagrant_ssh_manager](misc/images/vagrant_ssh_manager.png)

   vagrant@manager:~$ `ssh vagrant@192.168.56.11`
![perm_denied](misc/images/perm_denied.png)

- Сгенерировать SSH-ключ
   vagrant@manager:~$ `ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""`
![ssh_keygen](misc/images/ssh_keygen.png)

- Копирование публичного ключа
   bartonjo@pr-i3 ansible01 % `vagrant ssh manager -c "cat ~/.ssh/id_rsa.pub" | vagrant ssh node01 -c "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"`

- Скопировать services
   bartonjo@pr-i3 ansible01 % `vagrant upload ../services /home/vagrant/ansible/files/src/services --machine manager`
![upload_services](misc/images/upload_services_to_manager.png)

- Скопировать yml
   bartonjo@pr-i3 ansible01 % `vagrant upload docker-compose.yml /home/vagrant/ansible/files/docker-compose.yml --machine manager`
![upload_yml](misc/images/upload_yml_to_manager.png)

- Установка Ansible на manager
   bartonjo@pr-i3 ansible01 % `vagrant ssh manager`

   vagrant@manager:~$ `sudo apt update`

   vagrant@manager:~$ `sudo apt install -y ansible`

- Создание inventory файла
   vagrant@manager:~$ `cat > inventory << EOF
   [nodes]
   node01 ansible_host=192.168.56.11 ansible_user=vagrant ansible_ssh_private_key_file=~/.ssh/id_rsa
   node02 ansible_host=192.168.56.12 ansible_user=vagrant ansible_ssh_private_key_file=~/.ssh/id_rsa
   [all:vars]
   ansible_ssh_common_args='-o StrictHostKeyChecking=no'
   EOF`
![inventory](misc/images/inventory.png)

- Проверка подключения через Ansible к node01
   vagrant@manager:~$ `ansible all -i inventory -m ping`
![ansible_to_node01](misc/images/ansible_to_node01.png)
![ssh_to_node01](misc/images/ssh_to_node01.png)

### 3. Написание и выполнение плейбука Ansible

- Копирование плейбука на manager
   bartonjo@pr-i3 ansible01 % `tar -czf - ansible-playbook.yml | vagrant ssh manager -c "cd ~/ansible && tar -xzf -"`

- Проверка на виртуальной машине
   bartonjo@pr-i3 ansible01 % `vagrant ssh manager`
   `cd ~/ansible`
   `ls -la`
![ansible_playbook](misc/images/ansible_playbook.png)

- Запуск плейбука
   bartonjo@pr-i3 ansible01 % `vagrant ssh manager -c "cd ~/ansible && ansible-playbook -i inventory ansible-playbook.yml -v"`
![playbook](misc/images/playbook.png)

### 4. Тестирование через Postman

![postman_test_part1](misc/images/postman_test_part1.png)

### 5. Создание и применение ролей Ansible

- Сформировать три роли:
  - application (развертывание приложения)
  - apache (установка Apache)
  - postgres (установка PostgreSQL)

- Плейбук для ролей
![playbook_for_roles](misc/images/playbook_for_roles.png)

- Apache доступен на порту 8090:   
http://localhost:8090
![apache](misc/images/apache.png)

- Проверка PostgreSQL:
vagrant@manager:~/ansible$ `ansible node02 -i inventory -m shell -a "sudo -u postgres psql -d testdb -c 'SELECT * FROM sample_data;'" -b`
![postgresql](misc/images/postgresql.png)

## Part 2. Service Discovery с использованием Consul

### 1. Создание конфигурационных файлов Consul

![server](misc/images/consul_server.png)
![client](misc/images/consul_client.png)

### 2. Создание машин с помощью Vagrant

- Создать четыре машины - consul_server, api, manager и db

   bartonjo@pr-i3 ansible02 % `vagrant up`
![4_machines](misc/images/4_machines.png)
![beautiful_4](misc/images/beautiful_4.png)

### 3. Написание плейбука Ansible и ролей

- `install_consul_server` - установка Consul на сервер
- `install_consul_client` - установка Consul на клиенты
- `install_db` - установка PostgreSQL
- `install_hotels_service` - установка сервиса отелей

![4_roles](misc/images/4_roles.png)

### 4. Проверка работоспособности

- Проверить CRUD-операции над сервисом отелей.

---
- Consul Server (192.168.60.10): 
   - Установлен и настроен Consul в режиме сервера
   - Запущен сервис Consul
---   
- API (192.168.60.11):
   - Установлен Consul в режиме клиента
   - Зарегистрирован сервис hotels-service
   - Установлен Java и сервис отелей
   - Сервис доступен на http://localhost:8082
---
- DB (192.168.60.13):
   - Установлен Consul в режиме клиента
   - Зарегистрирован сервис postgres
   - Установлена PostgreSQL с тестовой базой
   - Создана таблица hotels с тестовыми данными
---
- Manager (192.168.60.12):
   - UI Consul доступен на http://localhost:8500
   - Ansible управляет всей инфраструктурой
---