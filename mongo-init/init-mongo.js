// Initialize shard1
rs.initiate({
  _id: "shard1",
  members: [{ _id: 0, host: "shard1:27018" }]
});

// Initialize shard2
rs.initiate({
  _id: "shard2",
  members: [{ _id: 0, host: "shard2:27019" }]
});

// Initialize config server
rs.initiate({
  _id: "configReplSet",
  configsvr: true,
  members: [{ _id: 0, host: "configsvr:27017" }]
});

// Add shards to the cluster
sh.addShard("shard1/shard1:27018");
sh.addShard("shard2/shard2:27019");
