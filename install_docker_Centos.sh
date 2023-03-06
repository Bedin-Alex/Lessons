#!/bin/bash
menu(){
echo "1 - Installation of packages
2 - Install Docker Engine
3 - Docker Start
4 - Docker Enable Service
5 - Grant privileges to user"
read choice

if [[ $choice == "1" ]];
then
 step_1
fi

if [[ $choice == "2" ]];
then
 step_2
fi

if [[ $choice == "3" ]];
then
 step_3
fi

if [[ $choice == "4" ]];
then
 step_4
fi

if [[ $choice == "5" ]];
then
 step_5
fi
}

step_1(){
 echo "Step 1. Installing required packages"
 sudo yum install -y yum-utils
 sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
 menu
}

step_2(){
 echo "Install Docker Engine"
 sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
 menu
}

step_3(){
 echo "Docker start"
 systemctl start docker
 menu
}

step_4(){
 echo "Enable service docker"
 systemctl enable docker
 menu
}

step_5(){
 echo "Will be given privileges to current user"
 sudo groupadd docker
 sudo usermod -aG docker $USER
 newgrp docker
 docker ps
}

menu
