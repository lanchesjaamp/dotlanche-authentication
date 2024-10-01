variable "lambda_function_name" {
  type    = string
  default = "DotLancheAuthenticationFunction"
}

variable "lambda_role_name" {
  type    = string
  default = "dotlanche-lambda-execution-role"
}

variable "zip_file" {
  description = "path to functions zip file"
  type        = string
}