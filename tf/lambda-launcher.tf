resource "aws_lambda_function" "Launcher" {
  filename         = data.archive_file.dummy.output_path
  function_name    = "Launcher"
  description      = "lists s3 prefix content and pushes it to sqs"
  role             = aws_iam_role.lambda_role.arn
  handler          = "Launcher.lambda_handler"
  source_code_hash = data.archive_file.dummy.output_base64sha256
  runtime          = "python3.8"
  timeout          = 900
  memory_size      = 512
  
  # set terraform ingnore changes in lambda files
  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash
    ]
  }

  environment {
    variables = {
      SQS_QUEUE_URL      = aws_sqs_queue.Tasks.id,
      SQS_QUEUE_NAME     = aws_sqs_queue.Tasks.name,
      DESTINATION_PREFIX = var.destination_prefix
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_Launcher" {
  name              = "/aws/lambda/Launcher"
  retention_in_days = 30
}

resource "aws_lambda_permission" "Launcher" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.Launcher.arn
  principal     = "s3.amazonaws.com"
  #source_account= var.aws_account_id 
}

resource "aws_lambda_function_event_invoke_config" "Launcher" {
  function_name                = aws_lambda_function.Launcher.function_name
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0
}

resource "aws_s3_bucket_notification" "Launcher" {
  bucket = aws_s3_bucket.hpdp_lambda_data.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.Launcher.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = var.kicker_file_name
  }
}


