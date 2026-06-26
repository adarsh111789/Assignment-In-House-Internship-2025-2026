from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("PartitionDemo").getOrCreate()

df = spark.range(5000000)

print("Initial Partitions:", df.rdd.getNumPartitions())

repartitioned_df = df.repartition(12)
print("Partitions after repartition:", repartitioned_df.rdd.getNumPartitions())

coalesced_df = repartitioned_df.coalesce(3)
print("Partitions after coalesce:", coalesced_df.rdd.getNumPartitions())

spark.stop()
