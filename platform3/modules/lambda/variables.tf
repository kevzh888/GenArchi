variable "var_lambda_role_name" {
  description = "The name of the IAM role for Lambda execution."
  type        = string
}

variable "var_dynamodb_policy_name" {
  description = "The name of the IAM policy for DynamoDB access."
  type        = string
  default     = "DynamoDBAccess"
}

variable "var_dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table."
  type        = string
}

variable "var_get_quote_lambda_function_name" {
  description = "The name of the Lambda function for getting quotes."
  type        = string
}

variable "var_create_quote_lambda_function_name" {
  description = "The name of the Lambda function for creating quotes."
  type        = string
}

variable "var_runtime" {
  description = "The runtime environment for the Lambda functions (e.g., nodejs14.x)."
  type        = string
  default     = "nodejs18.x"
}

variable "var_handler" {
  description = "The handler for the Lambda functions (e.g., index.handler)."
  type        = string
  default     = "index.handler" 
}
