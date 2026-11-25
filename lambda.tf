resource "aws_lambda_function" "bigpanda_lambda" {
  count = var.daily_event_rule ? 1 : 0
  function_name    = "BigPanda-CloudWatch-AddTopic"
  # Source of truth: CloudwatchBigpandaAddTopic.js in bigpandaio/int-cloudwatch.
  # The zip holds only that file, at the root (nodejs24.x provides the AWS SDK). Rebuild from
  # an int-cloudwatch checkout: zip -X <this repo>/CloudwatchBigpandaAddTopic.zip CloudwatchBigpandaAddTopic.js
  # Committed rather than archive_file: a plan-time build is missing on split plan/apply pipelines.
  filename         = "${path.module}/CloudwatchBigpandaAddTopic.zip"
  source_code_hash = filebase64sha256("${path.module}/CloudwatchBigpandaAddTopic.zip")

  # "handler" is the name of the property under which the handler function was
  # exported in the attached zip file.
  handler     = "CloudwatchBigpandaAddTopic.handler"
  runtime     = "nodejs24.x"
  timeout     = 900
  memory_size = 256
  role        = local.bigpanda_role_arn

  environment {
    variables = {
      TOPICARN = aws_sns_topic.sns_topic.arn
    }
  }
}

resource "aws_lambda_permission" "bigpanda_event_rule_to_invoke_lambda" {
  count = var.daily_event_rule ? 1 : 0
  statement_id  = "AllowLambdaInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bigpanda_lambda[0].function_name
  principal     = "events.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway
  source_arn = local.bigpanda_daily_rule_arn
}
