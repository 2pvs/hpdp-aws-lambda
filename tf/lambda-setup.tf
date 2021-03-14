data "aws_iam_policy_document" "lambda_assume_policy" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

data "archive_file" "dummy" {
  type        = "zip"
  output_path = "dummy-zip/lambda_function_payload.zip"

  source {
    content  = "hello"
    filename = "dummy.txt"
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect    = "Allow"
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "s3:*"
    ]    
    resources = [
      aws_s3_bucket.hpdp_lambda_data.arn,
      "${aws_s3_bucket.hpdp_lambda_data.arn}/*"
    ]
  }

  statement {
    effect  = "Allow"
    actions = [
      "sns:*",
      "sqs:*",
      "cloudwatch:*",
      "logs:*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

resource "aws_iam_role_policy" "lambda_policy" {
  role   = aws_iam_role.lambda_role.name
  policy = data.aws_iam_policy_document.lambda_policy.json
}
