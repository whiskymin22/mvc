#!/bin/bash

# =============================================================================
# Week 3 - Domain Integration with Infrastructure
# =============================================================================
# This script connects your domain to the deployed AWS infrastructure
# 
# PREREQUISITES:
# 1. Week 1 domain setup completed (04-setup-domain.sh)
# 2. Infrastructure deployed with Terraform
# 3. DNS propagation completed (24-48 hours)
# 4. SSL certificate validated
#
# WHAT THIS DOES:
# 1. Creates CloudFront distribution with custom domain
# 2. Configures ALB with custom domain for API
# 3. Sets up Route 53 DNS records
# 4. Configures HTTPS redirects
# =============================================================================

set -e
echo "🌐 Configuring domain with infrastructure..."

# Load configuration
if [ -f "../week1-setup/network-config.env" ]; then
    source ../week1-setup/network-config.env
    echo "✅ Configuration loaded for domain: $DOMAIN_NAME"
else
    echo "❌ Please run Week 1 domain setup first"
    exit 1
fi

# Get infrastructure outputs from Terraform
ALB_DNS_NAME=$(terraform output -raw alb_dns_name)
S3_BUCKET_NAME=$(terraform output -raw s3_bucket_name)
CLOUDFRONT_DOMAIN=$(terraform output -raw cloudfront_domain_name 2>/dev/null || echo "")

echo "📋 Step 1: Updating CloudFront Distribution with Custom Domain..."

# Create CloudFront distribution configuration with custom domain
cat > cloudfront-config.json << EOF
{
  "CallerReference": "expense-tracker-$(date +%s)",
  "Comment": "Expense Tracker Frontend - $DOMAIN_NAME",
  "DefaultRootObject": "index.html",
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-$S3_BUCKET_NAME",
        "DomainName": "$S3_BUCKET_NAME.s3-website-us-east-1.amazonaws.com",
        "CustomOriginConfig": {
          "HTTPPort": 80,
          "HTTPSPort": 443,
          "OriginProtocolPolicy": "http-only"
        }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-$S3_BUCKET_NAME",
    "ViewerProtocolPolicy": "redirect-to-https",
    "MinTTL": 0,
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {
        "Forward": "none"
      }
    },
    "TrustedSigners": {
      "Enabled": false,
      "Quantity": 0
    }
  },
  "Aliases": {
    "Quantity": 2,
    "Items": ["$DOMAIN_NAME", "www.$DOMAIN_NAME"]
  },
  "ViewerCertificate": {
    "ACMCertificateArn": "$CERT_ARN",
    "SSLSupportMethod": "sni-only",
    "MinimumProtocolVersion": "TLSv1.2_2021"
  },
  "Enabled": true,
  "PriceClass": "PriceClass_100",
  "CustomErrorResponses": {
    "Quantity": 1,
    "Items": [
      {
        "ErrorCode": 404,
        "ResponsePagePath": "/index.html",
        "ResponseCode": "200",
        "ErrorCachingMinTTL": 300
      }
    ]
  }
}
EOF

# Create or update CloudFront distribution
if [ -z "$CLOUDFRONT_DOMAIN" ]; then
    echo "Creating new CloudFront distribution..."
    CLOUDFRONT_DISTRIBUTION=$(aws cloudfront create-distribution --distribution-config file://cloudfront-config.json --query 'Distribution.Id' --output text)
else
    echo "Updating existing CloudFront distribution..."
    CLOUDFRONT_DISTRIBUTION=$(aws cloudfront list-distributions --query "DistributionList.Items[?Origins.Items[0].DomainName=='$S3_BUCKET_NAME.s3-website-us-east-1.amazonaws.com'].Id" --output text)
fi

echo "✅ CloudFront distribution configured: $CLOUDFRONT_DISTRIBUTION"

# Get CloudFront domain name
CLOUDFRONT_DOMAIN_NAME=$(aws cloudfront get-distribution --id $CLOUDFRONT_DISTRIBUTION --query 'Distribution.DomainName' --output text)

echo "📋 Step 2: Creating Route 53 DNS Records..."

# Create DNS records for frontend (CloudFront)
cat > frontend-dns-records.json << EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$DOMAIN_NAME",
        "Type": "A",
        "AliasTarget": {
          "DNSName": "$CLOUDFRONT_DOMAIN_NAME",
          "EvaluateTargetHealth": false,
          "HostedZoneId": "Z2FDTNDATAQYW2"
        }
      }
    },
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "www.$DOMAIN_NAME",
        "Type": "A",
        "AliasTarget": {
          "DNSName": "$CLOUDFRONT_DOMAIN_NAME",
          "EvaluateTargetHealth": false,
          "HostedZoneId": "Z2FDTNDATAQYW2"
        }
      }
    },
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "api.$DOMAIN_NAME",
        "Type": "A",
        "AliasTarget": {
          "DNSName": "$ALB_DNS_NAME",
          "EvaluateTargetHealth": true,
          "HostedZoneId": "Z35SXDOTRQ7X7K"
        }
      }
    }
  ]
}
EOF

# Apply DNS changes
CHANGE_ID=$(aws route53 change-resource-record-sets \
    --hosted-zone-id $HOSTED_ZONE_ID \
    --change-batch file://frontend-dns-records.json \
    --query 'ChangeInfo.Id' --output text)

echo "✅ DNS records created/updated: $CHANGE_ID"

echo "📋 Step 3: Updating Frontend Configuration..."

# Update React app configuration to use custom domain for API
cat > ../view/src/config.js << EOF
// API Configuration for Production
const config = {
  API_BASE_URL: process.env.NODE_ENV === 'production' 
    ? 'https://api.$DOMAIN_NAME'
    : 'http://localhost:8080',
  
  APP_URL: process.env.NODE_ENV === 'production'
    ? 'https://$DOMAIN_NAME'
    : 'http://localhost:3000'
};

export default config;
EOF

echo "✅ Frontend configuration updated"

echo "📋 Step 4: Updating Backend CORS Configuration..."

# Update backend CORS to allow custom domain
cat >> ../cors-update.md << EOF
# Update your server.js CORS configuration:

\`\`\`javascript
app.use(cors({
  origin: [
    'https://$DOMAIN_NAME',
    'https://www.$DOMAIN_NAME',
    'http://localhost:3000' // for development
  ],
  credentials: true
}));
\`\`\`
EOF

echo "✅ CORS configuration guide created"

# Clean up temporary files
rm -f cloudfront-config.json frontend-dns-records.json

echo "🎉 Domain configuration completed!"
echo ""
echo "🌐 Your URLs:"
echo "   Frontend: https://$DOMAIN_NAME"
echo "   Frontend (www): https://www.$DOMAIN_NAME"
echo "   API: https://api.$DOMAIN_NAME"
echo ""
echo "⏳ DNS propagation may take 5-10 minutes"
echo "🔒 HTTPS certificates are automatically managed by AWS"
echo ""
echo "📝 Next Steps:"
echo "   1. Update your React app imports to use the config file"
echo "   2. Update backend CORS settings (see cors-update.md)"
echo "   3. Rebuild and redeploy your applications"
echo "   4. Test all endpoints with your custom domain"

# Save domain URLs to config
cat >> ../week1-setup/network-config.env << EOF

# Domain URLs - Added $(date)
export FRONTEND_URL="https://$DOMAIN_NAME"
export API_URL="https://api.$DOMAIN_NAME"
export CLOUDFRONT_DISTRIBUTION_ID="$CLOUDFRONT_DISTRIBUTION"
EOF