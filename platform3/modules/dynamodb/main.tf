# DynamoDB table for quotes

resource "aws_dynamodb_table" "quote_table" {
  name         = var.var_dynamodb_table_name
  billing_mode = var.var_billing_mode
  read_capacity  = 20
  write_capacity = 20
  hash_key     = "quote_id"
    
  attribute {
    name = "quote_id"
    type = "S"
  }

  stream_enabled   = var.var_stream_enabled
  stream_view_type = var.var_stream_view_type
}
