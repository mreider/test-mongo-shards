#!/bin/bash

# Update and install necessary packages
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common openjdk-11-jdk maven wget

# Install MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt update
sudo apt install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

# Configure MongoDB sharding
sudo mkdir -p /data/shard1 /data/shard2 /data/config

sudo mongod --shardsvr --replSet shard1 --port 27018 --dbpath /data/shard1 --logpath /var/log/mongodb/shard1.log --fork
sudo mongod --shardsvr --replSet shard2 --port 27019 --dbpath /data/shard2 --logpath /var/log/mongodb/shard2.log --fork
sudo mongod --configsvr --replSet configReplSet --port 27017 --dbpath /data/config --logpath /var/log/mongodb/config.log --fork

mongo --port 27018 --eval 'rs.initiate({_id: "shard1", members: [{_id: 0, host: "localhost:27018"}]})'
mongo --port 27019 --eval 'rs.initiate({_id: "shard2", members: [{_id: 0, host: "localhost:27019"}]})'
mongo --port 27017 --eval 'rs.initiate({_id: "configReplSet", configsvr: true, members: [{_id: 0, host: "localhost:27017"}]})'

sudo mongos --configdb configReplSet/localhost:27017 --port 27020 --logpath /var/log/mongodb/mongos.log --fork

mongo --port 27020 --eval 'sh.addShard("shard1/localhost:27018")'
mongo --port 27020 --eval 'sh.addShard("shard2/localhost:27019")'

# Build and run Java services
echo "Building and running Service A..."
cd service-a
mvn clean package
mvn exec:java -Dexec.mainClass="com.example.servicea.ServiceA" &
cd ..

echo "Building and running Service B..."
cd service-b
mvn clean package
mvn exec:java -Dexec.mainClass="com.example.serviceb.ServiceB" &
cd ..

echo "Setup complete. MongoDB is running and Java applications are started."
