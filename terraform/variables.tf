# File: variables.tf

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "website_folder" {
  description = "Path to website files"
  type        = string
  default     = "../website"
}

variable "lambda_zip_file" {
  description = "Path to Lambda zip file"
  type        = string
  default     = "../lambda_function.zip"
}



# IU-International University of Applied Sciences
# Course Code: DLBSEPCP01_E
# Author: Gabriel Manu
# Matriculation ID: 9212512