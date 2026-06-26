from pyspark.sql import SparkSession
from pyspark.sql.functions import col

spark = SparkSession.builder.appName("SalesDataFrame").getOrCreate()

df = spark.read.csv("sales_data.csv", header=True, inferSchema=True)

print("Products sorted by sales descending:")
sorted_df = df.orderBy(col("sales").desc())
sorted_df.show()

print("Top 3 highest selling products:")
top3 = sorted_df.limit(3)
top3.show()

filtered = df.filter(col("sales") > 80000)
filtered.write.mode("overwrite").csv("filtered_output", header=True)

spark.stop()
