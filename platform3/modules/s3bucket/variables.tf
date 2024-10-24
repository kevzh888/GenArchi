variable "var_s3_bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "var_index_document_suffix" {
  description = "The suffix of the index document (e.g., 'index.html')."
  type        = string
  default     = "index.html"
}

variable "var_error_document_key" {
  description = "The key of the error document (e.g., 'error.html')."
  type        = string
  default     = "error.html"
}

variable "var_block_public_acls" {
  description = "Whether to block public ACLs on the bucket."
  type        = bool
  default     = false
}

variable "var_block_public_policy" {
  description = "Whether to block public policies on the bucket."
  type        = bool
  default     = false
}

variable "var_ignore_public_acls" {
  description = "Whether to ignore public ACLs on the bucket."
  type        = bool
  default     = false
}

variable "var_restrict_public_buckets" {
  description = "Whether to restrict public buckets."
  type        = bool
  default     = false
}

variable "var_object_ownership" {
  description = "The object ownership configuration (e.g., 'BucketOwnerPreferred')."
  type        = string
  default     = "BucketOwnerPreferred"
}

variable "var_bucket_acl" {
  description = "The ACL for the S3 bucket (e.g., 'public-read')."
  type        = string
  default     = "public-read"
}

variable "var_website_assets_dir" {
  description = "The local directory containing website assets."
  type        = string
}
