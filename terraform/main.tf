# File: main.tf

#---------------------------------
# Terraform And Providers
#-----------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
  required_version = ">= 1.2"
}

provider "aws" {
  region = "us-east-1"
}

# ----------------------------------
# 0. Random suffix for unique names
# ----------------------------------
resource "random_id" "suffix" {
  byte_length = 2
}

/*
# -----------------------
# Block 1. S3 Bucket
# -----------------------
# Comment this out if deploying later
resource "aws_s3_bucket" "site" {
  bucket        = "iusb-site-${random_id.suffix.hex}"
  force_destroy = true
  tags = {
    Name = "iusb-static-site"
  }
}


resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.site.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "site_config" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

 */

/*
# -----------------------
# Block 2a. Upload website static files
# -----------------------
resource "aws_s3_bucket_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  source       = "${var.website_folder}/index.html"
  content_type = "text/html; charset=utf-8"
}

resource "aws_s3_bucket_object" "register" {
  bucket       = aws_s3_bucket.site.id
  key          = "register.html"
  source       = "${var.website_folder}/register.html"
  content_type = "text/html; charset=utf-8"
}

resource "aws_s3_bucket_object" "about" {
  bucket       = aws_s3_bucket.site.id
  key          = "about.html"
  source       = "${var.website_folder}/about.html"
  content_type = "text/html; charset=utf-8"
}

resource "aws_s3_bucket_object" "contact" {
  bucket       = aws_s3_bucket.site.id
  key          = "contact.html"
  source       = "${var.website_folder}/contact.html"
  content_type = "text/html; charset=utf-8"
}

resource "aws_s3_bucket_object" "style" {
  bucket       = aws_s3_bucket.site.id
  key          = "style.css"
  source       = "${var.website_folder}/style.css"
  content_type = "text/css"
}

 */

/*
# -----------------------
# Block 2b. Upload app.js
# Comment out until API Gateway deployed
# -----------------------
resource "aws_s3_bucket_object" "appjs" {
  bucket       = aws_s3_bucket.site.id
  key          = "app.js"
  source       = "${var.website_folder}/app.js"
  etag         = filemd5("${var.website_folder}/app.js")
  content_type = "application/javascript"
}

 */

/*
# -----------------------
# 3. DynamoDB: users
# -----------------------
resource "aws_dynamodb_table" "users" {
  name         = "iusb-users-${random_id.suffix.hex}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"

  attribute {
    name = "email"
    type = "S"
  }
}

# -----------------------
# 4. DynamoDB: counters
# -----------------------
resource "aws_dynamodb_table" "counters" {
  name         = "iusb-counters-${random_id.suffix.hex}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

 */

/*
# -----------------------
# Block 5. IAM Role for Lambda
# -----------------------
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "iusb-lambda-role-${random_id.suffix.hex}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions   = ["dynamodb:*", "logs:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name   = "iusb-lambda-policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

 */

/*
# -----------------------
# Block 6. Lambda Function
# -----------------------
resource "aws_lambda_function" "registration" {
  filename         = var.lambda_zip_file
  function_name    = "iusb-registration-${random_id.suffix.hex}"
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = filebase64sha256(var.lambda_zip_file)

  # Pass DynamoDB table names as environment variables
  environment {
    variables = {
      USERS_TABLE    = aws_dynamodb_table.users.name
      COUNTERS_TABLE = aws_dynamodb_table.counters.name
    }
  }

  # Ensure tables exist before Lambda is created
  depends_on = [
    aws_dynamodb_table.users,
    aws_dynamodb_table.counters
  ]
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGWInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.registration.function_name
  principal     = "apigateway.amazonaws.com"
}

 */

/*
# -----------------------
# Block 7. API Gateway
# Comment out until ready
# -----------------------
resource "aws_apigatewayv2_api" "http_api" {
  name          = "iusb-http-api-${random_id.suffix.hex}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.registration.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "register_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /register"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}
resource "aws_apigatewayv2_route" "counter_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /counter"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

 */

/*
# -----------------------
# 8. Generate app.js locally
# Comment out until API Gateway deployed
# -----------------------

resource "local_file" "appjs" {
  filename = "${var.website_folder}/app.js"
  content  = templatefile("${var.website_folder}/app.template.js", {
    API_URL = try(aws_apigatewayv2_stage.default.invoke_url, "")
  })
  depends_on = [aws_apigatewayv2_api.http_api]
}

 */




# IU-International University of Applied Sciences
# Course Code: DLBSEPCP01_E
# Author: Gabriel Manu
# Matriculation ID: 9212512