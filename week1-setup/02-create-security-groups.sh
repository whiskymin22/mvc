#!/bin/bash

# =============================================================================
# Week 1 - Day 5-6: Security Groups Setup
# =============================================================================
# This script creates security groups with proper firewall rules
# Security groups act as virtual firewalls for your AWS resources
#
# PREREQUISITES:
# 1. Run 01-create-network.sh first to create VPC and subnets
# 2. AWS CLI configured with proper permissions
# 3. network-config.env file exists (created by previous script)
#
# CUSTOMIZATION:
# - No changes needed - this script uses configuration from previous script
# - The script automatically detects your public IP for bastion access
# =============================================================================

set -e  # Exit on any error
echo "🔒 Starting security groups setup..."

# =============================================================================
# LOAD CONFIGURATION FROM PREVIOUS SCRIPT - DO NOT MODIFY
# =============================================================================
# Load network configuration created by 01-create-network.sh
if [ -f "network-config.env" ]; then
    source network-config.env
    echo "✅ Network configuration loaded"
    echo "   VPC ID: $VPC_ID"
    echo "   App Name: $APP_NAME"
    echo "   Region: $AWS_REGION"
else
    echo "❌ network-config.env not found. Please run 01-create-network.sh first"
    exit 1
fi

echo "📋 Step 1: Creating ALB Security Group..."
# =============================================================================
# APPLICATION LOAD BALANCER SECURITY GROUP
# Purpose: Controls traffic to/from the load balancer
# Location: Public subnets
# =============================================================================
ALB_SG=$(aws ec2 create-security-group \
    --group-name "${APP_NAME}-alb-sg" \
    --description "Security group for Application Load Balancer" \
    --vpc-id $VPC_ID \
    --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=${APP_NAME}-alb-sg},{Key=Type,Value=ALB},{Key=Project,Value=${APP_NAME}}]" \
    --query 'GroupId' --output text)

echo "✅ ALB Security Group created: $ALB_SG"

# INBOUND RULES for ALB:
# Allow HTTP (port 80) from anywhere on the internet
aws ec2 authorize-security-group-ingress \
    --group-id $ALB_SG \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0 \
    --tag-specifications "ResourceType=security-group-rule,Tags=[{Key=Name,Value=HTTP-from-internet}]"

# Allow HTTPS (port 443) from anywhere on the internet
aws ec2 authorize-security-group-ingress \
    --group-id $ALB_SG \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0 \
    --tag-specifications "ResourceType=security-group-rule,Tags=[{Key=Name,Value=HTTPS-from-internet}]"

echo "✅ ALB Security Group rules added:"
echo "   - HTTP (80) from anywhere (0.0.0.0/0)"
echo "   - HTTPS (443) from anywhere (0.0.0.0/0)"

echo "📋 Step 2: Creating ECS Security Group..."
# Security Group for ECS Tasks
ECS_SG=$(aws ec2 create-security-group \
    --group-name "${APP_NAME}-ecs-sg" \
    --description "Security group for ECS tasks" \
    --vpc-id $VPC_ID \
    --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=${APP_NAME}-ecs-sg},{Key=Type,Value=ECS},{Key=Project,Value=${APP_NAME}}]" \
    --query 'GroupId' --output text)

echo "✅ ECS Security Group created: $ECS_SG"

# Add rule for ECS (Port 8080 from ALB only)
aws ec2 authorize-security-group-ingress \
    --group-id $ECS_SG \
    --protocol tcp \
    --port 8080 \
    --source-group $ALB_SG

# Add rule for ECS (All outbound traffic - for downloading packages, connecting to RDS)
aws ec2 authorize-security-group-egress \
    --group-id $ECS_SG \
    --protocol all \
    --port all \
    --cidr 0.0.0.0/0

echo "✅ ECS Security Group rules added (Port 8080 from ALB, all outbound)"

echo "📋 Step 3: Creating RDS Security Group..."
# Security Group for RDS
RDS_SG=$(aws ec2 create-security-group \
    --group-name "${APP_NAME}-rds-sg" \
    --description "Security group for RDS PostgreSQL" \
    --vpc-id $VPC_ID \
    --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=${APP_NAME}-rds-sg},{Key=Type,Value=RDS},{Key=Project,Value=${APP_NAME}}]" \
    --query 'GroupId' --output text)

echo "✅ RDS Security Group created: $RDS_SG"

# Add rule for RDS (PostgreSQL port 5432 from ECS only)
aws ec2 authorize-security-group-ingress \
    --group-id $RDS_SG \
    --protocol tcp \
    --port 5432 \
    --source-group $ECS_SG

echo "✅ RDS Security Group rules added (PostgreSQL from ECS only)"

echo "📋 Step 4: Creating Bastion Security Group (Optional)..."
# Security Group for Bastion Host (for database access during development)
BASTION_SG=$(aws ec2 create-security-group \
    --group-name "${APP_NAME}-bastion-sg" \
    --description "Security group for Bastion host" \
    --vpc-id $VPC_ID \
    --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=${APP_NAME}-bastion-sg},{Key=Type,Value=Bastion},{Key=Project,Value=${APP_NAME}}]" \
    --query 'GroupId' --output text)

echo "✅ Bastion Security Group created: $BASTION_SG"

# Add SSH access from your IP (get your current IP)
MY_IP=$(curl -s https://checkip.amazonaws.com)/32
aws ec2 authorize-security-group-ingress \
    --group-id $BASTION_SG \
    --protocol tcp \
    --port 22 \
    --cidr $MY_IP

echo "✅ Bastion Security Group rules added (SSH from your IP: $MY_IP)"

# Allow RDS access from Bastion
aws ec2 authorize-security-group-ingress \
    --group-id $RDS_SG \
    --protocol tcp \
    --port 5432 \
    --source-group $BASTION_SG

echo "✅ RDS now allows access from Bastion host"

echo "📋 Step 5: Saving security group configuration..."
# Append security group IDs to configuration file
cat >> network-config.env << EOF

# Security Groups - Added $(date)
export ALB_SG="$ALB_SG"
export ECS_SG="$ECS_SG"
export RDS_SG="$RDS_SG"
export BASTION_SG="$BASTION_SG"
export MY_IP="$MY_IP"
EOF

echo "✅ Security group configuration saved"

echo "🎉 Security groups setup complete!"
echo ""
echo "📝 Summary:"
echo "   - ALB Security Group: $ALB_SG (HTTP/HTTPS from anywhere)"
echo "   - ECS Security Group: $ECS_SG (Port 8080 from ALB)"
echo "   - RDS Security Group: $RDS_SG (PostgreSQL from ECS and Bastion)"
echo "   - Bastion Security Group: $BASTION_SG (SSH from your IP)"
echo ""
echo "🔒 Security Architecture:"
echo "   Internet → ALB (80/443) → ECS (8080) → RDS (5432)"
echo "   Your IP → Bastion (22) → RDS (5432) [for development]"
echo ""
echo "💡 Next steps:"
echo "   1. Review security groups in AWS Console"
echo "   2. Understand the security layers"
echo "   3. Proceed to Day 7: Database setup"