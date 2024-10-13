# DynamoDB table for quotes

resource "aws_dynamodb_table" "quote_table" {
  name         = var.var_dynamodb_table_name
  billing_mode = var.var_billing_mode
  hash_key     = var.var_hash_key
    
  attribute {
    name = "quote_id"
    type = "S"
  }

  stream_enabled   = var.var_stream_enabled
  stream_view_type = var.var_stream_view_type
}
