output "bucket_url" {
  description = "URL of the s3 bucket."
  value       = module.s3bucket.bucket_regional_domain_name
}