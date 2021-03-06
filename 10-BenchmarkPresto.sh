# Run all TPCDS queries on Presto
# Query presto for runtimes after you are done
# Run this on the dataproc cluster master
set -e 

# Create external tables references the data in gs://fivetran-benchmark that we generated with the big cluster
echo 'Create tables'
hive -f ParquetDdl.sql

# Read all tables to warm up google cloud storage
echo 'Warmup.sql...'
while read line;
do
  echo "$line"
  presto --catalog=hive --schema=tpcds_parquet --execute "$line" > /dev/null
done < Warmup.sql

# Run each query
for f in query/*.sql; 
do
  echo "$f"
  presto --catalog=hive --schema tpcds_parquet -f $f > /dev/null
done

presto --catalog=hive --schema tpcds_parquet -f PrestoTiming.sql