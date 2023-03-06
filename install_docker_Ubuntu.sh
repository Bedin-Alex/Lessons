#!/bin/bash

menu(){
echo "1 - Installation of packages
2 - Getting of GPG
3 - Installation of repositories
4 - Installation of Docker and features
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
 sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
 menu
}

step_2(){
 echo "Step 2. Installing GPG"
 sudo mkdir -p /etc/apt/keyrings
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
 menu
}

step_3(){
 echo "Step 3. Installing repository"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
 menu
}

step_4(){
 echo "Step 4. Installing docker + features"
 sudo apt-get update -y
 sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
}

step_5(){
 echo "Will be given privileges to current user"
 sudo groupadd docker
 sudo usermod -aG docker $USER
 newgrp docker
 docker ps
}

menu
