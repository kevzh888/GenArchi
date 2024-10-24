output "files_to_upload" {
 description = "List of files to upload to s3 bucket."
  value = fileset(var.var_website_assets_dir, "*")
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket"
  value       = aws_s3_bucket.website_bucket.bucket_regional_domain_name
}