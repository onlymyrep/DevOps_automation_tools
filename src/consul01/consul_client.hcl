datacenter = "dc1"
data_dir = "/opt/consul"
server = false
retry_join = ["192.168.60.10"]
bind_addr = "{{ ansible_default_ipv4.address }}"
client_addr = "0.0.0.0"