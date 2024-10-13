# Create two lambda functions to get and create quotes

data "archive_file" "get_quote_zip" {
  type        = "zip"
  source_file = "${path.module}/functions/getQuote/index.mjs"
  output_path = "${path.module}/functions/getQuote.zip"
}

data "archive_file" "create_quote_zip" {
  type        = "zip"
  source_file = "${path.module}/functions/createQuote/index.mjs"
  output_path = "${path.module}/functions/createQuote.zip"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = var.var_lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "dynamodb_access" {
  name = var.var_dynamodb_policy_name
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:Query"],
        Effect   = "Allow",
        Resource = var.var_dynamodb_table_arn
      }
    ]
  })
}

# Get quote Lambda function
resource "aws_lambda_function" "get_quote_lambda" {
  filename         = data.archive_file.get_quote_zip.output_path
  function_name    = var.var_get_quote_lambda_function_name
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = var.var_handler
  runtime          = var.var_runtime
  source_code_hash = data.archive_file.get_quote_zip.output_base64sha256
}

# Create quote Lambda function
resource "aws_lambda_function" "create_quote_lambda" {
  filename         = data.archive_file.create_quote_zip.output_path
  function_name    = var.var_create_quote_lambda_function_name
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = var.var_handler
  runtime          = var.var_runtime
  source_code_hash = data.archive_file.create_quote_zip.output_base64sha256
}
