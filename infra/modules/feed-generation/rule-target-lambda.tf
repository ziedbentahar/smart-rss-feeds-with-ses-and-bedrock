resource "aws_cloudwatch_event_rule" "this" {
  event_pattern = jsonencode({
    "detail-type" : ["Object Created"],
    "source" : ["aws.s3"],
    "detail" : {
      "bucket" : {
        "name" : ["${var.bucket.id}"]
      },
      "object" : {
        "key" : [{
          "prefix" : "inbox/"
        }]
      }
    }
  })
}

resource "aws_sqs_queue" "dlq" {
  name = "${var.application}-${var.environment}-dlq"
}

resource "aws_lambda_permission" "allow_eventbridge_invoke" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_email_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}

resource "aws_iam_role" "eb_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "eb_policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
        ]
        Resource = [aws_lambda_function.process_email_lambda.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
        ]
        Resource = [aws_sqs_queue.dlq.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eb_role_attachment" {
  role       = aws_iam_role.eb_role.name
  policy_arn = aws_iam_policy.eb_policy.arn
}



resource "aws_cloudwatch_event_target" "transcription_success" {
  rule      = aws_cloudwatch_event_rule.this.name
  target_id = "${var.application}-${var.environment}-process-email"
  arn       = aws_lambda_function.process_email_lambda.arn
  dead_letter_config {
    arn = aws_sqs_queue.dlq.arn
  }

  retry_policy {
    maximum_event_age_in_seconds = 60 * 60
    maximum_retry_attempts       = 10
  }


}



