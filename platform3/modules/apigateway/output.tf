output "api_gateway_url" {
  description = "The URL of the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.quotes.id}.execute-api.${var.aws_region}.amazonaws.com/quotes"
}