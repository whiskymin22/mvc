# 🌐 Domain Integration Guide: caohuuminh.com

This guide explains exactly how to integrate your `caohuuminh.com` domain throughout the AWS deployment process.

## 🎯 **Domain Architecture Overview**

Your domain will be used in the following structure:

```
🌐 caohuuminh.com Domain Structure:

├── https://caohuuminh.com           → React Frontend (S3 + CloudFront)
├── https://www.caohuuminh.com       → Redirect to main domain  
├── https://api.caohuuminh.com       → Node.js API (ECS + ALB)
└── https://admin.caohuuminh.com     → Future admin panel (optional)
```

## 📅 **Integration Timeline by Week**

### **Week 1: Domain Purchase & Route 53 Setup**
- Purchase domain from registrar
- Set up Route 53 hosted zone
- Request SSL certificates
- Configure DNS

### **Week 3: Infrastructure Integration**  
- Connect domain to CloudFront (frontend)
- Connect API subdomain to Load Balancer
- Configure HTTPS redirects
- Update application configurations

### **Week 4: Production Optimization**
- Set up monitoring for domain
- Configure caching policies
- Implement security headers
- Set up domain-based analytics

---

## 🛠️ **Step-by-Step Integration Process**

### **Phase 1: Domain Purchase & Initial Setup**

#### **Step 1: Purchase Domain**
1. Go to your preferred registrar (Namecheap, GoDaddy, etc.)
2. Purchase `caohuuminh.com`
3. **Important**: Don't configure DNS yet - we'll use Route 53

#### **Step 2: Week 1 Domain Setup**
```bash
# Navigate to week1-setup directory
cd week1-setup

# Edit the domain setup script
nano 04-setup-domain.sh

# Change these lines:
DOMAIN_NAME="caohuuminh.com"          # 🔧 Your domain
EMAIL="your-email@example.com"        # 🔧 Your email

# Run the domain setup script
chmod +x 04-setup-domain.sh
./04-setup-domain.sh
```

#### **Step 3: Configure Name Servers at Registrar**
After running the script, you'll get name servers like:
```
ns-1234.awsdns-12.org
ns-5678.awsdns-34.net
ns-9012.awsdns-56.co.uk
ns-3456.awsdns-78.com
```

**Go to your domain registrar and update the name servers to these AWS ones.**

---

### **Phase 2: Terraform Deployment with Domain**

#### **Step 4: Configure Terraform for Domain**
```bash
# Navigate to deployment-scripts directory
cd deployment-scripts

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars
nano terraform.tfvars
```

**Configure these values:**
```hcl
# Basic Configuration
aws_region = "us-east-1"
app_name   = "expense-tracker"

# Domain Configuration
domain_name = "caohuuminh.com"        # 🔧 Your domain
create_domain_resources = true        # Enable domain features
```

#### **Step 5: Deploy Infrastructure with Domain**
```bash
# Initialize Terraform
terraform init

# Plan deployment (review what will be created)
terraform plan

# Deploy with domain support
terraform apply
```

**What gets created:**
- Route 53 hosted zone
- SSL certificates for all subdomains
- CloudFront distribution with custom domain
- DNS records pointing to your infrastructure

---

### **Phase 3: Application Configuration**

#### **Step 6: Update Frontend Configuration**
Your React app needs to know about the custom domain:

```javascript
// Create/update view/src/config.js
const config = {
  API_BASE_URL: process.env.NODE_ENV === 'production' 
    ? 'https://api.caohuuminh.com'
    : 'http://localhost:8080',
  
  APP_URL: process.env.NODE_ENV === 'production'
    ? 'https://caohuuminh.com'
    : 'http://localhost:3000'
};

export default config;
```

**Update your React components:**
```javascript
// Instead of hardcoded URLs, use:
import config from './config';

// API calls
const response = await fetch(`${config.API_BASE_URL}/api/expenses`);
```

#### **Step 7: Update Backend CORS**
Update your `server.js` to allow requests from your domain:

```javascript
// Update CORS configuration in server.js
app.use(cors({
  origin: [
    'https://caohuuminh.com',
    'https://www.caohuuminh.com',
    'http://localhost:3000' // for development
  ],
  credentials: true
}));
```

---

### **Phase 4: Deployment & Testing**

#### **Step 8: Deploy Updated Applications**
```bash
# Build and deploy frontend
cd view
npm run build
aws s3 sync build/ s3://your-bucket-name --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/*"

# Deploy backend (if using ECS)
# Your CI/CD pipeline will handle this, or manually:
docker build -t expense-tracker-api .
docker tag expense-tracker-api:latest YOUR_ECR_URL:latest
docker push YOUR_ECR_URL:latest
aws ecs update-service --cluster expense-tracker-cluster --service expense-tracker-api-service --force-new-deployment
```

#### **Step 9: Test Your Domain**
```bash
# Test frontend
curl -I https://caohuuminh.com
curl -I https://www.caohuuminh.com

# Test API
curl https://api.caohuuminh.com/health
curl https://api.caohuuminh.com/api/expenses

# Test SSL certificates
openssl s_client -connect caohuuminh.com:443 -servername caohuuminh.com
```

---

## 🔧 **Configuration Files Summary**

### **Files You Need to Modify:**

#### **Week 1 Setup:**
```bash
# week1-setup/04-setup-domain.sh
DOMAIN_NAME="caohuuminh.com"          # Line 23
EMAIL="your-email@example.com"        # Line 24
```

#### **Terraform Configuration:**
```bash
# deployment-scripts/terraform.tfvars
domain_name = "caohuuminh.com"
create_domain_resources = true
```

#### **Frontend Configuration:**
```javascript
// view/src/config.js
const config = {
  API_BASE_URL: 'https://api.caohuuminh.com',
  APP_URL: 'https://caohuuminh.com'
};
```

#### **Backend Configuration:**
```javascript
// server.js
app.use(cors({
  origin: [
    'https://caohuuminh.com',
    'https://www.caohuuminh.com'
  ]
}));
```

---

## 💰 **Domain-Related Costs**

### **AWS Costs (Monthly):**
- **Route 53 Hosted Zone**: $0.50/month
- **SSL Certificates**: Free (AWS Certificate Manager)
- **CloudFront**: $0.085/GB + $0.0075/10k requests
- **DNS Queries**: $0.40/million queries

### **Domain Registration:**
- **Annual Cost**: $10-15/year (varies by registrar)
- **Renewal**: Same as registration cost

### **Total Additional Cost**: ~$1-3/month for domain features

---

## ⏰ **Timeline & Dependencies**

### **Day 1: Domain Setup**
- Purchase domain ✅
- Run domain setup script ✅
- Update name servers at registrar ✅
- **Wait**: 24-48 hours for DNS propagation

### **Day 3: Infrastructure Deployment**
- Configure Terraform variables ✅
- Deploy infrastructure with domain ✅
- **Wait**: SSL certificate validation (automatic)

### **Day 5: Application Updates**
- Update frontend configuration ✅
- Update backend CORS ✅
- Deploy applications ✅
- Test all endpoints ✅

---

## 🔍 **Verification Commands**

### **DNS Verification:**
```bash
# Check DNS propagation
dig caohuuminh.com
dig api.caohuuminh.com
dig www.caohuuminh.com

# Check name servers
dig NS caohuuminh.com
```

### **SSL Certificate Verification:**
```bash
# Check certificate details
openssl s_client -connect caohuuminh.com:443 -servername caohuuminh.com < /dev/null 2>/dev/null | openssl x509 -text -noout

# Check certificate expiration
echo | openssl s_client -connect caohuuminh.com:443 2>/dev/null | openssl x509 -dates -noout
```

### **Application Testing:**
```bash
# Test frontend
curl -L https://caohuuminh.com
curl -L https://www.caohuuminh.com

# Test API endpoints
curl https://api.caohuuminh.com/health
curl https://api.caohuuminh.com/api/expenses
```

---

## 🚨 **Troubleshooting Common Issues**

### **1. DNS Not Propagating**
```bash
# Check if name servers are updated
dig NS caohuuminh.com

# Solution: Wait 24-48 hours after updating name servers
```

### **2. SSL Certificate Not Validating**
```bash
# Check certificate status
aws acm describe-certificate --certificate-arn YOUR_CERT_ARN

# Solution: Ensure DNS records are correct and wait for validation
```

### **3. CORS Errors**
```bash
# Check browser console for CORS errors
# Solution: Update backend CORS configuration with your domain
```

### **4. 404 Errors on Frontend Routes**
```bash
# Check CloudFront error pages configuration
# Solution: Ensure custom error response redirects 404 to index.html
```

---

## 📊 **Monitoring Your Domain**

### **CloudWatch Metrics:**
- CloudFront request count and data transfer
- Route 53 query count
- ALB request count for API subdomain

### **Health Checks:**
```bash
# Set up Route 53 health checks
aws route53 create-health-check --caller-reference "health-check-$(date +%s)" --health-check-config Type=HTTPS,ResourcePath=/health,FullyQualifiedDomainName=api.caohuuminh.com
```

---

## 🎉 **Final Result**

After completing all steps, you'll have:

- ✅ **https://caohuuminh.com** - Your React frontend with SSL
- ✅ **https://www.caohuuminh.com** - Redirects to main domain  
- ✅ **https://api.caohuuminh.com** - Your Node.js API with SSL
- ✅ Automatic SSL certificate renewal
- ✅ Global CDN for fast loading
- ✅ Professional custom domain
- ✅ Production-ready setup

Your expense tracker application will be accessible at your custom domain with enterprise-grade security and performance! 🚀