
resource "aws_iam_role" "state_machine" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "states.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "state_machine" {
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
          "lambda:InvokeFunction",
        ]
        Resource = [
          aws_lambda_function.process_email_lambda.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "state_machine" {
  role       = aws_iam_role.state_machine.name
  policy_arn = aws_iam_policy.state_machine.arn
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  role_arn = aws_iam_role.state_machine.arn

  definition = templatefile("${path.module}/state.json", {
    ProcessEmail : aws_lambda_function.process_email_lambda.arn
  })
}
