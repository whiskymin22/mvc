# Week 2: Terraform Basics & Infrastructure as Code

**Goal**: Learn Terraform fundamentals while your manual infrastructure runs in parallel, preparing for automation.

## 📅 **Daily Schedule**

### **Day 8-9: Terraform Fundamentals**
**Time**: 3-4 hours  
**Difficulty**: Beginner to Intermediate

#### **Learning Objectives:**
- Understand Infrastructure as Code (IaC) principles
- Learn Terraform basics and HCL syntax
- Understand state management
- Practice with simple Terraform resources

#### **Tasks:**
1. **Install Terraform** (15 minutes)
   ```bash
   # Install Terraform
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   sudo apt-get update && sudo apt-get install terraform
   
   # Verify installation
   terraform --version
   ```

2. **Learn Terraform Basics** (2 hours)
   - Study HCL (HashiCorp Configuration Language)
   - Understand resources, providers, and variables
   - Learn about Terraform workflow: init, plan, apply, destroy
   - Practice with simple examples

3. **Create Your First Terraform Configuration** (90 minutes)
   ```bash
   mkdir terraform-learning
   cd terraform-learning
   ```

4. **Hands-on Practice** (60 minutes)
   - Create S3 bucket with Terraform
   - Understand state files
   - Practice terraform commands

#### **Key Concepts to Master:**
- **Resources**: Infrastructure objects (EC2, S3, VPC)
- **Providers**: Interface to APIs (AWS, Azure, GCP)
- **State**: Terraform's knowledge of infrastructure
- **Variables**: Parameterize configurations
- **Outputs**: Return values from modules

---

### **Day 10-11: Terraform State & Remote Backend**
**Time**: 2-3 hours  
**Difficulty**: Intermediate

#### **Learning Objectives:**
- Understand Terraform state management
- Learn about remote state backends
- Set up S3 + DynamoDB backend
- Understand state locking

#### **Tasks:**
1. **Study State Management** (60 minutes)
   - Learn why state is important
   - Understand local vs remote state
   - Learn about state locking

2. **Set up Remote State Backend** (90 minutes)
   ```bash
   # Create S3 bucket for state
   aws s3 mb s3://your-terraform-state-bucket-unique-name
   
   # Create DynamoDB table for locking
   aws dynamodb create-table \
     --table-name terraform-state-locks \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST
   ```

3. **Configure Backend** (30 minutes)
   - Update Terraform configuration with backend
   - Initialize with remote state
   - Test state operations

#### **Backend Configuration Example:**
```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "expense-tracker/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
```

---

### **Day 12-13: Recreate Manual Infrastructure with Terraform**
**Time**: 4-5 hours  
**Difficulty**: Intermediate to Advanced

#### **Learning Objectives:**
- Convert manual infrastructure to Terraform
- Learn about Terraform modules
- Understand resource dependencies
- Practice with complex configurations

#### **Tasks:**
1. **Study Existing Infrastructure** (60 minutes)
   - Review your manual infrastructure
   - Understand resource relationships
   - Plan Terraform structure

2. **Create Terraform Configuration** (3 hours)
   - Start with VPC and networking
   - Add security groups
   - Configure RDS instance
   - Use the provided infrastructure.tf as reference

3. **Test and Validate** (90 minutes)
   - Run terraform plan
   - Compare with manual infrastructure
   - Understand differences and conflicts

#### **Terraform Structure:**
```
terraform-infrastructure/
├── main.tf           # Main configuration
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── terraform.tfvars  # Variable values
└── modules/          # Reusable modules
    ├── vpc/
    ├── security/
    └── database/
```

---

### **Day 14: Terraform Best Practices & Modules**
**Time**: 2-3 hours  
**Difficulty**: Advanced

#### **Learning Objectives:**
- Learn Terraform best practices
- Understand module creation and usage
- Learn about workspaces
- Practice code organization

#### **Tasks:**
1. **Study Best Practices** (60 minutes)
   - Learn about naming conventions
   - Understand resource tagging
   - Study security best practices

2. **Create Reusable Modules** (90 minutes)
   - Create VPC module
   - Create security group module
   - Learn module versioning

3. **Implement Advanced Features** (60 minutes)
   - Use data sources
   - Implement conditional resources
   - Learn about for_each and count

---

## 📊 **Week 2 Progress Tracking**

### **Daily Checklist:**

#### **Day 8-9: Terraform Basics ✅**
- [ ] Terraform installed and configured
- [ ] HCL syntax understood
- [ ] First Terraform configuration created
- [ ] Basic terraform commands practiced
- [ ] State file concepts understood

#### **Day 10-11: State Management ✅**
- [ ] Remote state backend configured
- [ ] S3 + DynamoDB setup completed
- [ ] State locking understood
- [ ] Backend migration tested

#### **Day 12-13: Infrastructure Recreation ✅**
- [ ] Manual infrastructure analyzed
- [ ] Terraform configuration created
- [ ] Resource dependencies understood
- [ ] Configuration validated with terraform plan

#### **Day 14: Best Practices ✅**
- [ ] Terraform best practices studied
- [ ] Modules created and tested
- [ ] Advanced features implemented
- [ ] Code organization improved

## 🎯 **Week 2 Learning Exercises**

### **Exercise 1: Simple S3 Bucket**
```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-terraform-learning-bucket-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
```

### **Exercise 2: VPC Module**
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  cidr_block           = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  
  tags = {
    Project = "expense-tracker"
    Environment = "learning"
  }
}
```

### **Exercise 3: Data Sources**
```hcl
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
```

## 📚 **Learning Resources**

### **Terraform Documentation:**
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Language](https://www.terraform.io/language)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

### **Practice Labs:**
- Terraform Associate Certification Labs
- AWS + Terraform Hands-on Tutorials
- HashiCorp Learn Platform

## 🔄 **Parallel Infrastructure Management**

### **Week 2 Strategy:**
While learning Terraform, keep your manual infrastructure running:

1. **Don't Delete Manual Infrastructure**: Keep it running for reference
2. **Create in Different Region**: Use `us-west-2` for Terraform practice
3. **Compare Configurations**: Understand differences between manual and Terraform
4. **Cost Management**: Monitor costs for both environments

### **Resource Comparison:**
```bash
# Manual infrastructure (us-east-1)
aws ec2 describe-vpcs --region us-east-1 --filters "Name=tag:Project,Values=expense-tracker"

# Terraform infrastructure (us-west-2)  
aws ec2 describe-vpcs --region us-west-2 --filters "Name=tag:Project,Values=expense-tracker"
```

## 💰 **Week 2 Cost Considerations**

### **Additional Costs:**
- **S3 State Bucket**: ~$0.02/month
- **DynamoDB State Locking**: ~$0.25/month
- **Terraform Learning Environment**: ~$15-25/month (if created)

### **Cost Optimization:**
- Use smaller instance types for learning
- Destroy learning resources daily
- Use single AZ for non-production

## 🎉 **Week 2 Completion**

**Skills Acquired:**
- ✅ Terraform fundamentals
- ✅ HCL syntax proficiency
- ✅ State management understanding
- ✅ Remote backend configuration
- ✅ Infrastructure as Code principles
- ✅ Module creation and usage
- ✅ Terraform best practices

**Next Week Preview**: You'll recreate your infrastructure using Terraform in a new environment and prepare for application deployment.