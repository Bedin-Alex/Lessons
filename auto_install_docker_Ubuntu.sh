#!/bin/bash

echo "Step 1. Installing required packages"
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "Step 2. Installing GPG"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "Step 3. Installing repository"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Step 4. Installing docker + features"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "Will be given privileges to current user"
sudo groupadd docker
sudo usermod -aG docker $USER
#newgrp docker
docker ps
