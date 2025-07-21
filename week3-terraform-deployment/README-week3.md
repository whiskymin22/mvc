# Week 3: Terraform Infrastructure Deployment & Application Setup

**Goal**: Deploy production infrastructure with Terraform and set up containerized applications.

## 📅 **Daily Schedule**

### **Day 15-16: Production Infrastructure with Terraform**
**Time**: 4-5 hours  
**Difficulty**: Intermediate to Advanced

#### **Learning Objectives:**
- Deploy production-ready infrastructure with Terraform
- Understand infrastructure migration strategies
- Learn about Terraform import
- Implement infrastructure monitoring

#### **Tasks:**
1. **Clean Migration Strategy** (60 minutes)
   ```bash
   # Option 1: New region deployment
   cd deployment-scripts
   terraform init
   terraform plan -var="aws_region=us-west-2"
   terraform apply
   
   # Option 2: Import existing resources (advanced)
   terraform import aws_vpc.main vpc-xxxxxxxxx
   ```

2. **Deploy Complete Infrastructure** (2-3 hours)
   - Use the provided infrastructure.tf
   - Configure variables properly
   - Deploy in stages (networking → security → database)
   - Validate each component

3. **Infrastructure Testing** (90 minutes)
   - Test network connectivity
   - Verify security groups
   - Test database connectivity
   - Validate resource tagging

#### **Key Terraform Commands:**
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Show current state
terraform show

# List resources
terraform state list

# Destroy resources (when needed)
terraform destroy
```

---

### **Day 17: Container Setup & ECR**
**Time**: 3-4 hours  
**Difficulty**: Intermediate

#### **Learning Objectives:**
- Learn Docker containerization
- Understand Amazon ECR (Elastic Container Registry)
- Build and push Docker images
- Understand container security

#### **Tasks:**
1. **Review Application Code** (30 minutes)
   - Understand the Node.js application structure
   - Review Dockerfile
   - Understand container requirements

2. **Set up ECR Repository** (30 minutes)
   ```bash
   # ECR repository should be created by Terraform
   # Get ECR login token
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
   ```

3. **Build and Push Container** (90 minutes)
   ```bash
   # Build Docker image
   docker build -t expense-tracker-api .
   
   # Tag for ECR
   docker tag expense-tracker-api:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/expense-tracker-api:latest
   
   # Push to ECR
   docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/expense-tracker-api:latest
   ```

4. **Container Testing** (60 minutes)
   - Test container locally
   - Verify environment variables
   - Test health endpoints

#### **Docker Best Practices:**
- Use multi-stage builds
- Minimize image size
- Use non-root users
- Implement health checks
- Scan for vulnerabilities

---

### **Day 18-19: ECS Fargate Deployment**
**Time**: 4-5 hours  
**Difficulty**: Advanced

#### **Learning Objectives:**
- Understand ECS (Elastic Container Service)
- Learn about Fargate serverless containers
- Configure task definitions
- Set up load balancing

#### **Tasks:**
1. **ECS Concepts Study** (60 minutes)
   - Learn ECS vs EKS vs EC2
   - Understand clusters, services, and tasks
   - Study Fargate vs EC2 launch types

2. **Create ECS Resources** (2 hours)
   ```bash
   # Create ECS cluster (if not created by Terraform)
   aws ecs create-cluster --cluster-name expense-tracker-cluster
   
   # Register task definition
   aws ecs register-task-definition --cli-input-json file://task-definition.json
   
   # Create service
   aws ecs create-service --cluster expense-tracker-cluster --service-name expense-tracker-api-service --task-definition expense-tracker-api:1 --desired-count 2
   ```

3. **Configure Load Balancer** (90 minutes)
   - Create Application Load Balancer (ALB)
   - Configure target groups
   - Set up health checks
   - Configure listeners

4. **Service Testing** (60 minutes)
   - Test service deployment
   - Verify auto-scaling
   - Test load balancer health checks

#### **ECS Service Configuration:**
```json
{
  "serviceName": "expense-tracker-api-service",
  "cluster": "expense-tracker-cluster",
  "taskDefinition": "expense-tracker-api",
  "desiredCount": 2,
  "launchType": "FARGATE",
  "networkConfiguration": {
    "awsvpcConfiguration": {
      "subnets": ["subnet-xxx", "subnet-yyy"],
      "securityGroups": ["sg-xxx"],
      "assignPublicIp": "DISABLED"
    }
  }
}
```

---

### **Day 20-21: Frontend Deployment & Integration**
**Time**: 3-4 hours  
**Difficulty**: Intermediate

#### **Learning Objectives:**
- Deploy React frontend to S3
- Configure CloudFront distribution
- Integrate frontend with backend API
- Implement CORS configuration

#### **Tasks:**
1. **Frontend Build Process** (60 minutes)
   ```bash
   cd view
   npm install
   npm run build
   ```

2. **S3 Static Website Hosting** (90 minutes)
   ```bash
   # Create S3 bucket (if not created by Terraform)
   aws s3 mb s3://expense-tracker-frontend-unique-name
   
   # Enable static website hosting
   aws s3 website s3://expense-tracker-frontend-unique-name --index-document index.html
   
   # Upload files
   aws s3 sync build/ s3://expense-tracker-frontend-unique-name --delete
   ```

3. **CloudFront Configuration** (90 minutes)
   - Create CloudFront distribution
   - Configure caching behavior
   - Set up custom error pages
   - Configure SSL/TLS

4. **API Integration** (60 minutes)
   - Update frontend API endpoints
   - Configure CORS on backend
   - Test end-to-end functionality

#### **Frontend Configuration:**
```javascript
// Update API base URL in React app
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://your-alb-dns-name';

// Example API call
const fetchExpenses = async () => {
  const response = await fetch(`${API_BASE_URL}/api/expenses`);
  return response.json();
};
```

---

## 📊 **Week 3 Progress Tracking**

### **Daily Checklist:**

#### **Day 15-16: Terraform Infrastructure ✅**
- [ ] Production infrastructure deployed with Terraform
- [ ] All resources properly tagged
- [ ] Infrastructure testing completed
- [ ] State management configured

#### **Day 17: Container Setup ✅**
- [ ] Docker image built successfully
- [ ] ECR repository configured
- [ ] Container pushed to ECR
- [ ] Container security scanned

#### **Day 18-19: ECS Deployment ✅**
- [ ] ECS cluster created
- [ ] Task definition registered
- [ ] ECS service running
- [ ] Load balancer configured
- [ ] Health checks passing

#### **Day 20-21: Frontend Deployment ✅**
- [ ] React app built and deployed
- [ ] S3 static hosting configured
- [ ] CloudFront distribution created
- [ ] API integration working
- [ ] End-to-end testing completed

## 🎯 **Week 3 Architecture Validation**

### **Infrastructure Checklist:**
```bash
# Verify VPC and networking
terraform output vpc_id
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_id)

# Check RDS instance
terraform output rds_endpoint
aws rds describe-db-instances --db-instance-identifier expense-tracker-db

# Verify ECS service
aws ecs describe-services --cluster expense-tracker-cluster --services expense-tracker-api-service

# Test ALB health
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw target_group_arn)

# Check S3 website
curl -I http://$(terraform output -raw s3_website_endpoint)
```

### **Application Testing:**
```bash
# Test API endpoints
curl http://$(terraform output -raw alb_dns_name)/health
curl http://$(terraform output -raw alb_dns_name)/api/expenses

# Test frontend
curl -I http://$(terraform output -raw s3_website_endpoint)
```

## 🔧 **Week 3 Troubleshooting Guide**

### **Common Issues:**

1. **Terraform State Conflicts**
   ```bash
   # Check state
   terraform state list
   
   # Remove conflicting resources
   terraform state rm aws_vpc.main
   
   # Import existing resources
   terraform import aws_vpc.main vpc-xxxxxxxxx
   ```

2. **ECS Task Not Starting**
   ```bash
   # Check service events
   aws ecs describe-services --cluster expense-tracker-cluster --services expense-tracker-api-service
   
   # Check task logs
   aws logs tail /ecs/expense-tracker-api --follow
   ```

3. **Load Balancer Health Check Failures**
   ```bash
   # Check target health
   aws elbv2 describe-target-health --target-group-arn <target-group-arn>
   
   # Check security groups
   aws ec2 describe-security-groups --group-ids <security-group-id>
   ```

4. **Frontend API Connection Issues**
   - Verify CORS configuration
   - Check API endpoint URLs
   - Validate security group rules

## 💰 **Week 3 Cost Analysis**

### **New Resources Added:**
- **ECR Repository**: ~$0.10/GB/month
- **ECS Fargate Tasks**: ~$15-30/month (2 tasks)
- **Application Load Balancer**: ~$16-20/month
- **CloudFront Distribution**: ~$1-5/month
- **Data Transfer**: Variable

**Total Week 3 Addition**: ~$32-55/month

### **Cost Optimization Tips:**
- Use spot instances for development
- Implement auto-scaling policies
- Optimize container resource allocation
- Use CloudFront caching effectively

## 📚 **Week 3 Learning Resources**

### **AWS Services:**
- [ECS User Guide](https://docs.aws.amazon.com/ecs/latest/userguide/)
- [ECR User Guide](https://docs.aws.amazon.com/ecr/latest/userguide/)
- [CloudFront Developer Guide](https://docs.aws.amazon.com/cloudfront/latest/developerguide/)

### **Container Best Practices:**
- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [AWS Container Security](https://aws.amazon.com/container-security/)

## 🎉 **Week 3 Completion**

**Infrastructure Deployed:**
- ✅ Complete AWS infrastructure via Terraform
- ✅ Containerized Node.js API on ECS Fargate
- ✅ React frontend on S3 + CloudFront
- ✅ PostgreSQL database with secure access
- ✅ Load balancing and auto-scaling
- ✅ Monitoring and logging setup

**Skills Mastered:**
- ✅ Production Terraform deployment
- ✅ Container orchestration with ECS
- ✅ Load balancer configuration
- ✅ Static website hosting
- ✅ Full-stack application deployment

**Next Week Preview**: You'll implement CI/CD pipelines, monitoring, and production optimizations.