import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue import DynamicFrame

def sparkSqlQuery(glueContext, query, mapping, transformation_ctx) -> DynamicFrame:
    for alias, frame in mapping.items():
        frame.toDF().createOrReplaceTempView(alias)
    result = spark.sql(query)
    return DynamicFrame.fromDF(result, glueContext, transformation_ctx)
args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Script generated for node AWS Glue Data Catalog
AWSGlueDataCatalog_node1731569779658 = glueContext.create_dynamic_frame.from_catalog(database="wsi-glue-database", table_name="raw", transformation_ctx="AWSGlueDataCatalog_node1731569779658")

# Script generated for node AWS Glue Data Catalog
AWSGlueDataCatalog_node1731569828123 = glueContext.create_dynamic_frame.from_catalog(database="wsi-glue-database", table_name="ref", transformation_ctx="AWSGlueDataCatalog_node1731569828123")

# Script generated for node SQL Query
SqlQuery0 = '''
SELECT raw.title_id, ref.title, raw.uuid, raw.device_ts, raw.device_id, raw.device_type
FROM raw, ref
WHERE raw.title_id = ref.title_id;
'''
SQLQuery_node1731570016620 = sparkSqlQuery(glueContext, query = SqlQuery0, mapping = {"raw":AWSGlueDataCatalog_node1731569779658, "ref":AWSGlueDataCatalog_node1731569828123}, transformation_ctx = "SQLQuery_node1731570016620")

# Script generated for node Amazon S3
AmazonS3_node1731570147456 = glueContext.getSink(path="s3://wsi-107-arco-etl/result/", connection_type="s3", updateBehavior="LOG", partitionKeys=[], enableUpdateCatalog=True, transformation_ctx="AmazonS3_node1731570147456")
AmazonS3_node1731570147456.setCatalogInfo(catalogDatabase="wsi-glue-database",catalogTableName="result")
AmazonS3_node1731570147456.setFormat("json")
AmazonS3_node1731570147456.writeFrame(SQLQuery_node1731570016620)
job.commit()