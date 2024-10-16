#!/bin/bash

# Update and install necessary packages
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common openjdk-11-jdk maven

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the apt package index again
sudo apt update

# Install the latest version of Docker Engine and containerd
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Manage Docker as a non-root user
sudo groupadd docker
sudo usermod -aG docker $USER

# Enable Docker to start on boot
sudo systemctl enable docker

# Build Java services
echo "Building Service A..."
cd service-a
mvn clean package
cd ..

echo "Building Service B..."
cd service-b
mvn clean package
cd ..

# Run Docker Compose
echo "Starting Docker Compose..."
docker-compose up --build
