#!/bin/bash

# Week 1 - Day 3-4: Network Infrastructure Setup
# This script creates the basic networking infrastructure for our application

set -e
echo "🌐 Starting network infrastructure setup..."

# Configuration
export AWS_REGION="us-east-1"
export APP_NAME="expense-tracker"

echo "📋 Step 1: Creating VPC..."
# Create VPC with DNS support
VPC_OUTPUT=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=${APP_NAME}-vpc},{Key=Project,Value=${APP_NAME}}]" \
    --region $AWS_REGION)

export VPC_ID=$(echo $VPC_OUTPUT | jq -r '.Vpc.VpcId')
echo "✅ VPC created: $VPC_ID"

# Enable DNS hostnames
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
# Get availability zones
AZ1=$(aws ec2 describe-availability-zones --region $AWS_REGION --query 'AvailabilityZones[0].ZoneName' --output text)
AZ2=$(aws ec2 describe-availability-zones --region $AWS_REGION --query 'AvailabilityZones[1].ZoneName' --output text)

# Create Public Subnets (for Load Balancer)
PUBLIC_SUBNET_1=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone $AZ1 \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${APP_NAME}-public-1a},{Key=Type,Value=Public},{Key=Project,Value=${APP_NAME}}]" \
    --query 'Subnet.SubnetId' --output text)

PUBLIC_SUBNET_2=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.2.0/24 \
    --availability-zone $AZ2 \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${APP_NAME}-public-1b},{Key=Type,Value=Public},{Key=Project,Value=${APP_NAME}}]" \
    --query 'Subnet.SubnetId' --output text)

echo "✅ Public subnets created: $PUBLIC_SUBNET_1, $PUBLIC_SUBNET_2"

# Create Private Subnets (for ECS and RDS)
PRIVATE_SUBNET_1=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.3.0/24 \
    --availability-zone $AZ1 \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${APP_NAME}-private-1a},{Key=Type,Value=Private},{Key=Project,Value=${APP_NAME}}]" \
    --query 'Subnet.SubnetId' --output text)

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