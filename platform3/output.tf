output "bucket_url" {
  description = "URL of the s3 bucket."
  value       = module.s3bucket.bucket_regional_domain_name
}

output "get_quotes_lambda_invoke_arn" {
  description = "The invoke ARN of the Lambda function to get a quote."
  value       = module.lambda.get_quotes_lambda_invoke_arn
}

output "create_quote_lambda_invoke_arn" {
  description = "The invoke ARN of the Lambda function to create a quote."
  value       = module.lambda.create_quote_lambda_invoke_arn
}