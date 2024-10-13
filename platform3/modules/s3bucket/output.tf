output "files_to_upload" {
 description = "List of files to upload to s3 bucket."
  value = fileset(var.var_website_assets_dir, "*")
}