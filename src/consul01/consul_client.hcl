server = false
advertise_addr = "{{ ansible_eth1.ipv4.address }}"
retry_join = ["consul_server"]
data_dir = "/opt/consul"