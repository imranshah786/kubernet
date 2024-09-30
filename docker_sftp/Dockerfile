FROM ubuntu:latest
# steps done in one RUN layer for efficiency:
# - install packages
# - openSSH needs /var/run/sshd to run
# - remove generic host keys (entrypoint generates unique keys)
RUN apt-get update && apt-get install -y \
    openssh-server \
    git \
    curl \
    jq \
    bash \
    nano \
    procps \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/sshd \
    && rm -f /etc/ssh/ssh_host_*key*
    
# install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# copy configuration files
COPY sshd_config.sh /etc/ssh/
COPY create-sftp-user.sh /usr/local/bin/
COPY entrypoint.sh /
COPY generate-kube-config.sh /usr/local/bin/

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
