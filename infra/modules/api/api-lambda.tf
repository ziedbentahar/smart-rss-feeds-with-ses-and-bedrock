
resource "aws_iam_role" "api_lambda" {
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



resource "aws_iam_policy" "api_lambda" {
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
          "dynamodb:Query",
        ]
        Resource = [
          var.newsletter_feeds_table.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          var.emails_bucket.arn,
          "${var.emails_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
        ]
        Resource = [
          var.shorted_links_table.arn
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_lambda" {
  role       = aws_iam_role.api_lambda.name
  policy_arn = aws_iam_policy.api_lambda.arn
}

data "archive_file" "api_lambda" {
  type        = "zip"
  source_dir  = var.api_lambda.dist_dir
  output_path = "${path.root}/.terraform/tmp/lambda-dist-zips/${var.api_lambda.name}.zip"
}

resource "aws_lambda_function" "api_lambda" {
  function_name    = "${var.application}-${var.environment}-${var.api_lambda.name}"
  filename         = data.archive_file.api_lambda.output_path
  role             = aws_iam_role.api_lambda.arn
  handler          = var.api_lambda.handler
  source_code_hash = filebase64sha256("${data.archive_file.api_lambda.output_path}")
  runtime          = "nodejs20.x"
  memory_size      = "512"



  timeout = 3 * 60

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
      EMAILS_BUCKET              = var.emails_bucket.id
      API_HOST                   = local.api_subdomain
    }
  }

}

resource "aws_cloudwatch_log_group" "api_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.api_lambda.function_name}"
  retention_in_days = "3"
}


resource "aws_lambda_function_url" "api" {
  function_name      = aws_lambda_function.api_lambda.function_name
  authorization_type = "AWS_IAM"
}
