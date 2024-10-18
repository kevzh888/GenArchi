output "get_quotes_lambda_arn" {
  value = aws_lambda_function.get_quote_lambda.arn
}

output "create_quote_lambda_arn" {
  value = aws_lambda_function.create_quote_lambda.arn
}