datacenter = "dc1"
data_dir = "/opt/consul"
server = true
bootstrap_expect = 1
ui = true
bind_addr = "{{ ansible_default_ipv4.address }}"
client_addr = "0.0.0.0"