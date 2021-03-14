resource "aws_lambda_function" "Reducer" {
  filename         = data.archive_file.dummy.output_path
  function_name    = "Reducer"
  description      = "validates tiff files and moves it to archive and to vendor"
  role             = aws_iam_role.lambda_role.arn
  handler          = "Reducer.lambda_handler"
  source_code_hash = data.archive_file.dummy.output_base64sha256
  runtime          = "python3.8"
  timeout          = 600
  memory_size      = 512

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash
    ]
  }

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.Tasks.id,
      SQS_QUEUE_NAME = aws_sqs_queue.Tasks.name,
      DESTINATION_PREFIX = var.destination_prefix
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_Reducer" {
  name              = "/aws/lambda/Reducer"
  retention_in_days = 30
}
