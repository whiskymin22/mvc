# Week 1: Manual Deployment & AWS Learning

**Goal**: Understand AWS services deeply by deploying infrastructure manually and learning each component.

## 📅 **Daily Schedule**

### **Day 1-2: Environment Setup**
**Time**: 2-3 hours  
**Difficulty**: Beginner

#### **Learning Objectives:**
- Install and configure AWS CLI
- Understand AWS credentials and regions
- Set up development environment
- Learn basic AWS CLI commands

#### **Tasks:**
1. **Install Tools** (30 minutes)
   ```bash
   # Install AWS CLI v2
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   
   # Install Docker
   sudo apt update && sudo apt install docker.io -y
   sudo usermod -aG docker $USER
   
   # Install PostgreSQL client
   sudo apt install postgresql-client -y
   ```

2. **Configure AWS CLI** (15 minutes)
   ```bash
   aws configure
   # Test connection
   aws sts get-caller-identity
   ```

3. **Explore AWS Console** (60 minutes)
   - Navigate to VPC, EC2, RDS, ECS services
   - Understand the AWS interface
   - Review pricing for each service

4. **Practice Basic Commands** (30 minutes)
   ```bash
   # List regions
   aws ec2 describe-regions
   
   # List availability zones
   aws ec2 describe-availability-zones --region us-east-1
   
   # Check current user
   aws sts get-caller-identity
   ```

#### **Learning Resources:**
- [AWS CLI User Guide](https://docs.aws.amazon.com/cli/latest/userguide/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

### **Day 3-4: Network Infrastructure**
**Time**: 3-4 hours  
**Difficulty**: Intermediate

#### **Learning Objectives:**
- Understand VPC concepts (subnets, routing, gateways)
- Learn about public vs private subnets
- Understand NAT Gateways and Internet Gateways
- Learn network security basics

#### **Tasks:**
1. **Study VPC Concepts** (60 minutes)
   - Read AWS VPC documentation
   - Understand CIDR blocks
   - Learn about route tables

2. **Run Network Setup Script** (30 minutes)
   ```bash
   chmod +x 01-create-network.sh
   ./01-create-network.sh
   ```

3. **Explore Created Resources** (90 minutes)
   - Go to VPC Console
   - Examine each created resource
   - Understand the network topology
   - Draw the network diagram

4. **Test Network Connectivity** (60 minutes)
   - Understand routing between subnets
   - Learn about NAT Gateway costs
   - Review network ACLs vs Security Groups

#### **Key Concepts to Master:**
- **VPC**: Your isolated network in AWS
- **Subnets**: Network segments within VPC
- **Internet Gateway**: Allows internet access
- **NAT Gateway**: Allows outbound internet from private subnets
- **Route Tables**: Direct network traffic

#### **Practical Exercise:**
```bash
# Load your network configuration
source network-config.env

# Explore your resources
aws ec2 describe-vpcs --vpc-ids $VPC_ID
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID"
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID"
```

---

### **Day 5-6: Security Groups**
**Time**: 2-3 hours  
**Difficulty**: Intermediate

#### **Learning Objectives:**
- Understand Security Groups vs NACLs
- Learn firewall rules and port management
- Understand the principle of least privilege
- Learn security group references

#### **Tasks:**
1. **Study Security Concepts** (45 minutes)
   - Read about Security Groups
   - Understand stateful vs stateless firewalls
   - Learn common ports (80, 443, 22, 5432, 8080)

2. **Run Security Groups Script** (15 minutes)
   ```bash
   chmod +x 02-create-security-groups.sh
   ./02-create-security-groups.sh
   ```

3. **Analyze Security Architecture** (90 minutes)
   - Review each security group
   - Understand the security layers
   - Test security group rules
   - Learn about security group references

4. **Security Best Practices** (60 minutes)
   - Learn about least privilege principle
   - Understand defense in depth
   - Review AWS security best practices

#### **Key Concepts to Master:**
- **Security Groups**: Virtual firewalls for instances
- **Inbound Rules**: Control incoming traffic
- **Outbound Rules**: Control outgoing traffic
- **Security Group References**: Allow traffic from other security groups

#### **Security Architecture Understanding:**
```
Internet → ALB Security Group (80/443) 
         → ECS Security Group (8080) 
         → RDS Security Group (5432)
```

---

### **Day 7: Database Setup**
**Time**: 2-4 hours (including wait time)  
**Difficulty**: Intermediate

#### **Learning Objectives:**
- Understand RDS managed database service
- Learn about Multi-AZ deployments
- Understand database security and networking
- Learn about AWS Systems Manager Parameter Store

#### **Tasks:**
1. **Study RDS Concepts** (60 minutes)
   - Read RDS documentation
   - Understand Multi-AZ vs Read Replicas
   - Learn about automated backups
   - Study database security

2. **Run Database Setup Script** (30 minutes + 15 minutes wait)
   ```bash
   chmod +x 03-create-database.sh
   ./03-create-database.sh
   ```

3. **Test Database Connection** (45 minutes)
   ```bash
   # Test database connection (requires bastion host or VPN)
   ./connect-to-db.sh
   
   # Initialize database
   \i init-database.sql
   ```

4. **Explore Parameter Store** (30 minutes)
   - Go to Systems Manager Console
   - View stored parameters
   - Understand secure string encryption

#### **Key Concepts to Master:**
- **RDS**: Managed relational database service
- **Multi-AZ**: High availability deployment
- **Subnet Groups**: Database subnet placement
- **Parameter Store**: Secure configuration storage
- **Encryption**: Data encryption at rest and in transit

#### **Database Features Implemented:**
- ✅ PostgreSQL 15.4
- ✅ Multi-AZ deployment (automatic failover)
- ✅ Automated backups (7 days)
- ✅ Storage encryption
- ✅ Auto-scaling storage (20GB → 100GB)
- ✅ Private subnet deployment
- ✅ Secure credential storage

---

## 📊 **Week 1 Progress Tracking**

### **Daily Checklist:**

#### **Day 1-2: Setup ✅**
- [ ] AWS CLI installed and configured
- [ ] Docker installed and working
- [ ] PostgreSQL client installed
- [ ] AWS Console exploration completed
- [ ] Basic AWS CLI commands practiced

#### **Day 3-4: Networking ✅**
- [ ] VPC concepts understood
- [ ] Network script executed successfully
- [ ] All network resources reviewed in console
- [ ] Network topology diagram drawn
- [ ] Route table concepts mastered

#### **Day 5-6: Security ✅**
- [ ] Security Groups vs NACLs understood
- [ ] Security script executed successfully
- [ ] Security architecture analyzed
- [ ] Security best practices reviewed
- [ ] Port and protocol concepts mastered

#### **Day 7: Database ✅**
- [ ] RDS concepts understood
- [ ] Database script executed successfully
- [ ] Database connection tested
- [ ] Parameter Store explored
- [ ] Database initialization completed

## 🎯 **Week 1 Assessment**

### **Knowledge Check Questions:**
1. What's the difference between public and private subnets?
2. Why do we need NAT Gateways?
3. How do Security Groups differ from NACLs?
4. What are the benefits of Multi-AZ RDS deployment?
5. Why use Parameter Store for database credentials?

### **Practical Skills Gained:**
- ✅ AWS CLI proficiency
- ✅ VPC networking understanding
- ✅ Security group configuration
- ✅ RDS database management
- ✅ Infrastructure as Code basics
- ✅ AWS Console navigation

## 💰 **Week 1 Cost Analysis**

### **Resources Created:**
- **VPC**: Free
- **Subnets**: Free
- **Internet Gateway**: Free
- **NAT Gateways**: ~$45/month (2 gateways)
- **RDS t3.micro Multi-AZ**: ~$25/month
- **Security Groups**: Free
- **Parameter Store**: Free (standard parameters)

**Estimated Week 1 Cost**: ~$15-20 (prorated)

### **Cost Optimization Notes:**
- NAT Gateways are the most expensive component
- Consider single NAT Gateway for development
- RDS Multi-AZ doubles database costs
- Use single-AZ for development environments

## 📚 **Additional Learning Resources**

### **AWS Documentation:**
- [VPC User Guide](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [RDS User Guide](https://docs.aws.amazon.com/rds/latest/userguide/)
- [Security Groups Guide](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)

### **Hands-on Labs:**
- AWS VPC Hands-on Lab
- RDS Database Creation Lab
- Security Groups Configuration Lab

## 🔄 **Troubleshooting Guide**

### **Common Issues:**

1. **AWS CLI Not Configured**
   ```bash
   aws configure list
   aws sts get-caller-identity
   ```

2. **Permission Errors**
   - Check IAM user permissions
   - Ensure proper policy attachments

3. **Network Script Fails**
   - Check region availability zones
   - Verify AWS CLI configuration

4. **Database Connection Issues**
   - Verify security group rules
   - Check subnet group configuration
   - Ensure database is in available state

## 🎉 **Week 1 Completion**

**Congratulations!** You've successfully:
- Created a complete AWS network infrastructure
- Implemented proper security layers
- Deployed a production-ready database
- Learned fundamental AWS concepts
- Built hands-on experience with AWS services

**Next Week Preview**: You'll learn Terraform basics and start automating this infrastructure while the manual deployment runs in parallel.