# Getting start with my playbook
#### Install a ansible server:
#### Monolithic Ansible server
# Version information:
```
- Ansible [core 2.15.13]
- Python version = 3.9.20 (main, Sep  9 2024, 00:00:00) [GCC 11.5.0 20240719 (Red Hat 11.5.0-2)]
- jinja version = 3.1.2
- libyaml = True
```
#### Docker images
```
docker pull vminh492018/ansible:ubuntu2204
```

# Ansible.cfg
```
[defaults]
inventory =  /home/minhvx/Ansible_projects/VHKT_VTT/inventory/hosts.ini
roles_path = /home/minhvx/Ansible_projects/VHKT_VTT/roles
```
# Inventory
```
<!--  Use with root user
[VHKT_server]
centos9 ansible_host=localhost
centos7 ansible_host=192.168.153.31
ubuntu2204 ansible_host=192.168.153.44
-->

<!-- Use with user can sudo -->
[VHKT_Test_lab]
ansible-server-testlab ansible_host=minhvx ansible_user=minhvx ansible_become=yes ansible_become_method=sudo
```

# Playbook
```
---
- name: Check OS information
  hosts: VHKT_server
  become: true  # User can sudo
  roles:
    - check_ip_version_kernel
    - check_timezone
    - check_var_partition_conf
 .....
```

# Run command
```
*** Nếu chạy với user root sử dung command sau:
ansible-playbook -i inventory/hosts.ini playbooks/check_OS.yml
*** Nếu chạy với user có quyền sudo sử dung command sau:
ansible-playbook -i inventory/hosts.ini playbooks/check_OS.yml --ask-become-pass
-	Sau đó thực hiện nhập pass remote của user  
-	hoặc có thể cấu hình pass bên trong inventory (khômg khuyến khích cách này)
-	hoặc có thể sử dung ansible vault để mã hóa pass vào 1 file và cấu hình var trong inventory và playbook

```
