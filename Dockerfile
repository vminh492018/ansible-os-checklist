FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    software-properties-common \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    python3-pip \
    curl \
    gnupg && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    pip3 install ansible-core==2.15.13 jinja2==3.1.2 && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash devops && \
    mkdir -p /home/devops/.ssh && \
    chown -R devops:devops /home/devops

USER devops

WORKDIR /home/devops/ansible-projects

CMD ["/bin/bash/"]
