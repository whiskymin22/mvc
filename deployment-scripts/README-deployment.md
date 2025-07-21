# Expense Tracker - AWS Deployment Guide

This guide provides comprehensive instructions for deploying the Expense Tracker full-stack application on AWS Cloud.

## Architecture Overview

The application consists of:
- **Frontend**: React.js application hosted on S3 + CloudFront
- **Backend**: Node.js Express API running on ECS Fargate
- **Database**: PostgreSQL on RDS with Multi-AZ deployment
- **Load Balancer**: Application Load Balancer for high availability
- **Container Registry**: Amazon ECR for Docker images

## Prerequisites

### Required Tools
- AWS CLI v2 installed and configured
- Docker installed and running
- Node.js 18+ and npm
- Terraform (optional, for Infrastructure as Code)
- PostgreSQL client (for database initialization)

### AWS Account Setup
1. Create an AWS account if you don't have one
2. Create an IAM user with the following policies:
   - `AmazonECS_FullAccess`
   - `AmazonRDS_FullAccess`
   - `AmazonS3_FullAccess`
   - `AmazonEC2_FullAccess`
   - `AmazonVPC_FullAccess`
   - `CloudFrontFullAccess`
   - `AmazonSSMFullAccess`
   - `IAMFullAccess`

3. Configure AWS CLI:
```bash
aws configure
# Enter your Access Key ID, Secret Access Key, Region (us-east-1), and output format (json)
```

## Deployment Options

### Option 1: Automated Deployment with Terraform (Recommended)

#### Step 1: Deploy Infrastructure
```bash
cd deployment-scripts
terraform init
terraform plan
terraform apply -auto-approve
```

#### Step 2: Build and Deploy Application
```bash
# Make the deployment script executable
chmod +x deploy.sh

# Update the script with your AWS Account ID
sed -i 's/123456789012/YOUR_AWS_ACCOUNT_ID/g' deploy.sh

# Run deployment
./deploy.sh
```

#### Step 3: Create ECS Task Definition and Service
```bash
# Update task definition with correct ARNs from Terraform output
terraform output

# Create ECS task definition
aws ecs register-task-definition --cli-input-json file://task-definition.json

# Create ECS service (replace with actual subnet and security group IDs)
aws ecs create-service \
    --cluster expense-tracker-cluster \
    --service-name expense-tracker-api-service \
    --task-definition expense-tracker-api:1 \
    --desired-count 2 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[SUBNET_ID_1,SUBNET_ID_2],securityGroups=[SECURITY_GROUP_ID],assignPublicIp=DISABLED}" \
    --load-balancers targetGroupArn=TARGET_GROUP_ARN,containerName=expense-tracker-api,containerPort=8080
```

### Option 2: Manual Deployment

Follow the detailed step-by-step guide in the main README above.

## Post-Deployment Configuration

### 1. Initialize Database Schema
```bash
# Connect to RDS instance
psql -h YOUR_RDS_ENDPOINT -U dbadmin -d expenses

# Run schema creation
CREATE TABLE expenses(
    expense_id SERIAL PRIMARY KEY,
    title VARCHAR(30) NOT NULL, 
    price DECIMAL(10, 2) NOT NULL, 
    category VARCHAR(30) NOT NULL, 
    essential BOOLEAN NOT NULL, 
    created_at TIMESTAMPTZ NOT NULL
);
```

### 2. Update Frontend API Configuration
Update your React app to point to the correct API endpoint:

```javascript
// In your React app, update the API base URL
const API_BASE_URL = 'http://YOUR_ALB_DNS_NAME';
```

### 3. Configure CORS (if needed)
Update your backend CORS configuration to allow your frontend domain:

```javascript
app.use(cors({
  origin: ['http://YOUR_CLOUDFRONT_DOMAIN', 'https://YOUR_CUSTOM_DOMAIN'],
  credentials: true
}));
```

## SSL/TLS Configuration (Optional)

### For Custom Domain:
1. Request SSL certificate in ACM
2. Create Route 53 hosted zone
3. Update CloudFront distribution with custom domain and SSL certificate
4. Update ALB listener to redirect HTTP to HTTPS

## Monitoring and Logging

### CloudWatch Dashboards
The deployment includes CloudWatch monitoring for:
- ECS service CPU and memory utilization
- RDS performance metrics
- ALB request metrics
- Application logs

### Log Access
```bash
# View ECS logs
aws logs tail /ecs/expense-tracker-api --follow

# View RDS logs
aws rds describe-db-log-files --db-instance-identifier expense-tracker-db
```

## Scaling Configuration

### Auto Scaling
Configure ECS service auto-scaling:
```bash
aws application-autoscaling register-scalable-target \
    --service-namespace ecs \
    --scalable-dimension ecs:service:DesiredCount \
    --resource-id service/expense-tracker-cluster/expense-tracker-api-service \
    --min-capacity 1 \
    --max-capacity 10
```

## Cost Optimization

### Development Environment
- Use `t3.micro` instances for RDS
- Set ECS desired count to 1
- Use single AZ deployment

### Production Environment
- Use Multi-AZ RDS deployment
- Configure auto-scaling for ECS
- Use CloudFront for global content delivery

## Troubleshooting

### Common Issues

1. **ECS Tasks Not Starting**
   - Check security groups allow traffic on port 8080
   - Verify IAM roles have correct permissions
   - Check CloudWatch logs for container errors

2. **Database Connection Issues**
   - Verify security groups allow PostgreSQL traffic (port 5432)
   - Check database credentials in Parameter Store
   - Ensure ECS tasks are in the correct subnets

3. **Frontend Not Loading**
   - Verify S3 bucket policy allows public read access
   - Check CloudFront distribution status
   - Ensure API endpoints are correctly configured

### Health Checks
```bash
# Check ECS service health
aws ecs describe-services --cluster expense-tracker-cluster --services expense-tracker-api-service

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn YOUR_TARGET_GROUP_ARN

# Test API endpoint
curl http://YOUR_ALB_DNS_NAME/health
```

## Cleanup

### Terraform Cleanup
```bash
terraform destroy -auto-approve
```

### Manual Cleanup
1. Delete ECS service and cluster
2. Delete RDS instance
3. Delete Load Balancer and Target Groups
4. Delete S3 bucket contents and bucket
5. Delete CloudFront distribution
6. Delete VPC and associated resources

## Security Best Practices

1. **Database Security**
   - Use strong passwords
   - Enable encryption at rest
   - Use Parameter Store for secrets

2. **Network Security**
   - Use private subnets for database and ECS tasks
   - Configure security groups with least privilege
   - Enable VPC Flow Logs

3. **Application Security**
   - Use HTTPS in production
   - Implement proper authentication
   - Regularly update dependencies

## Support

For issues and questions:
1. Check CloudWatch logs for detailed error information
2. Review AWS service limits and quotas
3. Consult AWS documentation for service-specific issues

## Cost Estimation

### Monthly Cost Breakdown (us-east-1):
- **ECS Fargate**: ~$15-30 (2 tasks, 0.25 vCPU, 0.5GB RAM)
- **RDS t3.micro**: ~$12-25 (Multi-AZ adds cost)
- **Application Load Balancer**: ~$16-20
- **S3 + CloudFront**: ~$1-5 (depending on usage)
- **Data Transfer**: Variable based on usage

**Total Estimated Cost**: $44-80/month

*Note: Costs may vary based on usage patterns, data transfer, and AWS region.*