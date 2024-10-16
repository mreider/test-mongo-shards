#!/bin/bash

# Update and install necessary packages
sudo apt update
sudo apt install -y openjdk-11-jdk maven docker.io docker-compose

# Build Java services
echo "Building Service A..."
cd service-a
mvn clean package -X
cd ..

echo "Building Service B..."
cd service-b
mvn clean package -X
cd ..

# Run Docker Compose
echo "Starting Docker Compose..."
docker-compose up --build
