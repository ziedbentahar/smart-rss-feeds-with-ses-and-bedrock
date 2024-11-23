
resource "aws_cloudwatch_event_target" "this" {
  rule     = var.bucket_events_rule.name
  arn      = aws_sfn_state_machine.sfn_state_machine.arn
  role_arn = aws_iam_role.this.arn

  dead_letter_config {
    arn = aws_sqs_queue.this.arn
  }
}

resource "aws_iam_role" "this" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "MyEventRuleTargetPolicy" {
  name = "s3-eventbridge-sfn-tf-EventRolePolicy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "states:StartExecution",
          "Resource" : aws_sfn_state_machine.sfn_state_machine.arn
          "Effect" : "Allow"
        }
      ]
    }
  )
  role = aws_iam_role.this.name
}

resource "aws_sqs_queue" "this" {
  name = "${var.application}-${var.environment}-inbox-dlq"
}

resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": "sqs:*",
      "Resource": "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_sqs_queue.this.name}",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Sid": "AllowEventRuleS3EventBridgeSfnStackStackpatternEventsRule",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_sqs_queue.this.name}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${var.bucket_events_rule.arn}"
        }
      }
    }
  ]
}
POLICY
}
