variable "var_api_gateway_name" {
  description = "The name of the API Gateway."
  type        = string
  default = "quotes"
}

variable "var_lambda_get_quotes_arn" {
  description = "The ARN of the Lambda function to get a quote."
  type        = string
}

variable "var_lambda_create_quote_arn" {
  description = "The ARN of the Lambda function to create a quote."
  type        = string
}

variable "var_lambda_get_quotes_invoke_arn" {
  description = "The invoke ARN of the Lambda function to get a quote."
  type        = string
}

variable "var_lambda_create_quote_invoke_arn" {
  description = "The invoke ARN of the Lambda function to create a quote."
  type        = string
}

variable "var_bucket" {
  description = "The name of the S3 bucket."
  type        = string
  default     = "ga-s3bucket-quotes-app"
}

variable "aws_region" {
  description = "The aws region"
  type        = string
  default = "eu-west-3"
}