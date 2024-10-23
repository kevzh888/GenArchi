resource "aws_api_gateway_rest_api" "quotes" {
  name        = "quotes"
  description = "My API Gateway"

  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "quotes"
      version = "1.0"
    }
    paths = {
      "/getQuotes" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "AWS_PROXY"
            uri                  = var.var_lambda_get_quotes_invoke_arn
          }
        }
        options = {
          x-amazon-apigateway-integration = {
            httpMethod           = "OPTIONS"
            payloadFormatVersion = "1.0"
            type                 = "MOCK"
            requestTemplates = {
              "application/json" = "{\"statusCode\": 200}"
            }
            responses = {
              default = {
                statusCode = "200"
                responseParameters = {
                  "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
                  "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
                  "method.response.header.Access-Control-Allow-Origin"  = "'*'"
                }
              }
            }
          }
          responses = {
            "200" = {
              description = "CORS support"
              headers = {
                "Access-Control-Allow-Headers" = {
                  schema = {
                    type = "string"
                  }
                }
                "Access-Control-Allow-Methods" = {
                  schema = {
                    type = "string"
                  }
                }
                "Access-Control-Allow-Origin" = {
                  schema = {
                    type = "string"
                  }
                }
              }
            }
          }
        }
      },
      "/createQuote" = {
        post = {
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            payloadFormatVersion = "1.0"
            type                 = "AWS_PROXY"
            uri                  = var.var_lambda_create_quote_invoke_arn
          }
        }
        options = {
          x-amazon-apigateway-integration = {
            httpMethod           = "OPTIONS"
            payloadFormatVersion = "1.0"
            type                 = "MOCK"
            requestTemplates = {
              "application/json" = "{\"statusCode\": 200}"
            }
            responses = {
              default = {
                statusCode = "200"
                responseParameters = {
                  "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
                  "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
                  "method.response.header.Access-Control-Allow-Origin"  = "'*'"
                }
              }
            }
          }
          responses = {
            "200" = {
              description = "CORS support"
              headers = {
                "Access-Control-Allow-Headers" = {
                  schema = {
                    type = "string"
                  }
                }
                "Access-Control-Allow-Methods" = {
                  schema = {
                    type = "string"
                  }
                }
                "Access-Control-Allow-Origin" = {
                  schema = {
                    type = "string"
                  }
                }
              }
            }
          }
        }
      }
    }
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "quotes" {
  rest_api_id = aws_api_gateway_rest_api.quotes.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.quotes.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "permissionsGet" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.var_lambda_get_quotes_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_api_gateway_rest_api.quotes.execution_arn
}

resource "aws_lambda_permission" "permissionsCreate" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.var_lambda_create_quote_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_api_gateway_rest_api.quotes.execution_arn
}

resource "aws_api_gateway_stage" "quotes" {
  deployment_id = aws_api_gateway_deployment.quotes.id
  rest_api_id   = aws_api_gateway_rest_api.quotes.id
  stage_name    = "quotes"
}

resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.quotes.id
  parent_id   = aws_api_gateway_rest_api.quotes.root_resource_id
  path_part   = "quotes"
}

resource "aws_s3_object" "api_gateway_url" {
  bucket = var.var_bucket
  key    = "api_gateway_url.txt"
  content = "https://${module.apigateway.rest_api_id}.execute-api.${var.aws_region}.amazonaws.com/$%7Bmodule.apigateway.api_stage_name%7D/"
  acl    = "public-read"
}
