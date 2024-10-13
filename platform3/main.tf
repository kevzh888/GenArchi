# S3 bucket
module "s3bucket" {
  source = "./modules/s3bucket"
  var_s3_bucket_name = "ga-s3bucket-quotes-app"
  var_object_ownership = "BucketOwnerPreferred"
  var_bucket_acl = "public-read"
  var_website_assets_dir = "./assets"
}

# DynamoDB table
module "dynamodb" {
  source = "./modules/dynamodb"
  var_dynamodb_table_name = "QuotesTable"
}

# Lambda functions
module "lambda" {
  source = "./modules/lambda"
  var_dynamodb_table_arn = module.dynamodb.dynamodb_table_arn
  var_get_quote_lambda_function_name = "getQuote-function"
  var_create_quote_lambda_function_name = "createQuote-function"
  var_lambda_role_name = "lambda-execution-role"
}