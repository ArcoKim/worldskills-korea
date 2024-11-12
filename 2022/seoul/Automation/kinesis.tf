resource "aws_kinesis_stream" "main" {
  name = "kda_flink_kinesis_stream"

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }
}

resource "aws_kinesisanalyticsv2_application" "main" {
  name                   = "example-flink-application"
  runtime_environment    = "FLINK-1_13"
  service_execution_role = aws_iam_role.flink.arn

  application_configuration {
    application_code_configuration {
      code_content {
        s3_content_location {
          bucket_arn = aws_s3_bucket.main.arn
          file_key   = aws_s3_object.flink_jar.key
        }
      }

      code_content_type = "ZIPFILE"
    }

    environment_properties {
      property_group {
        property_group_id = "FlinkAppProperties"

        property_map = {
          s3_output_path = "s3a://${aws_s3_bucket.main.bucket}/kda_flink_output"
        }
      }
    }
  }
}