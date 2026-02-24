# lambda-s3-monitoring-solution

Serverless solution that processes images uploaded to S3 with monitoring via CloudWatch and notifications via SNS. Uses AWS Lambda to optimize images for storage and web use.

## Features
- Triggers on S3 object creation
- Processes images with Pillow (resize, compress, variants)
- Publishes custom CloudWatch metrics (invocations, errors, duration)
- Sets up CloudWatch alarms for error rates and processing times
- Includes CloudWatch dashboard
- SNS email alerts on alarm triggers

## Prerequisites
- AWS account with admin access for Lambda, S3, CloudWatch, SNS, IAM
- Docker (for building Pillow Lambda layer)
- Terraform (for infrastructure)
- AWS CLI (configured)

## Deployment

```bash
git clone https://github.com/Bhaveshm23/lambda-s3-monitoring-solution.git
cd lambda-s3-monitoring-solution

cd scripts && ./build_layer.sh && cd ..
./deploy.sh
```

## How it works

1. Upload an image to the S3 bucket
2. S3 event triggers the Lambda function
3. Lambda validates, resizes, and creates image variants using Pillow, then uploads to the processed bucket
4. Metrics and logs are sent to CloudWatch
5. CloudWatch alarms notify via SNS if thresholds are breached
6. Monitor via the CloudWatch dashboard