package com.example.serviceb;

import com.mongodb.MongoClient;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import org.bson.Document;

import static spark.Spark.get;
import static spark.Spark.port;

public class ServiceB {
    public static void main(String[] args) {
        port(8081);
        get("/insert", (req, res) -> {
            try (MongoClient mongoClient = new MongoClient("localhost", 27020)) {
                MongoDatabase db1 = mongoClient.getDatabase("shard1");
                MongoDatabase db2 = mongoClient.getDatabase("shard2");

                MongoCollection<Document> collection1 = db1.getCollection("test");
                MongoCollection<Document> collection2 = db2.getCollection("test");

                Document doc = new Document("name", "example")
                        .append("value", Math.random());

                collection1.insertOne(doc);
                collection2.insertOne(doc);

                return "Inserted into both shards";
            }
        });
    }
}
