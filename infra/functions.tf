locals {
  role        = var.functions_role
  memory_size = 512
  runtime     = "dotnet8"
  envs = {
    "COGNITO_USER_POOL"    = aws_cognito_user_pool.users-pool.id
    "COGNITO_CLIENTID"     = aws_cognito_user_pool_client.users-client.id
    "COGNITO_CLIENTSECRET" = aws_cognito_user_pool_client.users-client.client_secret
    "ANONYMOUS_USERNAME"   = aws_cognito_user.anonymous-user.username
    "ANONYMOUS_PASSWORD"   = aws_cognito_user.anonymous-user.password
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

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
}

resource "aws_lambda_function" "getuser" {
  function_name = "dotlanches-getuser"
  handler       = "DotlancheAuthentication::DotlancheAuthentication.Functions_GetUser_Generated::GetUser" #Class is build from a source generator
  role          = aws_iam_role.lambda_role.name
  memory_size   = local.memory_size
  runtime       = local.runtime
  filename      = var.zip_file
  environment {
    variables = local.envs
  }
}

resource "aws_lambda_function" "signup" {
  function_name = "dotlanches-signup"
  handler       = "DotlancheAuthentication::DotlancheAuthentication.Functions_SignUp_Generated::SignUp" #Class is build from a source generator
  role          = aws_iam_role.lambda_role.name
  memory_size   = local.memory_size
  runtime       = local.runtime
  filename      = var.zip_file
  environment {
    variables = local.envs
  }
}

resource "aws_lambda_function" "signin" {
  function_name = "dotlanches-signin"
  handler       = "DotlancheAuthentication::DotlancheAuthentication.Functions_SignIn_Generated::SignIn" #Class is build from a source generator
  role          = aws_iam_role.lambda_role.name
  memory_size   = local.memory_size
  runtime       = local.runtime
  filename      = var.zip_file
  environment {
    variables = local.envs
  }
}
