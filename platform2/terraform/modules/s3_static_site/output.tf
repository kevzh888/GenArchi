output "website_endpoint" {
  description = "Domain name of the bucket endpoint"
  value       = aws_s3_bucket_website_configuration.static_site.website_endpoint
}

output "bucket_name" {
  description = "Name of the bucket"
  value       = aws_s3_bucket.static_site.id
}

output "bucket_arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.static_site.arn
}