# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "wsc2025-masking-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "wsc2025-masking-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.sensitive.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.sensitive.arn
      }
    ]
  })
}

# Archive Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/masking.py"
  output_path = "${path.module}/lambda/masking.zip"
}

# Lambda function
resource "aws_lambda_function" "masking" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "wsc2025-masking-start"
  role             = aws_iam_role.lambda_role.arn
  handler          = "masking.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.12"
  timeout          = 300
  memory_size      = 256
}

# S3 bucket notification permission for Lambda
resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.masking.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.sensitive.arn
}

# S3 bucket notification to trigger Lambda
resource "aws_s3_bucket_notification" "incoming_notification" {
  bucket = aws_s3_bucket.sensitive.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.masking.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "incoming/"
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}
