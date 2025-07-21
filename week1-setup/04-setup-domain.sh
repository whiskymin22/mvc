#!/bin/bash

# =============================================================================
# Week 1 - Day 7 (Optional): Domain Setup with Route 53
# =============================================================================
# This script sets up your custom domain (caohuuminh.com) with Route 53
# 
# PREREQUISITES:
# 1. Domain purchased (caohuuminh.com)
# 2. Run previous scripts (01, 02, 03) first
# 3. AWS CLI configured with Route 53 permissions
#
# CUSTOMIZATION REQUIRED:
# - Change DOMAIN_NAME to your actual domain
# - Verify domain ownership
# =============================================================================

set -e  # Exit on any error
echo "🌐 Starting domain setup with Route 53..."

# =============================================================================
# DOMAIN CONFIGURATION - CUSTOMIZE THIS
# =============================================================================
DOMAIN_NAME="caohuuminh.com"          # 🔧 CHANGE THIS: Your domain name
EMAIL="your-email@example.com"        # 🔧 CHANGE THIS: Your email for SSL certs

# Load existing configuration
if [ -f "network-config.env" ]; then
    source network-config.env
    echo "✅ Network configuration loaded"
else
    echo "❌ Please run scripts 01-03 first"
    exit 1
fi

echo "📋 Step 1: Creating Route 53 Hosted Zone..."
# Create hosted zone for your domain
HOSTED_ZONE=$(aws route53 create-hosted-zone \
    --name $DOMAIN_NAME \
    --caller-reference "expense-tracker-$(date +%s)" \
    --hosted-zone-config Comment="Hosted zone for expense tracker app" \
    --query 'HostedZone.Id' --output text)

echo "✅ Hosted Zone created: $HOSTED_ZONE"

# Get name servers
NAME_SERVERS=$(aws route53 get-hosted-zone --id $HOSTED_ZONE --query 'DelegationSet.NameServers' --output table)
echo "📝 Configure these name servers at your domain registrar:"
echo "$NAME_SERVERS"

echo "📋 Step 2: Requesting SSL Certificate..."
# Request SSL certificate for domain and subdomain
CERT_ARN=$(aws acm request-certificate \
    --domain-name $DOMAIN_NAME \
    --subject-alternative-names "www.$DOMAIN_NAME" "api.$DOMAIN_NAME" "*.${DOMAIN_NAME}" \
    --validation-method DNS \
    --region us-east-1 \
    --query 'CertificateArn' --output text)

echo "✅ SSL Certificate requested: $CERT_ARN"
echo "⏳ Certificate validation will be completed after DNS configuration"

echo "📋 Step 3: Saving domain configuration..."
# Add domain info to configuration file
cat >> network-config.env << EOF

# Domain Configuration - Added $(date)
export DOMAIN_NAME="$DOMAIN_NAME"
export HOSTED_ZONE_ID="$HOSTED_ZONE"
export CERT_ARN="$CERT_ARN"
export EMAIL="$EMAIL"
EOF

echo "✅ Domain configuration saved"

echo "🎉 Domain setup initiated!"
echo ""
echo "📝 Next Steps:"
echo "   1. Update your domain registrar with these name servers:"
echo "      $NAME_SERVERS"
echo "   2. Wait 24-48 hours for DNS propagation"
echo "   3. SSL certificate will auto-validate via DNS"
echo ""
echo "💡 Domain Structure:"
echo "   - $DOMAIN_NAME → Frontend (React app)"
echo "   - api.$DOMAIN_NAME → Backend API"  
echo "   - www.$DOMAIN_NAME → Redirect to main domain"
echo ""
echo "⚠️  Important: Update name servers at your registrar before proceeding to Week 3"