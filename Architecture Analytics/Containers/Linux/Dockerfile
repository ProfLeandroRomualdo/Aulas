FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Instala SSH + ferramentas úteis para shell script
RUN apt-get update && \
    apt-get install -y \
    openssh-server \
    sudo \
    nano \
    vim \
    curl \
    wget \
    git \
    net-tools \
    iputils-ping \
    dnsutils \
    bash-completion && \
    mkdir /var/run/sshd

# Cria usuário para aula (melhor que root)
RUN useradd -m -s /bin/bash aluno && \
    echo 'aluno:aluno123' | chpasswd && \
    usermod -aG sudo aluno

# Permite login por senha
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# (Opcional) permitir root também
RUN echo 'root:root123' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Ajuste PAM
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# Diretório de aula
WORKDIR /home/aluno

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]