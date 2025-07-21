#!/bin/bash

# =============================================================================
# Week 1 - Day 3-4: Network Infrastructure Setup
# =============================================================================
# This script creates the basic networking infrastructure for our application
# including VPC, subnets, internet gateway, NAT gateways, and route tables
#
# PREREQUISITES:
# 1. AWS CLI installed and configured (run: aws configure)
# 2. Proper IAM permissions for VPC, EC2, and networking services
# 3. jq installed for JSON parsing (run: sudo apt install jq)
#
# CUSTOMIZATION REQUIRED:
# - Change AWS_REGION if you want to deploy in a different region
# - Change APP_NAME if you want a different application name prefix
# =============================================================================

set -e  # Exit on any error
echo "🌐 Starting network infrastructure setup..."

# =============================================================================
# CONFIGURATION SECTION - CUSTOMIZE THESE VALUES
# =============================================================================
# TODO: Change these values according to your preferences

export AWS_REGION="us-east-1"        # 🔧 CHANGE THIS: Your preferred AWS region
                                      # Options: us-east-1, us-west-2, eu-west-1, etc.

export APP_NAME="expense-tracker"     # 🔧 CHANGE THIS: Your application name
                                      # This will be used as prefix for all resources
                                      # Use lowercase letters and hyphens only

# =============================================================================
# VALIDATION SECTION - DO NOT MODIFY
# =============================================================================

# Validate AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ Error: AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ AWS CLI configured for account: $(aws sts get-caller-identity --query Account --output text)"
echo "✅ Using region: $AWS_REGION"

echo "📋 Step 1: Creating VPC..."
# Create VPC with DNS support
# CIDR 10.0.0.0/16 provides 65,536 IP addresses (10.0.0.1 to 10.0.255.254)
VPC_OUTPUT=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=${APP_NAME}-vpc},{Key=Project,Value=${APP_NAME}}]" \
    --region $AWS_REGION)

export VPC_ID=$(echo $VPC_OUTPUT | jq -r '.Vpc.VpcId')
echo "✅ VPC created: $VPC_ID"

# Enable DNS hostnames and resolution (required for RDS and ECS)
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support
echo "✅ DNS support enabled for VPC"

echo "📋 Step 2: Creating Internet Gateway..."
# Create Internet Gateway
IGW_OUTPUT=$(aws ec2 create-internet-gateway \
    --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=${APP_NAME}-igw},{Key=Project,Value=${APP_NAME}}]" \
    --region $AWS_REGION)

export IGW_ID=$(echo $IGW_OUTPUT | jq -r '.InternetGateway.InternetGatewayId')
echo "✅ Internet Gateway created: $IGW_ID"

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
echo "✅ Internet Gateway attached to VPC"

echo "📋 Step 3: Creating Subnets..."
# Get the first two availability zones in the region
# This ensures high availability across multiple data centers
AZ1=$(aws ec2 describe-availability-zones --region $AWS_REGION --query 'AvailabilityZones[0].ZoneName' --output text)
AZ2=$(aws ec2 describe-availability-zones --region $AWS_REGION --query 'AvailabilityZones[1].ZoneName' --output text)

echo "📍 Using availability zones: $AZ1 and $AZ2"

# =============================================================================
# PUBLIC SUBNETS - For resources that need internet access (Load Balancer, NAT Gateway)
# =============================================================================
# Public Subnet 1: 10.0.1.0/24 (256 IP addresses: 10.0.1.1 to 10.0.1.254)
PUBLIC_SUBNET_1=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone $AZ1 \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${APP_NAME}-public-1a},{Key=Type,Value=Public},{Key=Project,Value=${APP_NAME}}]" \
    --query 'Subnet.SubnetId' --output text)

# Public Subnet 2: 10.0.2.0/24 (256 IP addresses: 10.0.2.1 to 10.0.2.254)
PUBLIC_SUBNET_2=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.2.0/24 \
    --availability-zone $AZ2 \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${APP_NAME}-public-1b},{Key=Type,Value=Public},{Key=Project,Value=${APP_NAME}}]" \
    --query 'Subnet.SubnetId' --output text)

echo "✅ Public subnets created: $PUBLIC_SUBNET_1, $PUBLIC_SUBNET_2"

# =============================================================================
# PRIVATE SUBNETS - For resources that should NOT have direct internet access (ECS, RDS)
# =============================================================================
# Private Subnet 1: 10.0.3.0/24 (256 IP addresses: 10.0.3.1 to 10.0.3.254)
PRIVATE_SUBNET_1=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.3.0/24 \
    --availability-zone $AZ1 \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${APP_NAME}-private-1a},{Key=Type,Value=Private},{Key=Project,Value=${APP_NAME}}]" \
    --query 'Subnet.SubnetId' --output text)

# Private Subnet 2: 10.0.4.0/24 (256 IP addresses: 10.0.4.1 to 10.0.4.254)
PRIVATE_SUBNET_2=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.4.0/24 \
    --availability-zone $AZ2 \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${APP_NAME}-private-1b},{Key=Type,Value=Private},{Key=Project,Value=${APP_NAME}}]" \
    --query 'Subnet.SubnetId' --output text)

echo "✅ Private subnets created: $PRIVATE_SUBNET_1, $PRIVATE_SUBNET_2"

# Enable auto-assign public IP for public subnets
aws ec2 modify-subnet-attribute --subnet-id $PUBLIC_SUBNET_1 --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --subnet-id $PUBLIC_SUBNET_2 --map-public-ip-on-launch
echo "✅ Auto-assign public IP enabled for public subnets"

echo "📋 Step 4: Creating NAT Gateways..."
# Create Elastic IPs for NAT Gateways
EIP1=$(aws ec2 allocate-address --domain vpc --tag-specifications "ResourceType=elastic-ip,Tags=[{Key=Name,Value=${APP_NAME}-nat-eip-1},{Key=Project,Value=${APP_NAME}}]" --query 'AllocationId' --output text)
EIP2=$(aws ec2 allocate-address --domain vpc --tag-specifications "ResourceType=elastic-ip,Tags=[{Key=Name,Value=${APP_NAME}-nat-eip-2},{Key=Project,Value=${APP_NAME}}]" --query 'AllocationId' --output text)

echo "✅ Elastic IPs created: $EIP1, $EIP2"

# Create NAT Gateways
NAT_GW_1=$(aws ec2 create-nat-gateway \
    --subnet-id $PUBLIC_SUBNET_1 \
    --allocation-id $EIP1 \
    --tag-specifications "ResourceType=nat-gateway,Tags=[{Key=Name,Value=${APP_NAME}-nat-1a},{Key=Project,Value=${APP_NAME}}]" \
    --query 'NatGateway.NatGatewayId' --output text)

NAT_GW_2=$(aws ec2 create-nat-gateway \
    --subnet-id $PUBLIC_SUBNET_2 \
    --allocation-id $EIP2 \
    --tag-specifications "ResourceType=nat-gateway,Tags=[{Key=Name,Value=${APP_NAME}-nat-1b},{Key=Project,Value=${APP_NAME}}]" \
    --query 'NatGateway.NatGatewayId' --output text)

echo "✅ NAT Gateways created: $NAT_GW_1, $NAT_GW_2"
echo "⏳ Waiting for NAT Gateways to be available..."
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW_1 $NAT_GW_2

echo "📋 Step 5: Creating Route Tables..."
# Create Route Table for Public Subnets
PUBLIC_RT=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=${APP_NAME}-public-rt},{Key=Type,Value=Public},{Key=Project,Value=${APP_NAME}}]" \
    --query 'RouteTable.RouteTableId' --output text)

# Add route to Internet Gateway
aws ec2 create-route --route-table-id $PUBLIC_RT --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

# Associate public subnets with public route table
aws ec2 associate-route-table --subnet-id $PUBLIC_SUBNET_1 --route-table-id $PUBLIC_RT
aws ec2 associate-route-table --subnet-id $PUBLIC_SUBNET_2 --route-table-id $PUBLIC_RT

echo "✅ Public route table configured: $PUBLIC_RT"

# Create Route Tables for Private Subnets
PRIVATE_RT_1=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=${APP_NAME}-private-rt-1a},{Key=Type,Value=Private},{Key=Project,Value=${APP_NAME}}]" \
    --query 'RouteTable.RouteTableId' --output text)

PRIVATE_RT_2=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=${APP_NAME}-private-rt-1b},{Key=Type,Value=Private},{Key=Project,Value=${APP_NAME}}]" \
    --query 'RouteTable.RouteTableId' --output text)

# Add routes to NAT Gateways
aws ec2 create-route --route-table-id $PRIVATE_RT_1 --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NAT_GW_1
aws ec2 create-route --route-table-id $PRIVATE_RT_2 --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NAT_GW_2

# Associate private subnets with private route tables
aws ec2 associate-route-table --subnet-id $PRIVATE_SUBNET_1 --route-table-id $PRIVATE_RT_1
aws ec2 associate-route-table --subnet-id $PRIVATE_SUBNET_2 --route-table-id $PRIVATE_RT_2

echo "✅ Private route tables configured: $PRIVATE_RT_1, $PRIVATE_RT_2"

echo "📋 Step 6: Saving configuration..."
# Save important IDs to a file for later use
cat > network-config.env << EOF
# Network Configuration - Created $(date)
export VPC_ID="$VPC_ID"
export IGW_ID="$IGW_ID"
export PUBLIC_SUBNET_1="$PUBLIC_SUBNET_1"
export PUBLIC_SUBNET_2="$PUBLIC_SUBNET_2"
export PRIVATE_SUBNET_1="$PRIVATE_SUBNET_1"
export PRIVATE_SUBNET_2="$PRIVATE_SUBNET_2"
export NAT_GW_1="$NAT_GW_1"
export NAT_GW_2="$NAT_GW_2"
export PUBLIC_RT="$PUBLIC_RT"
export PRIVATE_RT_1="$PRIVATE_RT_1"
export PRIVATE_RT_2="$PRIVATE_RT_2"
export AWS_REGION="$AWS_REGION"
export APP_NAME="$APP_NAME"
EOF

echo "✅ Configuration saved to network-config.env"

echo "🎉 Network infrastructure setup complete!"
echo ""
echo "📝 Summary:"
echo "   - VPC: $VPC_ID"
echo "   - Public Subnets: $PUBLIC_SUBNET_1, $PUBLIC_SUBNET_2"
echo "   - Private Subnets: $PRIVATE_SUBNET_1, $PRIVATE_SUBNET_2"
echo "   - NAT Gateways: $NAT_GW_1, $NAT_GW_2"
echo ""
echo "💡 Next steps:"
echo "   1. Review the AWS Console to see your created resources"
echo "   2. Run: source network-config.env to load these variables"
echo "   3. Proceed to Day 5-6: Security Groups setup"