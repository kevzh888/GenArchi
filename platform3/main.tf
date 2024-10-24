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
  var_get_quote_lambda_function_name = "getQuotes"
  var_create_quote_lambda_function_name = "createQuote"
  var_lambda_role_name = "lambda-execution-role"
}

# API Gateway
module "apigateway" {
  depends_on = [ module.lambda, module.s3bucket ]
  source = "./modules/apigateway"

  var_lambda_get_quotes_arn = module.lambda.get_quotes_lambda_arn
  var_lambda_create_quote_arn = module.lambda.create_quote_lambda_arn
  var_lambda_get_quotes_invoke_arn = module.lambda.get_quotes_lambda_invoke_arn
  var_lambda_create_quote_invoke_arn = module.lambda.create_quote_lambda_invoke_arn
}
