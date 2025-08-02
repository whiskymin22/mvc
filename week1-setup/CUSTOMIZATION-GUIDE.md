# 🔧 Week 1 Scripts Customization Guide

This guide explains exactly what you need to customize in each Week 1 script before running them.

## 📋 **Prerequisites (Required Before Running Any Script)**

### 1. AWS CLI Configuration
```bash
# Configure AWS CLI with your credentials
aws configure

# You'll be prompted to enter:
# - AWS Access Key ID: [Your access key]
# - AWS Secret Access Key: [Your secret key]  
# - Default region name: [e.g., us-east-1]
# - Default output format: json

# Test your configuration
aws sts get-caller-identity
```

### 2. Install Required Tools
```bash
# Install jq for JSON parsing (Ubuntu/Debian)
sudo apt install jq

# Or on macOS
brew install jq

# Verify installation
jq --version
```

### 3. Get Your AWS Account Information
```bash
# Get your AWS Account ID (you'll need this for some configurations)
aws sts get-caller-identity --query Account --output text

# List available regions
aws ec2 describe-regions --query 'Regions[].RegionName' --output table
```

---

## 🌐 **Script 1: 01-create-network.sh**

### **Required Changes:**

#### **1. AWS Region Selection**
```bash
# Line ~25: Change to your preferred region
export AWS_REGION="us-east-1"        # 🔧 CHANGE THIS
```

**Popular Options:**
- `us-east-1` (N. Virginia) - Cheapest, most services
- `us-west-2` (Oregon) - Good for West Coast
- `eu-west-1` (Ireland) - Good for Europe
- `ap-southeast-1` (Singapore) - Good for Asia

#### **2. Application Name**
```bash
# Line ~28: Change to your preferred app name
export APP_NAME="expense-tracker"     # 🔧 CHANGE THIS
```

**Naming Rules:**
- Use lowercase letters and hyphens only
- No spaces or special characters
- Keep it short and descriptive
- Examples: `my-app`, `company-api`, `personal-blog`

### **Optional Changes:**

#### **VPC CIDR Block (Advanced)**
If you need a different IP range, modify line ~45:
```bash
# Change from 10.0.0.0/16 to your preferred range
--cidr-block 10.0.0.0/16
```

**Common CIDR Options:**
- `10.0.0.0/16` (65,536 IPs) - Default, good for most cases
- `172.16.0.0/16` (65,536 IPs) - Alternative private range
- `192.168.0.0/16` (65,536 IPs) - Traditional private range

---

## 🔒 **Script 2: 02-create-security-groups.sh**

### **Required Changes:**
**✅ NO CHANGES NEEDED** - This script automatically uses configuration from the first script.

### **What It Does Automatically:**
- Loads configuration from `network-config.env`
- Detects your public IP address for bastion host access
- Creates security groups with proper firewall rules

### **Optional Changes:**

#### **Restrict Access to Specific IPs (Advanced)**
If you want to restrict access to specific IP addresses instead of allowing from anywhere:

```bash
# Find the lines with 0.0.0.0/0 and replace with your IP
# Example: Replace 0.0.0.0/0 with 203.0.113.0/24
```

---

## 🗄️ **Script 3: 03-create-database.sh**

### **Required Changes:**
**✅ NO CHANGES NEEDED** - Default settings work for learning purposes.

### **Recommended Changes for Production:**

#### **1. Database Instance Size**
```bash
# Line ~45: Change database size based on your needs
DB_INSTANCE_CLASS="db.t3.micro"      # 🔧 CHANGE THIS
```

**Instance Options:**
- `db.t3.micro` - $12/month, 1 vCPU, 1GB RAM (good for learning)
- `db.t3.small` - $24/month, 2 vCPU, 2GB RAM (good for small apps)
- `db.t3.medium` - $48/month, 2 vCPU, 4GB RAM (good for production)

#### **2. Storage Configuration**
```bash
# Lines ~48-49: Adjust storage based on your data needs
DB_ALLOCATED_STORAGE=20               # 🔧 Initial storage (GB)
DB_MAX_ALLOCATED_STORAGE=100          # 🔧 Max auto-scaling storage (GB)
```

#### **3. Backup Retention**
```bash
# Line ~50: Change backup retention period
BACKUP_RETENTION=7                    # 🔧 Days to keep backups
```

#### **4. Multi-AZ Deployment (Cost Impact)**
```bash
# Line ~51: Set to false for single-AZ (50% cost savings)
MULTI_AZ=true                        # 🔧 Set to false for development
```

**Multi-AZ Impact:**
- `true` - High availability, automatic failover, **double the cost**
- `false` - Single availability zone, **50% cheaper**, no automatic failover

---

## 💰 **Cost Impact of Your Choices**

### **Region Selection Impact:**
| Region | Relative Cost | Notes |
|--------|---------------|-------|
| us-east-1 | Baseline (cheapest) | Most AWS services available |
| us-west-2 | +5-10% | Good performance for West Coast |
| eu-west-1 | +10-15% | Good for European users |
| ap-southeast-1 | +15-20% | Higher costs but good for Asia |

### **Database Configuration Impact:**
| Setting | Development Cost | Production Cost |
|---------|------------------|-----------------|
| db.t3.micro + Single-AZ | ~$12/month | Not recommended |
| db.t3.micro + Multi-AZ | ~$24/month | ~$24/month |
| db.t3.small + Multi-AZ | ~$48/month | ~$48/month |
| db.t3.medium + Multi-AZ | ~$96/month | ~$96/month |

---

## 🚀 **Quick Start Configurations**

### **💡 Learning/Development Setup (Cheapest)**
```bash
# 01-create-network.sh
export AWS_REGION="us-east-1"
export APP_NAME="my-expense-app"

# 03-create-database.sh  
DB_INSTANCE_CLASS="db.t3.micro"
MULTI_AZ=false                        # 50% cost savings
BACKUP_RETENTION=1                     # Minimum backups
```
**Estimated Cost: ~$35-50/month**

### **🏢 Production Setup (Recommended)**
```bash
# 01-create-network.sh
export AWS_REGION="us-east-1"         # or your preferred region
export APP_NAME="company-expense-tracker"

# 03-create-database.sh
DB_INSTANCE_CLASS="db.t3.small"       # Better performance
MULTI_AZ=true                         # High availability
BACKUP_RETENTION=7                     # 7 days of backups
```
**Estimated Cost: ~$70-100/month**

---

## 🔍 **How to Verify Your Configuration**

### **Before Running Scripts:**
```bash
# Check AWS CLI configuration
aws sts get-caller-identity
aws configure list

# Check your current region
aws configure get region

# Verify you have required permissions
aws iam get-user
```

### **After Running Each Script:**
```bash
# After script 1 - Check VPC creation
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=YOUR_APP_NAME"

# After script 2 - Check security groups
aws ec2 describe-security-groups --filters "Name=tag:Project,Values=YOUR_APP_NAME"

# After script 3 - Check RDS instance
aws rds describe-db-instances --db-instance-identifier YOUR_APP_NAME-db
```

---

## ⚠️ **Important Notes**

### **1. Naming Consistency**
- Use the same `APP_NAME` across all scripts
- AWS resources will be prefixed with this name
- Example: `expense-tracker-vpc`, `expense-tracker-db`

### **2. Region Consistency**  
- Use the same `AWS_REGION` for all resources
- Don't change regions between scripts
- All resources must be in the same region

### **3. Cost Monitoring**
```bash
# Monitor your AWS costs
aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-31 --granularity MONTHLY --metrics BlendedCost
```

### **4. Resource Cleanup**
To avoid ongoing charges, you can delete resources:
```bash
# Delete RDS instance (saves ~$25/month)
aws rds delete-db-instance --db-instance-identifier YOUR_APP_NAME-db --skip-final-snapshot

# Delete NAT Gateways (saves ~$45/month)  
aws ec2 describe-nat-gateways --filter "Name=tag:Project,Values=YOUR_APP_NAME"
aws ec2 delete-nat-gateway --nat-gateway-id nat-xxxxxxxxx
```

---

## 🆘 **Common Issues and Solutions**

### **1. "AWS CLI not configured" Error**
```bash
# Solution: Configure AWS CLI
aws configure
```

### **2. "jq: command not found" Error**
```bash
# Solution: Install jq
sudo apt install jq    # Ubuntu/Debian
brew install jq        # macOS
```

### **3. "Permission denied" Errors**
- Check your IAM user has required permissions
- Ensure AWS credentials are correct
- Try: `aws sts get-caller-identity`

### **4. "Region not supported" Errors**
- Some regions don't support all services
- Use major regions like us-east-1, us-west-2
- Check AWS service availability by region

---

## 📞 **Getting Help**

If you encounter issues:

1. **Check the script output** - Error messages usually indicate the problem
2. **Verify prerequisites** - AWS CLI, jq, permissions
3. **Check AWS Console** - Look for created resources
4. **Review CloudWatch logs** - For detailed error information
5. **Consult AWS documentation** - Service-specific guidance

**Remember: The scripts include extensive error checking and will stop if something goes wrong, so you can safely re-run them after fixing issues.**