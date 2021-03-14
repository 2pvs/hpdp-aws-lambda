resource "aws_cloudwatch_event_rule" "queue_empty" {
  name        = "queue_empty"
  description = "triggers on empty queue cloudwatch alarm"

  event_pattern = <<EOF
{
  "source": [
    "aws.cloudwatch"
  ],
  "detail-type": [
    "CloudWatch Alarm State Change"
  ]
}
EOF
}

resource "aws_cloudwatch_event_target" "lambda_Reducer" {
  rule      = aws_cloudwatch_event_rule.queue_empty.name
  target_id = aws_lambda_function.Reducer.function_name
  arn       = aws_lambda_function.Reducer.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_call_Reducer" {
    statement_id  = "AllowExecutionFromCloudWatch"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.Reducer.arn
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.queue_empty.arn
}