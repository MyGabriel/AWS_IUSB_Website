**DISCLAIMER:** _IUSB is not affiliated with the International University of Applied Sciences (IU), Germany._

# Hosting International University of Applied Sciences Students Bank (IUSB) Website on AWS

## Project Overview
This project implements the hosting of the International University of Applied Sciences
Students Bank (IUSB) webpage on Amazon Web Services (AWS) using Infrastructure as Code (IaC) 
principles. The architecture is designed to satisfy the following requirements:
● High availability, suitable for a banking application.
● Low-latency access for users distributed globally.
● Automatic backend scaling to accommodate fluctuating traffic demand.

## AWS Services Used
Amazon S3 Bucket – Static content storage
Amazon API Gateway (Edge-Optimized) – Global API access
AWS Lambda – Serverless backend computation
Amazon DynamoDB – highly available NoSQL data storage

**Note:** _Edge-optimized API Gateway endpoints automatically use an AWS-managed Amazon
CloudFront distribution to provide global edge access. CloudFront is not explicitly
configured in this project._

## Architectural Objectives and Justification

## High Availability
High availability is achieved through the use of fully managed AWS services that are
designed to operate across multiple Availability Zones.

#### Amazon S3 Bucket
● Stores static HTML and CSS assets.
● Provides 11 nines (99.999999999%) durability.
● Automatically replicates data across Availability Zones (AZ).

#### Amazon API Gateway
● Fully AWS-managed service and a multi-AZ service.
● Eliminates single points of failure.
● Benefits from AWS-managed CloudFront for edge resilience.

#### AWS Lambda
● Executes across multiple Availability Zones by default.
● Removes dependency on server provisioning and maintenance.

#### Amazon DynamoDB
● Fully managed, multi-AZ and fault-tolerant.
● Data is synchronously replicated across Availability Zones.

#### Outcome:
The application remains available despite infrastructure or data-center-level failures,
meeting reliability expectations for financial systems.

## Low Latency for Global Users
Low latency is achieved by combining AWS’s global network with edge-optimized request routing.

#### Static Content (Amazon S3)
● Serves static files from a regional endpoint over AWS’s global backbone
● Suitable for consistent and reliable content delivery

#### Backend API (Amazon API Gateway – Edge-Optimized)
● Automatically uses AWS-managed CloudFront
● Routes requests to the nearest AWS edge location
● Minimizes round-trip time for geographically distributed users

#### Compute and Data Access
● AWS Lambda executes backend logic without startup delays
● Amazon DynamoDB provides single-digit millisecond response times
● DynamoDB Global Tables may be used for further global optimization if required

#### Outcome:
Users experience fast and consistent backend responses regardless of geographic location.

## Automatic Scaling
The system is designed to scale automatically without manual intervention.

#### Amazon S3
● Supports virtually unlimited concurrent requests
● Requires no capacity planning

#### Amazon API Gateway
● Automatically scales to handle high request volumes
● Edge distribution absorbs traffic spikes efficiently

#### AWS Lambda
● Automatically increases concurrent executions as demand grows
● Scales down during periods of low traffic

#### Amazon DynamoDB
● Uses on-demand or auto-scaling capacity modes
● Adjusts throughput dynamically based on workload

#### Outcome:
The backend remains responsive during traffic surges, such as peak banking hours or 
promotional events.

## STEP-BY-STEP DEPLOYMENT
**Note:** The Terraform syntax for the project is specifically for deployment in PyCharm 
using the _**-target**_ method.

### STEP 0 — Set The Environment

**Prepare the Lambda zip**
Open PowerShell in the lambda folder (or the project folder, use "cd lambda"):
Then run:

    cd lambda
    npm init -y
    npm install

#### Outcome:
_"npm install"_ will generate _"node_modules"_ directory and _"package-lock.json"_ file in the
"lambda" directory.

The following code generates a _"lambda_function.zip"_ in the root folder to assist Lambda deployment.
    
    Compress-Archive -Path * -DestinationPath ../lambda_function.zip

#### Outcome:
The code will generate _"lambda_function.zip"_ in the main directory (IUCloudProject_IUBS).

**Initialize Terraform**

    cd ..     
    cd terraform
    terraform init

### STEP 1 — Create S3 Bucket: Block 1

#### Purpose:
The S3 bucket holds the website's files.

**Deployment Guide:**
● In the main.tf: Block 1 is to be uncommented, and Blocks 2 to 8 commented out.
● In the outputs.tf: Block 1 is to be uncommented, and Blocks 2 and 3 commented out.
● Then run the following code one after the other:

    terraform apply "-target=aws_s3_bucket.site"
    terraform apply "-target=aws_s3_bucket_public_access_block.public_access"
    terraform apply "-target=aws_s3_bucket_policy.public_policy"
    terraform apply "-target=aws_s3_bucket_website_configuration.site_config"

#### Outcome:
The S3 Bucket is created; confirm in the AWS Console that the S3 console shows the bucket.

### STEP 2 — Upload static website files: Block 2a

#### Purpose:
These blocks deploy the IUSB website's HTML and CSS files.
The static HTML and CSS files will be in S3; however, the API and Lambda are not ready.

**Deployment Guide:**
● In the main.tf:
    Block 2a is to be uncommented now while keeping Block 1 also uncommented.
    Keep Blocks 2b to 8 commented out.
    Wait until the API is deployed before uncommenting Block 2b.
● In the outputs.tf: Block 1 is to be uncommented while Blocks 2 and 3 are commented out.
● Then run the following code one after the other:

    terraform apply "-target=aws_s3_bucket_object.index"
    terraform apply "-target=aws_s3_bucket_object.register"
    terraform apply "-target=aws_s3_bucket_object.about"
    terraform apply "-target=aws_s3_bucket_object.contact"
    terraform apply "-target=aws_s3_bucket_object.style"

#### Outcome:
Now the HTML and CSS files have been uploaded. Test by opening the S3 website endpoint; index.html should load.

### STEP 3 — Deploy DynamoDB Tables: Block 3

#### Purpose:
DynamoDB is required for backend storage.
Block 3 is the users table, and Block 4 is the counters table.

**Deployment Guide:**
● In the main.tf:
    Uncomment Blocks 3 and Block 4. 
    Keep Blocks 1 to 2a uncommented.
    Keep Block 2b and Blocks 5 to 8 commented out.
● In the outputs.tf: Uncommented Block 3 while keeping Blocks 1 uncommented, but Block 2 commented out.
● Now run the following Terraform code one after the other:

    terraform apply "-target=aws_dynamodb_table.users"
    terraform apply "-target=aws_dynamodb_table.counters"

#### Outcome:
DynamoDB tables, users, and counters are created. Check the DynamoDB console.

### STEP 4 — Create IAM Role for Lambda: Block 5

#### Purpose:
Lambda needs an IAM role (plus policy) with DynamoDB and CloudWatch permissions.

**Deployment Guide:**
● In the main.tf:
    Uncomment block 5.
    Keep Blocks 1 to 4 uncommented, except Block 2b.
    Keep Blocks 6 to 8 commented out. 
● In the outputs.tf: Keep Block 1 and Blocks 3 uncommented, but Block 2 commented-out.
● Run the following Terraform code one after the other:

    terraform apply "-target=aws_iam_role.lambda_role"
    terraform apply "-target=aws_iam_role_policy.lambda_role_policy"

#### Outcome:
IAM role is created. Check the AWS IAM console.

### STEP 5 — Deploy Lambda Function: Block 6

#### Purpose:
Backend for registration and visitors counter.

**Deployment Guide:**
● In the main.tf:
    Uncomment Block 6.
    Keep blocks 1 to 5 uncommented, except Block 2b.
    Keep Blocks 7 to 8 commented out.
● In the outputs.tf: Keep Block 1 and Blocks 3 uncommented, but Block 2 commented out.
● Run the following Terraform code one after the other:

    terraform apply "-target=aws_lambda_function.registration"
    terraform apply "-target=aws_lambda_permission.allow_apigw"

#### Outcome:
Lambda is deployed. Check the AWS Lambda console.

### STEP 6 — Deploy API Gateway: Block 7

#### Purpose: 
Exposes the Lambda via HTTP endpoints.

**Note:** The next step should be implemented once Lambda is ready.

**Deployment Guide:**
● In the main.tf):  
    Uncomment block 7 (API Gateway and Routes)
    Keep blocks 1 to 6 uncommented, except Block 2b
    Keep Block 8 commented out.
● In the outputs.tf: Uncomment the API outputs (Block 2).
● Then run the following Terraform code one after the other:

    terraform apply "-target=aws_apigatewayv2_api.http_api"
    terraform apply "-target=aws_apigatewayv2_integration.lambda_integration"
    terraform apply "-target=aws_apigatewayv2_route.register_route"
    terraform apply "-target=aws_apigatewayv2_route.counter_route"
    terraform apply "-target=aws_apigatewayv2_stage.default"

#### Outcome:
API Gateway is deployed. Terraform output will show api_url.

### STEP 7 — Generate app.js with API URL: Block 8

#### Purpose:
Inject real API URL (local_file app.js) into JS for the frontend.

**Deployment Guide:**
● In the main.tf
    Uncomment block 8.
    Keep Blocks 1 to 7 uncommented, except Block 2b.
● Then run the following Terraform code:

    terraform apply "-target=local_file.appjs"

#### Outcome:
The website app.js is generated with an API URL.

#### STREP 8 The Last Deployment**

#### Purpose: 
Upload app.js to S3.

**Deployment Guide:**
● In the main.tf:
    Uncomment Block 2b now
    Keep Blocks 1 to 7 uncommented.
● Then run the following Terraform code:

    terraform apply "-target=aws_s3_bucket_object.appjs"

#### Outcome:
The IUSB website is now fully functional, such that
1. HTML and CSS are from the S3 Bucket.
2. JS calls Lambda via API Gateway.
3. Registration and the visitors counter should work now.

#### Access the Website

**S3 website URL:**
http://<your-bucket-name>.s3-website-us-east-1.amazonaws.com

**Registration page:**
http://<your-bucket-name>.s3-website-us-east-1.amazonaws.com/register.html

**Note:** JS automatically calls the API Gateway endpoints. Do not access API Gateway root URL directly.




**DISCLAIMER:** _IUSB is not affiliated with the International University of Applied Sciences (IU), Germany._

############ THE END  #############
