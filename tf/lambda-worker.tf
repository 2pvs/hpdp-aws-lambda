resource "aws_lambda_function" "Worker" {
  filename         = data.archive_file.dummy.output_path
  function_name    = "Worker"
  description      = "converts tiff files to jpeg"
  role             = aws_iam_role.lambda_role.arn
  handler          = "Worker.lambda_handler"
  source_code_hash = data.archive_file.dummy.output_base64sha256
  runtime          = "python3.8"
  timeout          = 120
  memory_size      = 512
  #reserved_concurrent_executions = 100

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

resource "aws_cloudwatch_log_group" "lambda_Worker" {
  name              = "/aws/lambda/Worker"
  retention_in_days = 30
}

resource "aws_lambda_event_source_mapping" "Worker" {
  event_source_arn = aws_sqs_queue.Tasks.arn
  enabled          = true
  function_name    = aws_lambda_function.Worker.function_name
  batch_size       = 10
}