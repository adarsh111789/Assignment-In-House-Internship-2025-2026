# Assignment 18 - PySpark Partition Management

## Objective
Create a PySpark DataFrame with 5 million records using spark.range() and perform partition operations.

Operations:
- Display initial number of partitions
- Increase partitions to 12 using repartition()
- Reduce partitions to 3 using coalesce()

## Build Docker Image
docker build -t assignment18 .

## Run Docker Container
docker run assignment18
