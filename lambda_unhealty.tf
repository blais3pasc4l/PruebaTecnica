resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:*",
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*",
      },
      {
        Action = [
          "ecs:DescribeServices",
          "ecs:StopTask",
          "ecs:UpdateService",
        ],
        Effect   = "Allow",
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "ecs_task_handler" {
  function_name    = "ECSUnhealthyTaskHandler"
  handler          = "lambda_function.check_and_handle_task"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_execution_role.arn
  filename         = "lambda_unhealty.zip"

  environment {
    variables = {
      CLUSTER_NAME = aws_ecs_cluster.ecs.name
      SERVICE_NAME = aws_ecs_service.ecs.name
    }
  }
}


resource "aws_cloudwatch_metric_alarm" "ecs_cpu_alarm" {
  alarm_name          = "ECSHighCPUUsageAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm when CPU exceeds 80% for ECS tasks"
  dimensions = {
    ClusterName = aws_ecs_cluster.ecs.name
    ServiceName = aws_ecs_service.ecs.name
  }

  alarm_actions = [aws_lambda_function.ecs_task_handler.arn]
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_alarm" {
  alarm_name          = "ECSHighMemoryUsageAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm when Memory exceeds 80% for ECS tasks"
  dimensions = {
    ClusterName = aws_ecs_cluster.ecs.name
    ServiceName = aws_ecs_service.ecs.name
  }

  alarm_actions = [aws_lambda_function.ecs_task_handler.arn]
}