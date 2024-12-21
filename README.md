## Getting Started
This is a guide for using my project with Ansible and Docker to check Linux system parameters, supporting various OS checklists for enterprise purposes.

### Prerequisites
This guide provides an example of the prerequisites for using the software and detailed instructions for installation.
* Ansible (recommend)
  ```
  - Ansible [core 2.15.13]
  - Python version = 3.10.12 (main, Nov  6 2024, 20:22:13) [GCC 11.4.0] (/usr/bin/python3)
  - jinja version = 3.1.2
  - libyaml = True
  ```
* Docker images (optinal)
  ```
  - docker pull vminh492018/ansible-ubuntu:22.04
  ```
### 1. Local Setup
#### Step 1: Create User `devops` with Sudo and SSH Access
#### Ubuntu
* Create user *devops*:
   ```bash
   sudo adduser devops
   ```
* Set a password when prompted.
* Skip other optional information.
* Add *devops* to the *sudo* group:
   ```bash
   sudo usermod -aG sudo devops
   ```
* Enable SSH access for *devops*:
   ```bash
   sudo mkdir -p /home/devops/.ssh
   sudo chmod 700 /home/devops/.ssh
   sudo chown -R devops:devops /home/devops/.ssh
   ```
#### On CentOS 7/9
* Create user *devops*:
   ```bash
   sudo adduser devops
   ```

* Set a password for *devops*:
   ```bash
   sudo passwd devops
   ```

* Add *devops* to the *wheel* group (for sudo access):**
   ```bash
   sudo usermod -aG wheel devops

   OR:

   sudo visudo
   devops ALL=(ALL) NOPASSWD: ALL
   ```

* Enable SSH access for *devops*:
   ```bash
   sudo mkdir -p /home/devops/.ssh
   sudo chmod 700 /home/devops/.ssh
   sudo chown -R devops:devops /home/devops/.ssh
   ```

#### Step 2: Create Working Directory `/home/devops/ansible-projects`
* Create the directory:
   ```bash
   sudo mkdir -p /home/devops/ansible-projects
   ```

* Set permissions and ownership:
   ```bash
   sudo chmod 755 /home/devops/ansible-projects
   sudo chown -R devops:devops /home/devops/ansible-projects
   ```
   
#### Step 3: Check UID and GID of User *devops*
* Verify UID and GID:
   ```bash
   id devops
   ```
* Sample output:
  ```
  uid=1001(devops) gid=1001(devops) groups=1001(devops),27(sudo)
  ```
* Note down `uid` and `gid` values for later use.
---

### 2. Docker Setup
#### Step 1: Pull Docker Image
* Download the Docker image *vminh492018/ansible-ubuntu:22.04*:
   ```bash
   docker pull vminh492018/ansible-ubuntu:22.04
   ```

#### Step 2: Run Container with Mounted Directory
* Start a container with the working directory mounted and the correct UID/GID:
   ```bash
  docker run -d -it --name ansible_container --user $(id -u devops):$(id -g devops) --mount type=bind,source=/home/devops/ansible-projects,target=/home/devops/ansible-projects vminh492018/ansible-ubuntu:22.04

   OR: (Older docker version)
   docker run -d -it --name ansible_container --user $(id -u devops):$(id -g devops) -v /home/devops/ansible-projects:/home/devops/ansible-projects vminh492018/ansible-ubuntu:22.04
   ```
* Replace `<UID>` and `<GID>` with the values from `id devops`.

### Step 3: Create SSH Key and Configure SSH
#### Generate SSH Key Inside the Container
* Access the container if not already inside:
   ```bash
   docker exec -it ansible-container /bin/bash
   ```

* Generate SSH key:
   ```bash
   ssh-keygen -t rsa -b 2048 -f /home/devops/.ssh/id_rsa -N ""
   ```
* Private key: `/home/devops/.ssh/id_rsa`
* Public key: `/home/devops/.ssh/id_rsa.pub`

* Set appropriate permissions for *.ssh* folder and keys:
   ```bash
   chmod 700 /home/devops/.ssh
   chmod 600 /home/devops/.ssh/id_rsa
   chmod 644 /home/devops/.ssh/id_rsa.pub
   ```

#### Copy SSH Public Key to Remote Servers
* Use `ssh-copy-id` to add the public key to remote servers:
   ```bash
   ssh-copy-id -i /home/devops/.ssh/id_rsa.pub devops@<remote_server_ip>
   ```
* Replace `<remote_server_ip>` with the IP address of the target server.
* Enter the password when prompted to complete the setup.

* Test SSH access to the remote server:
   ```bash
   ssh devops@<remote_server_ip>
   ```
* If no password is required, the SSH key is configured correctly.
---

### 3. Test Ansible Setup
* Verify Ansible can connect to the remote server:
   ```bash
   ansible all -i "<remote_server_ip>," -m ping -u devops --private-key=/home/devops/.ssh/id_rsa
   ```
   - Replace `<remote_server_ip>` with the target server IP.
   - A successful `pong` response indicates the connection is working.

## Summary
- **Local:** Set up the `devops` user with sudo and SSH access, and create a working directory.
- **Docker:** Run the container with the correct UID/GID and mount the working directory.
- **SSH Key:** Generate and configure SSH keys for connecting to remote servers.
- **Ansible:** Test the setup by running an Ansible command to check connectivity.
---
## Info my playbook
### Ansible.cfg
```
[defaults]
inventory =  /home/minhvx/Ansible_projects/VHKT_VTT/inventory/hosts.ini
roles_path = /home/minhvx/Ansible_projects/VHKT_VTT/roles
```
### Inventory
```
<!--  Use with root user
[VHKT_server]
centos9 ansible_host=localhost
centos7 ansible_host=192.168.153.31
ubuntu2204 ansible_host=192.168.153.44
-->

<!-- Use with user can sudo -->
[VHKT_Test_lab]
ansible-server-testlab ansible_host= [ip_host] ansible_user=minhvx ansible_become=yes ansible_become_method=sudo ansible_become_password=...
```

### Playbook
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

### Run command
```
*** If running as the root user, use the following command:
ansible-playbook -i inventory/hosts.ini playbooks/check_OS.yml

*** If running as a user with sudo privileges, use the following command:
ansible-playbook -i inventory/hosts.ini playbooks/check_OS.yml --ask-become-pass

Then enter the remote user's password
Alternatively, you can configure the password inside the inventory (not recommended)
Or you can use Ansible Vault to encrypt the password into a file and configure the variable in the inventory and playbook

```
