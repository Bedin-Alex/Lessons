#!/bin/bash

step_1(){
 echo "Step 1. Installing required packages"
 sudo yum install -y yum-utils
 sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
 step_2
}

step_2(){
 echo "Install Docker Engine"
 sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
 step_3
}

step_3(){
 echo "Docker start"
 systemctl start docker
 step_4
}

step_4(){
 echo "Enable service docker"
 systemctl enable docker
 step_5
}

step_5(){
 echo "Will be given privileges to current user"
 sudo groupadd docker
 sudo usermod -aG docker $USER
 newgrp docker
 docker ps
}

step_1
