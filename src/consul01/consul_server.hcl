server = true
bootstrap_expect = 1
advertise_addr = "{{ ansible_eth1.ipv4.address }}"
client_addr = "0.0.0.0"
ui = true
data_dir = "/opt/consul"