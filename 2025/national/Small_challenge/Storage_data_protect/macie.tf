# Enable Macie
resource "aws_macie2_account" "main" {}

# Custom Data Identifiers

# Names: Various formats - must end with letters followed by newline (not *****)
resource "aws_macie2_custom_data_identifier" "names" {
  name                   = "wsc2025-names"
  description            = "Detect full names"
  regex                  = "[A-Z][a-z.]+ [A-Z][a-z.]+ [A-Z][a-z.]+ [A-Z][a-z.]+"
  maximum_match_distance = 50

  depends_on = [aws_macie2_account.main]
}

# Emails: standard email format - excludes masked emails with asterisks
resource "aws_macie2_custom_data_identifier" "emails" {
  name                   = "wsc2025-emails"
  description            = "Detect email addresses"
  regex                  = "[a-zA-Z0-9._%+-]{2,}@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"
  maximum_match_distance = 50

  depends_on = [aws_macie2_account.main]
}

# Korean phone numbers: 010-XXXX-XXXX format (preceded by space/newline/start, not part of credit card)
resource "aws_macie2_custom_data_identifier" "phones" {
  name                   = "wsc2025-phones"
  description            = "Detect Korean phone numbers (010-XXXX-XXXX)"
  regex                  = "(^|\\s)010-[0-9]{4}-[0-9]{4}"
  maximum_match_distance = 50

  depends_on = [aws_macie2_account.main]
}

# SSN: XXX-XX-XXXX format (all digits, no asterisks)
resource "aws_macie2_custom_data_identifier" "ssns" {
  name                   = "wsc2025-ssns"
  description            = "Detect SSN format (XXX-XX-XXXX)"
  regex                  = "[0-9]{3}-[0-9]{2}-[0-9]{4}"
  maximum_match_distance = 50

  depends_on = [aws_macie2_account.main]
}

# Credit card numbers: XXXX-XXXX-XXXX-XXXX format (preceded by start/space, ends at line end)
resource "aws_macie2_custom_data_identifier" "credit_cards" {
  name                   = "wsc2025-credit-cards"
  description            = "Detect credit card numbers (XXXX-XXXX-XXXX-XXXX)"
  regex                  = "(^|\\s)[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}"
  maximum_match_distance = 50

  depends_on = [aws_macie2_account.main]
}

# UUIDs: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx format (must contain at least one a-f letter)
resource "aws_macie2_custom_data_identifier" "uuids" {
  name                   = "wsc2025-uuids"
  description            = "Detect UUIDs"
  regex                  = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
  maximum_match_distance = 50

  depends_on = [aws_macie2_account.main]
}

# Create Macie classification job with custom identifiers
resource "aws_macie2_classification_job" "sensor_job" {
  name     = "wsc2025-sensor-job2"
  job_type = "ONE_TIME"

  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [aws_s3_bucket.sensitive.id]
    }

    scoping {
      includes {
        and {
          simple_scope_term {
            comparator = "STARTS_WITH"
            key        = "OBJECT_KEY"
            values     = ["masked/"]
          }
        }
      }
    }
  }

  custom_data_identifier_ids = [
    aws_macie2_custom_data_identifier.names.id,
    aws_macie2_custom_data_identifier.emails.id,
    aws_macie2_custom_data_identifier.phones.id,
    aws_macie2_custom_data_identifier.ssns.id,
    aws_macie2_custom_data_identifier.credit_cards.id,
    aws_macie2_custom_data_identifier.uuids.id
  ]

  depends_on = [
    aws_macie2_account.main,
    aws_s3_bucket.sensitive,
    aws_macie2_custom_data_identifier.names,
    aws_macie2_custom_data_identifier.emails,
    aws_macie2_custom_data_identifier.phones,
    aws_macie2_custom_data_identifier.ssns,
    aws_macie2_custom_data_identifier.credit_cards,
    aws_macie2_custom_data_identifier.uuids
  ]
}

# Get current account ID
data "aws_caller_identity" "current" {}

# Output
output "s3_bucket_name" {
  value = aws_s3_bucket.sensitive.id
}

output "lambda_function_name" {
  value = aws_lambda_function.masking.function_name
}

output "macie_job_id" {
  value = aws_macie2_classification_job.sensor_job.id
}