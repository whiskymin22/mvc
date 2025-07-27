# Load configuration
source network-config.env

# Get database credentials from Parameter Store
DB_HOST=$(aws ssm get-parameter --name "/${APP_NAME}/db/host" --query 'Parameter.Value' --output text)
DB_USER=$(aws ssm get-parameter --name "/${APP_NAME}/db/user" --query 'Parameter.Value' --output text)
DB_PASSWORD=$(aws ssm get-parameter --name "/${APP_NAME}/db/password" --query 'Parameter.Value' --output text)
DB_NAME=$(aws ssm get-parameter --name "/${APP_NAME}/db/database" --query 'Parameter.Value' --output text)

# Connect to database
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME"
