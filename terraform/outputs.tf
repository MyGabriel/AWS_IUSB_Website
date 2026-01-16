# File: main.tf

/*
# -----------------------
# Block 1: S3 Website URL
# -----------------------
output "site_url" {
  value       = try(aws_s3_bucket.site.website_endpoint, "S3 Bucket not deployed yet")
  description = "URL of the S3 static website"
}

 */

/*
# -----------------------
# Block 2: API Gateway URL
# Comment out until API Gateway is deployed
# -----------------------
output "api_url" {
  value       = try(aws_apigatewayv2_stage.default.invoke_url, "API Gateway not deployed yet")
  description = "Invoke URL for HTTP API Gateway"
}

 */

/*
# -----------------------
# Block 3: DynamoDB Tables
# -----------------------
output "users_table" {
  value       = try(aws_dynamodb_table.users.name, "DynamoDB users table not deployed yet")
  description = "Users table name"
}

output "counters_table" {
  value       = try(aws_dynamodb_table.counters.name, "DynamoDB counters table not deployed yet")
  description = "Counters table name"
}

 */



# IU-International University of Applied Sciences
# Course Code: DLBSEPCP01_E
# Author: Gabriel Manu
# Matriculation ID: 9212512