FROM ubuntu:20.04
MAINTAINER Martin Polak

ENV HOME /root

RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen cs_CZ.UTF-8
ENV LANG cs_CZ.UTF-8

RUN (apt-get update && \
     DEBIAN_FRONTEND=noninteractive \
     apt-get install -y software-properties-common \
                        vim git byobu wget curl unzip tree exuberant-ctags \
                        python gdb screen tidy nodejs npm)
                        
# Install OpenJDK
RUN (apt-get install -y openjdk-8-jdk ant maven)

# Add a non-root user
RUN (useradd -m -d /home/docker -s /bin/bash docker && \
     echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers)

USER docker
ENV HOME /home/docker
WORKDIR /home/docker

# Install golang
RUN (wget https://dl.google.com/go/go1.13.5.linux-amd64.tar.gz && \
tar -xvf go1.13.5.linux-amd64.tar.gz && \
mkdir /home/docker/src && \
rm go1.13.5.linux-amd64.tar.gz)

# Install jshint
RUN (npm i jshint)

# Git configuration
RUN (git config --global user.email "nigol@nigol.cz" && \
  git config --global user.name "Martin Polak" && \
  git config --global core.filemode false)
  
# micro configuration
USER root
RUN (wget https://github.com/zyedidia/micro/releases/download/v2.0.6/micro-2.0.6-linux64.tar.gz && \
    tar xvf micro-2.0.6-linux64.tar.gz && \
    rm micro-2.0.6-linux64.tar.gz && \
    mv micro-2.0.6/micro /usr/bin/ && \
    rm micro-2.0.6/ -rf)
USER docker
RUN (mkdir /home/docker/.config/micro && \
    git clone https://github.com/nigol/micro-cfg.git && \
    mv /home/docker/micro-cfg/settings.json /home/docker/.config/micro &&\
    rm /home/docker/micro-cfg -rf)
    
# Vim configuration
RUN (git clone https://github.com/nigol/vimrc && \
    cp vimrc/vimrc .vimrc)

# Prepare SSH key file
RUN (mkdir /home/docker/.ssh && \
    touch /home/docker/.ssh/id_rsa && \
    chmod 600 /home/docker/.ssh/id_rsa)

USER docker
RUN (echo "export PATH=$PATH:/home/docker/go/bin:/home/docker/node_modules/jshint/bin" >> ~/.profile && \
    echo "export GOPATH=/home/docker" >> ~/.profile)
RUN (echo "export PATH=$PATH:/home/docker/go/bin:/home/docker/node_modules/jshint/bin" >> ~/.bashrc && \
    echo "export GOPATH=/home/docker" >> ~/.bashrc)

USER root
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD [“/bin/sh”]
