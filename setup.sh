#!/bin/bash

# Update and install necessary packages
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common openjdk-11-jdk maven wget

# Install MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt update
sudo apt install -y mongodb-org

# Start MongoDB service
sudo systemctl start mongod
sudo systemctl enable mongod

# Configure MongoDB sharding
sudo mkdir -p /data/shard1 /data/shard2 /data/config
sudo mkdir -p /var/log/mongodb
sudo chown -R `whoami` /var/log/mongodb

# Start shard1 with forking
echo "Starting shard1..."
sudo mongod --shardsvr --replSet shard1 --port 27018 --dbpath /data/shard1 --logpath /var/log/mongodb/shard1.log --fork

# Start shard2 with forking
echo "Starting shard2..."
sudo mongod --shardsvr --replSet shard2 --port 27019 --dbpath /data/shard2 --logpath /var/log/mongodb/shard2.log --fork

# Start config server with forking
echo "Starting config server..."
sudo mongod --configsvr --replSet configReplSet --port 27017 --dbpath /data/config --logpath /var/log/mongodb/config.log --fork

# Give the processes a moment to start
sleep 5

# Initiate replica sets
mongo --port 27018 --eval 'rs.initiate({_id: "shard1", members: [{_id: 0, host: "localhost:27018"}]})'
mongo --port 27019 --eval 'rs.initiate({_id: "shard2", members: [{_id: 0, host: "localhost:27019"}]})'
mongo --port 27017 --eval 'rs.initiate({_id: "configReplSet", configsvr: true, members: [{_id: 0, host: "localhost:27017"}]})'

# Start mongos with forking
echo "Starting mongos..."
sudo mongos --configdb configReplSet/localhost:27017 --port 27020 --logpath /var/log/mongodb/mongos.log --fork

# Add shards to the cluster
mongo --port 27020 --eval 'sh.addShard("shard1/localhost:27018")'
mongo --port 27020 --eval 'sh.addShard("shard2/localhost:27019")'

# Build and run Java services
echo "Building and running Service A..."
cd service-a
mvn clean package
nohup java -jar target/service-a-1.0-SNAPSHOT.jar > ../service-a.log 2>&1 &
cd ..


echo "Building and running Service B..."
cd service-b
mvn clean package
nohup java -jar target/service-b-1.0-SNAPSHOT.jar > ../service-b.log 2>&1 &
cd ..

echo "Setup complete. MongoDB is running and Java applications are started."
echo "Logs can be found in shard1.log, shard2.log, configsvr.log, mongos.log, service-a.log, and service-b.log."
echo "To view logs, run ./tail.sh"