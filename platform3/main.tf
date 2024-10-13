module "s3bucket" {
  source = "./modules/s3bucket"
  var_s3_bucket_name = "ga-s3bucket-quotes-app"
  var_object_ownership = "BucketOwnerPreferred"
  var_bucket_acl = "public-read"
  var_website_assets_dir = "./assets"
}