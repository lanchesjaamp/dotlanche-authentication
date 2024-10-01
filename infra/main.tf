resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

locals {
  role        = aws_iam_role.lambda_role.arn
  memory_size = 512
  runtime     = "dotnet8"
}

resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "IamLambdaExecutionRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.lambda_role.name]
}

resource "aws_lambda_function" "getuser" {
  function_name = "dotlanches-getuser"
  handler       = "DotLancheAuthentication::DotLancheAuthentication.Functions.AuthenticationFunction::GetUser"
  role          = local.role
  memory_size   = local.memory_size
  runtime       = local.runtime
  filename      = var.zip_file
}

resource "aws_lambda_function" "signup" {
  function_name = "dotlanches-signup"
  handler       = "DotLancheAuthentication::DotLancheAuthentication.Functions.AuthenticationFunction::SignUp" #Class is build from a source generator
  role          = local.role
  memory_size   = local.memory_size
  runtime       = local.runtime
  filename      = var.zip_file
}

resource "aws_lambda_function" "signin" {
  function_name = "dotlanches-signin"
  handler       = "DotLancheAuthentication::DotLancheAuthentication.Functions.AuthenticationFunction::SignIn" #Class is build from a source generator
  role          = local.role
  memory_size   = local.memory_size
  runtime       = local.runtime
  filename      = var.zip_file
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "DotLancheApi"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "signin_lambda_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.signin_function.arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "signup_lambda_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.signup_function.arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "getuser_lambda_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.getuser_function.arn
  integration_method = "GET"
  payload_format_version = "2.0"
}

# Permissões para cada Lambda
resource "aws_lambda_permission" "signin_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeSignIn"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.signin_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "signup_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeSignUp"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.signup_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "getuser_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeGetUser"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getuser_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
