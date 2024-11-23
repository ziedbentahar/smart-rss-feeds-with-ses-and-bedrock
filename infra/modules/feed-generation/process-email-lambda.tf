locals {
  model_id = "anthropic.claude-3-sonnet-20240229-v1:0"
}


resource "aws_iam_role" "process_email_lambda" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}



resource "aws_iam_policy" "process_email_lambda" {
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
        Resource = ["arn:aws:logs:*:*:*"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          var.bucket.arn,
          "${var.bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",

        ]
        Resource = [
          "arn:aws:bedrock:${data.aws_region.current.id}::foundation-model/${local.model_id}",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
        ]
        Resource = [
          var.newsletter_feeds_table.arn,
          var.shorted_links_table.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:Query",
        ]
        Resource = [
          var.feed_config_table.arn,
          "${var.feed_config_table.arn}/index/*",
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "process_email_lambda" {
  role       = aws_iam_role.process_email_lambda.name
  policy_arn = aws_iam_policy.process_email_lambda.arn
}

data "archive_file" "process_email_lambda" {
  type        = "zip"
  source_dir  = var.process_email_lambda.dist_dir
  output_path = "${path.root}/.terraform/tmp/lambda-dist-zips/${var.process_email_lambda.name}.zip"
}

resource "aws_lambda_function" "process_email_lambda" {
  function_name    = "${var.application}-${var.environment}-${var.process_email_lambda.name}"
  filename         = data.archive_file.process_email_lambda.output_path
  role             = aws_iam_role.process_email_lambda.arn
  handler          = var.process_email_lambda.handler
  source_code_hash = filebase64sha256("${data.archive_file.process_email_lambda.output_path}")
  runtime          = "nodejs20.x"
  memory_size      = "512"

  timeout = 5 * 60

  architectures = ["arm64"]

  logging_config {
    system_log_level      = "INFO"
    application_log_level = "INFO"
    log_format            = "JSON"
  }

  environment {
    variables = {
      FEEDS_TABLE_NAME           = var.newsletter_feeds_table.name
      SHORTENED_LINKS_TABLE_NAME = var.shorted_links_table.name
      FEED_CONFIG_TABLE_NAME     = var.feed_config_table.name
      SENDER_EMAIL_GSI           = var.feed_config_table.sender_email_gsi

      TRANSFORMED_EMAILS_BUCKET = var.bucket.id
      EMAILS_BUCKET             = var.bucket.id

      MODEL_ID = local.model_id
    }
  }

}

resource "aws_cloudwatch_log_group" "process_email_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.process_email_lambda.function_name}"
  retention_in_days = "3"
}
