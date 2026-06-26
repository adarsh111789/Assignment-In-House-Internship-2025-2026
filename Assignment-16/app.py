from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("EmployeeRDD").getOrCreate()
sc = spark.sparkContext

rdd = sc.textFile("employee_data.csv")

header = rdd.first()
data = rdd.filter(lambda row: row != header)

employees = data.map(lambda x: x.split(",")) \
                .map(lambda x: (int(x[0]), x[1], x[2], int(x[3])))

# Sort by salary descending
sorted_employees = employees.sortBy(lambda x: x[3], ascending=False)

print("Employees Sorted by Salary:")
for emp in sorted_employees.collect():
    print(emp)

# Department wise salary total
dept_salary = employees.map(lambda x: (x[2], x[3])) \
                       .reduceByKey(lambda a, b: a + b)

print("\nDepartment Wise Total Salary:")
for dept in dept_salary.collect():
    print(dept)

# Top 3 highest paid employees
top3 = sorted_employees.take(3)

with open("output.txt", "w") as f:
    f.write("Top 3 Highest Paid Employees\n")
    for emp in top3:
        f.write(str(emp) + "\n")

spark.stop()
