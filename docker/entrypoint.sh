#!/bin/bash

# Default values for UID and GID
USER_ID=${LOCAL_UID:-1001}
GROUP_ID=${LOCAL_GID:-1001}

# Create group if it doesn't exist
if ! getent group devops > /dev/null; then
    groupadd -g "$GROUP_ID" devops
fi

# Create user if it doesn't exist
if ! id -u devops > /dev/null 2>&1; then
    useradd -u "$USER_ID" -g "$GROUP_ID" -m -s /bin/bash devops
    mkdir -p /home/devops/.ssh
    chown -R devops:devops /home/devops
fi

# Update SSH configuration
echo 'AllowUsers devops' >> /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Switch to the "devops" user and execute the given command
exec gosu devops "$@"
