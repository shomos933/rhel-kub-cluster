#cloud-config
datasource_list: [NoCloud]
preserve_hostname: false
hostname: ${hostname}
manage_etc_hosts: false

users:
  - name: ubuntu
    gecos: "User for Ansible automation"
    lock_passwd: false              # разрешаем логин по паролю
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_key}
# Задаём пароль ubuntu/ubuntu
ssh_pwauth: true
chpasswd:
  list: |
    ubuntu:ubuntu
  expire: false
network:
  version: 2
  ethernets:
    ens3:
      addresses: ["${static_ip}/24"]
      gateway4: 192.168.122.1
      nameservers:
        addresses: [192.168.122.1]

