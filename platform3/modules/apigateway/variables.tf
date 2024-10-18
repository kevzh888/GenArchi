variable "var_api_gateway_name" {
  description = "The name of the API Gateway."
  type        = string
  default = "quotes"
}

variable "var_lambda_get_quote_arn" {
  description = "The ARN of the Lambda function to get a quote."
  type        = string
}

variable "var_lambda_create_quote_arn" {
  description = "The ARN of the Lambda function to create a quote."
  type        = string
}
