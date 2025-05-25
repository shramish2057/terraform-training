#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' 

# Function to write test results
write_test_result() {
    local test_name=$1
    local result=$2
    local details=$3
    
    if [ "$result" = true ]; then
        echo -e "\n[${GREEN}${test_name}${NC}]"
    else
        echo -e "\n[${RED}${test_name}${NC}]"
    fi
    
    if [ ! -z "$details" ]; then
        echo "$details"
    fi
}

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install it first: brew install jq"
    exit 1
fi

# 1. Check Region and AZs
echo -e "\n${CYAN}=== Testing Region and AZs ===${NC}"
REGION=$(aws configure get region)
AZS=$(aws ec2 describe-availability-zones --region $REGION --query 'AvailabilityZones[*].ZoneName' --output text)

write_test_result "Region Check" "$([ "$REGION" = "us-east-1" ] && echo true || echo false)" "Current region: $REGION"
write_test_result "AZs Check" "$(echo "$AZS" | grep -q "us-east-1a" && echo "$AZS" | grep -q "us-east-1b" && echo true || echo false)" "Available AZs: $AZS"

# 2. Check VPC and Network Setup
echo -e "\n${CYAN}=== Testing VPC and Network Setup ===${NC}"
VPC=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*-vpc" --query 'Vpcs[0]' --output json)
VPC_ID=$(echo $VPC | jq -r '.VpcId')

if [ "$VPC_ID" != "null" ]; then
    SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*]' --output json)
    PUBLIC_SUBNETS=$(echo $SUBNETS | jq '[.[] | select(.Tags[].Value | contains("public-subnet"))] | length')
    PRIVATE_SUBNETS=$(echo $SUBNETS | jq '[.[] | select(.Tags[].Value | contains("private-subnet"))] | length')
    
    write_test_result "VPC Exists" "true" "VPC ID: $VPC_ID"
    write_test_result "Public Subnets" "$([ "$PUBLIC_SUBNETS" = "2" ] && echo true || echo false)" "Found $PUBLIC_SUBNETS public subnets"
    write_test_result "Private Subnets" "$([ "$PRIVATE_SUBNETS" = "2" ] && echo true || echo false)" "Found $PRIVATE_SUBNETS private subnets"
else
    write_test_result "VPC Exists" "false" "No VPC found"
fi

# 3. Check RDS Configuration
echo -e "\n${CYAN}=== Testing RDS Configuration ===${NC}"
RDS=$(aws rds describe-db-instances --query 'DBInstances[0]' --output json)
RDS_INSTANCE_TYPE=$(echo $RDS | jq -r '.DBInstanceClass')
RDS_MULTI_AZ=$(echo $RDS | jq -r '.MultiAZ')

write_test_result "RDS Instance Type" "$([ "$RDS_INSTANCE_TYPE" = "db.m6i.xlarge" ] && echo true || echo false)" "Current instance type: $RDS_INSTANCE_TYPE"
write_test_result "RDS Multi-AZ" "$([ "$RDS_MULTI_AZ" = "true" ] && echo true || echo false)" "Multi-AZ enabled: $RDS_MULTI_AZ"

# 4. Check EC2 Configuration
echo -e "\n${CYAN}=== Testing EC2 Configuration ===${NC}"
EC2_COUNT=$(aws ec2 describe-instances --filters "Name=instance-type,Values=m7i.2xlarge" --query 'Reservations[*].Instances[*]' --output json | jq 'length')
write_test_result "EC2 Instance Type" "$([ "$EC2_COUNT" -gt 0 ] && echo true || echo false)" "Found $EC2_COUNT m7i.2xlarge instances"

# 5. Check Security Groups
echo -e "\n${CYAN}=== Testing Security Groups ===${NC}"
if [ "$VPC_ID" != "null" ]; then
    SG=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[*]' --output json)
    RDS_SG=$(echo $SG | jq '[.[] | select(.GroupName | contains("rds-sg"))] | length')
    RDS_PORT=$(echo $SG | jq '[.[] | select(.IpPermissions[].FromPort == 1433 or .IpPermissions[].ToPort == 1433)] | length')
    
    write_test_result "RDS Security Group" "$([ "$RDS_SG" -gt 0 ] && echo true || echo false)" "RDS Security Group exists"
    write_test_result "RDS Port 1433" "$([ "$RDS_PORT" -gt 0 ] && echo true || echo false)" "Port 1433 is allowed"
else
    write_test_result "RDS Security Group" "false" "No VPC found"
fi

# 6. Check S3 VPC Endpoint
echo -e "\n${CYAN}=== Testing S3 VPC Endpoint ===${NC}"
if [ "$VPC_ID" != "null" ]; then
    ENDPOINTS=$(aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$VPC_ID" --query 'VpcEndpoints[*]' --output json)
    S3_ENDPOINT=$(echo $ENDPOINTS | jq '[.[] | select(.ServiceName | contains("s3"))] | length')
    write_test_result "S3 VPC Endpoint" "$([ "$S3_ENDPOINT" -gt 0 ] && echo true || echo false)" "S3 VPC Endpoint exists"
else
    write_test_result "S3 VPC Endpoint" "false" "No VPC found"
fi

# 7. Check IAM Setup
echo -e "\n${CYAN}=== Testing IAM Setup ===${NC}"
IAM_USER=$(aws iam get-user --user-name tf-manager --query 'User.UserName' --output text 2>/dev/null || echo "")
IAM_ROLE=$(aws iam get-role --role-name "${var.environment}-infra-role" --query 'Role.RoleName' --output text 2>/dev/null || echo "")

write_test_result "IAM User" "$([ "$IAM_USER" = "tf-manager" ] && echo true || echo false)" "IAM User: $IAM_USER"
write_test_result "IAM Role" "$([ "$IAM_ROLE" = "${var.environment}-infra-role" ] && echo true || echo false)" "IAM Role: $IAM_ROLE"

# 8. Check ELB and ASG
echo -e "\n${CYAN}=== Testing ELB and ASG ===${NC}"
ELB=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[0]' --output json)
ASG=$(aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[0]' --output json)
ASG_CAPACITY=$(echo $ASG | jq -r '.DesiredCapacity // 0')

write_test_result "ELB Exists" "$([ "$(echo $ELB | jq -r '.LoadBalancerArn // empty')" != "" ] && echo true || echo false)" "ELB exists"
write_test_result "ASG Exists" "$([ "$(echo $ASG | jq -r '.AutoScalingGroupName // empty')" != "" ] && echo true || echo false)" "ASG exists"
write_test_result "ASG Instance Count" "$([ "$ASG_CAPACITY" -ge 1 ] && echo true || echo false)" "ASG desired capacity: $ASG_CAPACITY"

# 9. Check Terraform State
echo -e "\n${CYAN}=== Testing Terraform State ===${NC}"
S3_BUCKET=$(aws s3 ls s3://terraform-state-prod-001 2>/dev/null && echo "exists" || echo "")
DYNAMO_TABLE=$(aws dynamodb describe-table --table-name terraform-locks --query 'Table.TableName' --output text 2>/dev/null || echo "")

write_test_result "S3 State Bucket" "$([ "$S3_BUCKET" = "exists" ] && echo true || echo false)" "S3 state bucket exists"
write_test_result "DynamoDB Lock Table" "$([ "$DYNAMO_TABLE" = "terraform-locks" ] && echo true || echo false)" "DynamoDB lock table exists"

# 10. Check Tags and Best Practices
echo -e "\n${CYAN}=== Testing Tags and Best Practices ===${NC}"
if [ "$VPC_ID" != "null" ]; then
    TAGS=$(echo $VPC | jq '.Tags[] | select(.Key == "Environment" or .Key == "Project")')
    write_test_result "Resource Tagging" "$([ ! -z "$TAGS" ] && echo true || echo false)" "Resources are properly tagged"
else
    write_test_result "Resource Tagging" "false" "No VPC found"
fi

# Summary
echo -e "\n${YELLOW}=== Test Summary ===${NC}"
TEST_COUNT=$(grep -c "write_test_result" "$0")
echo "Total tests run: $TEST_COUNT" 