resource "aws_sqs_queue" "Tasks" {
  name                      = "Tasks"
  visibility_timeout_seconds = 300
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.Tasks_DLQ.arn
    maxReceiveCount     = 20
  })
}

resource "aws_sqs_queue" "Tasks_DLQ" {
  name = "Tasks_DLQ"
}