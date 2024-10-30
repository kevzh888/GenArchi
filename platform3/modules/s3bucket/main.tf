# Purpose: Create an S3 bucket to host a static website

# Create an S3 bucket
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.var_s3_bucket_name
}

# Set the object ownership configuration for the S3 bucket
resource "aws_s3_bucket_ownership_controls" "website_bucket_ownership_controls" {
  bucket = aws_s3_bucket.website_bucket.id
  rule {
    object_ownership = var.var_object_ownership
  }
}

# Allow public access to the bucket  
resource "aws_s3_bucket_public_access_block" "website_bucket_public_access_block" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = var.var_block_public_acls
  block_public_policy     = var.var_block_public_policy
  ignore_public_acls      = var.var_ignore_public_acls
  restrict_public_buckets = var.var_restrict_public_buckets
}

# Set the ACL for the S3 bucket
resource "aws_s3_bucket_acl" "website_bucket_acl" {
  depends_on = [
    aws_s3_bucket_public_access_block.website_bucket_public_access_block,
    aws_s3_bucket_ownership_controls.website_bucket_ownership_controls,
  ]

  bucket = aws_s3_bucket.website_bucket.id
  acl    = var.var_bucket_acl
}

resource "aws_s3_bucket_cors_configuration" "website_bucket_cors" {
  bucket = aws_s3_bucket.website_bucket.id

  cors_rule {
    allowed_methods = [
      "GET",
      "POST",
      "PUT",
      "DELETE",
      "HEAD",
    ]
    allowed_origins = [
      "*",
      "",
    ]
    allowed_headers = [
      "",
    ]
    expose_headers = [
      "ETag",
      "x-amz-request-id",
    ]

    max_age_seconds = 3000  # Optional: cache preflight response for this long
  }
}

# Configure the S3 bucket to host a static website
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = var.var_index_document_suffix
  }

  error_document {
    key = var.var_error_document_key
  }
}

<<<<<<< HEAD
resource "aws_s3_bucket_cors_configuration" "website_bucket_cors" {
  bucket = aws_s3_bucket.website_bucket.id

  cors_rule {
    allowed_methods = [
      "GET",
      "POST",
      "PUT",
      "DELETE",
      "HEAD",
    ]

    allowed_origins = [
      "https://your-allowed-origin.com", # Replace with your origin
      "*",  # Use '*' to allow all origins (not recommended for production)
    ]

    allowed_headers = [
      "*",  # Use '*' to allow all headers
    ]

    expose_headers = [
      "ETag",
      "x-amz-request-id",
    ]

    max_age_seconds = 3000  # Optional: cache preflight response for this long
  }
}




=======
>>>>>>> f604fb4f3f09639da0edf6e663cd11de6cefd1b8
resource "aws_s3_bucket_policy" "allow_public_access" {
   depends_on = [
    aws_s3_bucket_public_access_block.website_bucket_public_access_block,
    aws_s3_bucket_ownership_controls.website_bucket_ownership_controls,
  ]
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      },
    ]
  })
}

# Set up the S3 bucket to host a static website
resource "aws_s3_object" "website_bucket_s3_object" {
  for_each = fileset(var.var_website_assets_dir, "*")
  bucket   = aws_s3_bucket.website_bucket.id
  key      = each.value
  source    = "${var.var_website_assets_dir}/${each.value}"
  etag      = filemd5("${var.var_website_assets_dir}/${each.value}")
  content_type = "text/html"
}
