#!/bin/bash

# Stop Java services
echo "Stopping Service A..."
pkill -f 'com.example.servicea.ServiceA'

echo "Stopping Service B..."
pkill -f 'com.example.serviceb.ServiceB'

# Stop mongos
echo "Stopping mongos..."
sudo pkill -f 'mongos --configdb configReplSet/localhost:27017 --port 27020'

# Stop MongoDB shards and config server
echo "Stopping shard1..."
sudo pkill -f 'mongod --shardsvr --replSet shard1 --port 27018'

echo "Stopping shard2..."
sudo pkill -f 'mongod --shardsvr --replSet shard2 --port 27019'

echo "Stopping config server..."
sudo pkill -f 'mongod --configsvr --replSet configReplSet --port 27017'

# Stop MongoDB service
echo "Stopping MongoDB service..."
sudo systemctl stop mongod

echo "Shutdown complete. All MongoDB processes and Java services have been stopped."
