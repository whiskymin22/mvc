#!/bin/bash

# Expense Tracker AWS Deployment Script
# Make sure to configure AWS CLI and set these variables before running

set -e

# Configuration Variables
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="123456789012"  # Replace with your AWS Account ID
APP_NAME="expense-tracker"
ECR_REPOSITORY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}-api"
S3_BUCKET="${APP_NAME}-frontend-$(date +%s)"

echo "🚀 Starting deployment of Expense Tracker application..."

# Phase 1: Build and push Docker image
echo "📦 Building and pushing Docker image..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY
docker build -t ${APP_NAME}-api .
docker tag ${APP_NAME}-api:latest $ECR_REPOSITORY:latest
docker push $ECR_REPOSITORY:latest

# Phase 2: Update ECS service
echo "🔄 Updating ECS service..."
# Update task definition with new image
sed -i "s|123456789012|${AWS_ACCOUNT_ID}|g" task-definition.json
aws ecs register-task-definition --cli-input-json file://task-definition.json
aws ecs update-service --cluster ${APP_NAME}-cluster --service ${APP_NAME}-api-service --task-definition ${APP_NAME}-api

# Phase 3: Build and deploy frontend
echo "🎨 Building and deploying frontend..."
cd view
npm install
npm run build

# Create S3 bucket if it doesn't exist
aws s3 mb s3://$S3_BUCKET --region $AWS_REGION || true
aws s3 website s3://$S3_BUCKET --index-document index.html --error-document error.html
aws s3 sync build/ s3://$S3_BUCKET --delete

# Apply bucket policy
sed -i "s|expense-tracker-frontend-bucket|${S3_BUCKET}|g" ../s3-bucket-policy.json
aws s3api put-bucket-policy --bucket $S3_BUCKET --policy file://../s3-bucket-policy.json

cd ..

echo "✅ Deployment completed successfully!"
echo "📝 Next steps:"
echo "   1. Update your DNS records to point to the CloudFront distribution"
echo "   2. Configure SSL certificate if using custom domain"
echo "   3. Update frontend API endpoints to point to your ALB"
echo "   4. Test the application end-to-end"