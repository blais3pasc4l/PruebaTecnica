resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "ecs-policy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "ecs:UpdateService"
          ],
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_lambda_function" "ecs_redeploy" {
  function_name = "ecsRedeploy"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda_function.zip"
  environment {
    variables = {
      CLUSTER_NAME = aws_ecs_cluster.ecs.name
      SERVICE_NAME = aws_ecs_service.ecs.name
    }
  }
}

resource "aws_api_gateway_rest_api" "redeploy_api" {
  name        = "redeploy-api"
  description = "API for redeploying ECS service"
}

resource "aws_api_gateway_resource" "redeploy_resource" {
  rest_api_id = aws_api_gateway_rest_api.redeploy_api.id
  parent_id   = aws_api_gateway_rest_api.redeploy_api.root_resource_id
  path_part   = "redeploy"
}

resource "aws_api_gateway_method" "post_redeploy" {
  rest_api_id   = aws_api_gateway_rest_api.redeploy_api.id
  resource_id   = aws_api_gateway_resource.redeploy_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecs_redeploy.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.redeploy_api.id
  resource_id             = aws_api_gateway_resource.redeploy_resource.id
  http_method             = aws_api_gateway_method.post_redeploy.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.ecs_redeploy.invoke_arn
}

resource "aws_api_gateway_deployment" "redeploy_api_deployment" {
  depends_on  = [aws_api_gateway_integration.lambda]
  rest_api_id = aws_api_gateway_rest_api.redeploy_api.id
  stage_name  = "prod"
}

resource "aws_api_gateway_stage" "redeploy_stage" {
  deployment_id = aws_api_gateway_deployment.redeploy_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.redeploy_api.id
  stage_name    = "prod"
}