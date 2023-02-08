#!/bin/bash
menu(){
echo "1 - Installation of packages
2 - Install Docker Engine
3 - Docker Start
4 - Docker Enable Service"
read chose

if [[ $chose == "1" ]];
then
 step_1
fi

if [[ $chose == "2" ]];
then
 step_2
fi

if [[ $chose == "3" ]];
then
 step_3
fi

if [[ $chose == "4" ]];
then
 step_4
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

menu
