# 🚀 Week 1 Scripts - Quick Reference

## ⚡ **TL;DR - What You Need to Change**

### **Before You Start:**
```bash
# 1. Configure AWS CLI
aws configure

# 2. Install jq
sudo apt install jq  # Ubuntu/Debian
brew install jq      # macOS
```

### **Script Customizations:**

#### **📄 01-create-network.sh**
```bash
# Lines 25-28: REQUIRED CHANGES
export AWS_REGION="us-east-1"        # 🔧 Your AWS region
export APP_NAME="expense-tracker"    # 🔧 Your app name
```

#### **📄 02-create-security-groups.sh**
```bash
# ✅ NO CHANGES NEEDED - Uses config from script 1
```

#### **📄 03-create-database.sh**
```bash
# Lines 45-51: OPTIONAL CHANGES (defaults work fine)
DB_INSTANCE_CLASS="db.t3.micro"      # Database size
DB_ALLOCATED_STORAGE=20               # Storage in GB
BACKUP_RETENTION=7                    # Backup days
MULTI_AZ=true                        # High availability (costs 2x)
```

---

## 🏃‍♂️ **Quick Start Commands**

```bash
# 1. Navigate to week1-setup directory
cd week1-setup

# 2. Read the customization guide (optional)
cat CUSTOMIZATION-GUIDE.md

# 3. Edit the first script with your preferences
nano 01-create-network.sh
# Change AWS_REGION and APP_NAME

# 4. Run the scripts in order
chmod +x *.sh
./01-create-network.sh
./02-create-security-groups.sh  
./03-create-database.sh
```

---

## 💰 **Cost Quick Reference**

| Configuration | Monthly Cost | Use Case |
|---------------|-------------|----------|
| **Learning Setup** | $35-50 | Learning AWS, single-AZ |
| **Development** | $50-70 | Small projects, Multi-AZ |
| **Production** | $70-100+ | Production apps, optimized |

### **Cost Factors:**
- **NAT Gateways**: $22-45/month (biggest cost)
- **RDS Multi-AZ**: Doubles database cost
- **Region**: us-east-1 is cheapest

---

## 🔧 **Common Customizations**

### **Cheapest Setup (Learning):**
```bash
# 01-create-network.sh
export AWS_REGION="us-east-1"
export APP_NAME="learning-app"

# 03-create-database.sh
DB_INSTANCE_CLASS="db.t3.micro"
MULTI_AZ=false                       # 50% savings
```

### **Production Setup:**
```bash
# 01-create-network.sh
export AWS_REGION="us-east-1"        # or your region
export APP_NAME="company-expense-api"

# 03-create-database.sh  
DB_INSTANCE_CLASS="db.t3.small"      # Better performance
MULTI_AZ=true                        # High availability
```

---

## 🌍 **Popular AWS Regions**

| Region Code | Location | Notes |
|------------|----------|--------|
| `us-east-1` | N. Virginia | Cheapest, most services |
| `us-west-2` | Oregon | Good for West Coast |
| `eu-west-1` | Ireland | Good for Europe |
| `ap-southeast-1` | Singapore | Good for Asia |

---

## ✅ **Validation Commands**

```bash
# Check AWS CLI setup
aws sts get-caller-identity

# After script 1 - Check VPC
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=YOUR_APP_NAME"

# After script 2 - Check security groups  
aws ec2 describe-security-groups --filters "Name=tag:Project,Values=YOUR_APP_NAME"

# After script 3 - Check database
aws rds describe-db-instances --db-instance-identifier YOUR_APP_NAME-db
```

---

## 🆘 **Quick Troubleshooting**

| Error | Solution |
|-------|----------|
| `AWS CLI not configured` | Run `aws configure` |
| `jq: command not found` | Install jq: `sudo apt install jq` |
| `Permission denied` | Check IAM permissions |
| `Region not supported` | Use major regions like us-east-1 |

---

## 📝 **Script Execution Order**

1. **01-create-network.sh** (5-10 minutes)
   - Creates VPC, subnets, gateways
   - Generates `network-config.env`

2. **02-create-security-groups.sh** (2-3 minutes)
   - Creates firewall rules
   - Updates `network-config.env`

3. **03-create-database.sh** (15-20 minutes)
   - Creates RDS PostgreSQL
   - Creates connection scripts

**Total Time: ~25-35 minutes**

---

## 🎯 **What Gets Created**

### **Networking:**
- 1 VPC with DNS support
- 4 subnets (2 public, 2 private)
- 1 Internet Gateway
- 2 NAT Gateways (high availability)
- Route tables and associations

### **Security:**
- ALB Security Group (web traffic)
- ECS Security Group (application)
- RDS Security Group (database)
- Bastion Security Group (admin access)

### **Database:**
- PostgreSQL RDS instance
- Automated backups
- Secure credential storage
- Connection helper scripts

---

**💡 Tip: All scripts are idempotent - you can safely re-run them if something fails!**