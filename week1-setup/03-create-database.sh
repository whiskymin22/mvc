#!/bin/bash

# Week 1 - Day 7: Database Setup
# This script creates RDS PostgreSQL instance and configures secrets

set -e
echo "🗄️ Starting database setup..."

# Load configuration
if [ -f "network-config.env" ]; then
    source network-config.env
    echo "✅ Configuration loaded"
else
    echo "❌ network-config.env not found. Please run previous scripts first"
    exit 1
fi

# Generate a secure random password
DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
echo "🔐 Generated secure database password"

echo "📋 Step 1: Creating RDS Subnet Group..."
# Create DB subnet group
aws rds create-db-subnet-group \
    --db-subnet-group-name "${APP_NAME}-db-subnet-group" \
    --db-subnet-group-description "Subnet group for ${APP_NAME} database" \
    --subnet-ids $PRIVATE_SUBNET_1 $PRIVATE_SUBNET_2 \
    --tags "Key=Name,Value=${APP_NAME}-db-subnet-group" "Key=Project,Value=${APP_NAME}"

echo "✅ RDS Subnet Group created"

echo "📋 Step 2: Creating RDS PostgreSQL Instance..."
# Create RDS PostgreSQL instance
RDS_INSTANCE_ID="${APP_NAME}-db"
aws rds create-db-instance \
    --db-instance-identifier $RDS_INSTANCE_ID \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --engine-version 15.4 \
    --master-username dbadmin \
    --master-user-password "$DB_PASSWORD" \
    --allocated-storage 20 \
    --max-allocated-storage 100 \
    --storage-type gp2 \
    --storage-encrypted \
    --vpc-security-group-ids $RDS_SG \
    --db-subnet-group-name "${APP_NAME}-db-subnet-group" \
    --backup-retention-period 7 \
    --backup-window "07:00-09:00" \
    --maintenance-window "sun:09:00-sun:10:00" \
    --multi-az \
    --no-publicly-accessible \
    --db-name expenses \
    --tags "Key=Name,Value=${APP_NAME}-db" "Key=Project,Value=${APP_NAME}" "Key=Environment,Value=development"

echo "✅ RDS PostgreSQL instance creation initiated"
echo "⏳ This will take 10-15 minutes. Waiting for database to be available..."

# Wait for RDS instance to be available
aws rds wait db-instance-available --db-instance-identifier $RDS_INSTANCE_ID

echo "✅ RDS PostgreSQL instance is now available"

# Get RDS endpoint
RDS_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier $RDS_INSTANCE_ID \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text)

echo "✅ RDS Endpoint: $RDS_ENDPOINT"

echo "📋 Step 3: Storing database credentials in Systems Manager Parameter Store..."
# Store database configuration in Parameter Store
aws ssm put-parameter \
    --name "/${APP_NAME}/db/host" \
    --value "$RDS_ENDPOINT" \
    --type "String" \
    --description "Database host for ${APP_NAME}" \
    --tags "Key=Project,Value=${APP_NAME}" \
    --overwrite

aws ssm put-parameter \
    --name "/${APP_NAME}/db/user" \
    --value "dbadmin" \
    --type "String" \
    --description "Database username for ${APP_NAME}" \
    --tags "Key=Project,Value=${APP_NAME}" \
    --overwrite

aws ssm put-parameter \
    --name "/${APP_NAME}/db/password" \
    --value "$DB_PASSWORD" \
    --type "SecureString" \
    --description "Database password for ${APP_NAME}" \
    --tags "Key=Project,Value=${APP_NAME}" \
    --overwrite

aws ssm put-parameter \
    --name "/${APP_NAME}/db/database" \
    --value "expenses" \
    --type "String" \
    --description "Database name for ${APP_NAME}" \
    --tags "Key=Project,Value=${APP_NAME}" \
    --overwrite

aws ssm put-parameter \
    --name "/${APP_NAME}/db/port" \
    --value "5432" \
    --type "String" \
    --description "Database port for ${APP_NAME}" \
    --tags "Key=Project,Value=${APP_NAME}" \
    --overwrite

echo "✅ Database credentials stored in Parameter Store"

echo "📋 Step 4: Creating database initialization script..."
# Create database initialization script
cat > init-database.sql << EOF
-- Database initialization script for Expense Tracker
-- Run this after connecting to the database

-- Create expenses table
CREATE TABLE IF NOT EXISTS expenses(
    expense_id SERIAL PRIMARY KEY,
    title VARCHAR(30) NOT NULL, 
    price DECIMAL(10, 2) NOT NULL, 
    category VARCHAR(30) NOT NULL, 
    essential BOOLEAN NOT NULL, 
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO expenses (title, price, category, essential, created_at) VALUES
('Groceries', 85.50, 'Food', true, CURRENT_TIMESTAMP),
('Netflix Subscription', 15.99, 'Entertainment', false, CURRENT_TIMESTAMP),
('Gasoline', 45.00, 'Transportation', true, CURRENT_TIMESTAMP),
('Coffee', 4.50, 'Food', false, CURRENT_TIMESTAMP);

-- Verify data
SELECT * FROM expenses;

-- Show table structure
\d expenses;
EOF

echo "✅ Database initialization script created: init-database.sql"

echo "📋 Step 5: Creating database connection helper script..."
# Create database connection script
cat > connect-to-db.sh << 'EOF'
#!/bin/bash

# Helper script to connect to the database
# This script will be useful for development and debugging

# Load configuration
source network-config.env

# Get database credentials from Parameter Store
DB_HOST=$(aws ssm get-parameter --name "/${APP_NAME}/db/host" --query 'Parameter.Value' --output text)
DB_USER=$(aws ssm get-parameter --name "/${APP_NAME}/db/user" --query 'Parameter.Value' --output text)
DB_PASSWORD=$(aws ssm get-parameter --name "/${APP_NAME}/db/password" --with-decryption --query 'Parameter.Value' --output text)
DB_NAME=$(aws ssm get-parameter --name "/${APP_NAME}/db/database" --query 'Parameter.Value' --output text)

echo "🔗 Connecting to database..."
echo "Host: $DB_HOST"
echo "User: $DB_USER"
echo "Database: $DB_NAME"
echo ""

# Connect to database
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME"
EOF

chmod +x connect-to-db.sh
echo "✅ Database connection script created: connect-to-db.sh"

echo "📋 Step 6: Updating configuration file..."
# Add database info to configuration file
cat >> network-config.env << EOF

# Database Configuration - Added $(date)
export RDS_INSTANCE_ID="$RDS_INSTANCE_ID"
export RDS_ENDPOINT="$RDS_ENDPOINT"
export DB_PASSWORD="$DB_PASSWORD"
EOF

echo "✅ Database configuration saved"

echo "🎉 Database setup complete!"
echo ""
echo "📝 Summary:"
echo "   - RDS Instance ID: $RDS_INSTANCE_ID"
echo "   - RDS Endpoint: $RDS_ENDPOINT"
echo "   - Database Name: expenses"
echo "   - Username: dbadmin"
echo "   - Password: Stored in Parameter Store"
echo ""
echo "🔧 Database Features:"
echo "   - PostgreSQL 15.4"
echo "   - Multi-AZ deployment (High Availability)"
echo "   - Automated backups (7 days retention)"
echo "   - Storage encryption enabled"
echo "   - Auto-scaling storage (20GB to 100GB)"
echo ""
echo "💡 Next steps:"
echo "   1. Test database connection: ./connect-to-db.sh"
echo "   2. Initialize database: \\i init-database.sql"
echo "   3. Review RDS instance in AWS Console"
echo "   4. Understand database security (private subnets, security groups)"
echo ""
echo "⚠️  Important Notes:"
echo "   - Database is in private subnets (not accessible from internet)"
echo "   - Use bastion host or ECS tasks to connect"
echo "   - Credentials are stored securely in Parameter Store"
echo "   - Multi-AZ provides automatic failover"