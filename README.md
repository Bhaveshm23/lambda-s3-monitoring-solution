# lambda-s3-monitoring-solution


**Serverless solution** that automatically processes images uploaded to S3 and provides full monitoring with CloudWatch + SNS alerts. Built with AWS Lambda, it optimizes images for storage and web use while tracking performance metrics.

## Features
- Triggers on S3 object creation events
- Uses **Pillow** to resize, compress, and generate image variants (JPEG 85%/60%, WEBP, PNG) + 300px thumbnail
- Publishes custom CloudWatch metrics (e.g., invocations, errors, duration)
- Sets up alarms for thresholds like high error rates or long processing times
- Includes a customizable CloudWatch dashboard for visualization
- Sends SNS email alerts on alarm triggers for quick notifications

## Prerequisites
- AWS account with admin rights for Lambda, S3, CloudWatch, SNS, and IAM
- Docker (for building the Pillow layer)
- Terraform (for IaC deployment)
- AWS CLI (configured with credentials)

## Deploying
```bash
git clone https://github.com/Bhaveshm23/lambda-s3-monitoring-solution.git
cd lambda-s3-monitoring-solution

# Build Pillow layer (uses Docker to package Pillow 10.4.0 for Lambda compatibility)
cd scripts && ./build_layer.sh && cd ..

# Deploy everything (builds layer, runs Terraform init/plan/apply)
./deploy.sh


## How It Works

- Upload an image to the S3 upload bucket.
- S3 event triggers the Lambda function.
- Lambda downloads the image, processes it with Pillow (validation, resize, variants), and uploads outputs to the processed bucket.
- Metrics and logs are pushed to CloudWatch.
- Alarms monitor for issues and notify via SNS if thresholds are breached.
- View real-time data on the CloudWatch dashboard.

