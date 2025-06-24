# EKS Deployment & Cleanup Guide

## AWS Infrastructure Cleanup Guide

This guide provides step-by-step instructions to completely remove all AWS resources for the CSV Processor application to avoid ongoing charges.

### Current AWS Services to Clean Up
Based on your billing, the following services need to be cleaned up:
- **Elastic Container Service for Kubernetes (EKS)** - $9.14
- **Elastic Compute Cloud (EC2)** - $4.60
- **Key Management Service (KMS)** - $0.19
- **Virtual Private Cloud (VPC)** - $0.14
- **CloudWatch** - $0.00
- **Data Transfer** - $0.00
- **DynamoDB** - $0.00
- **Elastic Load Balancing (ELB)** - $0.00
- **Secrets Manager** - $0.00
- **Simple Storage Service (S3)** - $0.00

---

## Prerequisites

Before starting the cleanup, ensure you have:
- AWS CLI configured with appropriate permissions
- kubectl configured to connect to your EKS cluster
- Terraform installed (if you used Terraform for deployment)
- Access to the AWS Management Console

---

## Step-by-Step Cleanup Process

### Step 1: Backup Important Data (Optional)

If you have important data in S3 or any other storage, back it up first:

```bash
# Download all files from S3 bucket (replace with your bucket name)
aws s3 sync s3://your-csv-processor-bucket ./backup/s3-data/

# Export any important configurations
kubectl get all --all-namespaces -o yaml > backup/k8s-resources.yaml
```

### Step 2: Delete Kubernetes Resources

First, delete all Kubernetes resources to prevent hanging resources:

```bash
# Delete the application deployment
kubectl delete deployment csv-processor -n default

# Delete services
kubectl delete service csv-processor -n default
kubectl delete service csv-processor-nginx -n default

# Delete ingress
kubectl delete ingress csv-processor-ingress -n default

# Delete configmaps and secrets
kubectl delete configmap csv-processor-config -n default
kubectl delete secret csv-processor-secret -n default

# Delete persistent volume claims
kubectl delete pvc --all -n default

# Delete horizontal pod autoscalers
kubectl delete hpa --all -n default

# Delete all resources in default namespace
kubectl delete all --all -n default

# Delete any custom namespaces if created
kubectl get namespaces
kubectl delete namespace <your-custom-namespace>
```

### Step 3: Delete EKS Cluster and Node Groups

#### Option A: Using Terraform (Recommended if you used Terraform)

```bash
# Navigate to terraform directory
cd terraform/

# Initialize Terraform
terraform init

# Review what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy -auto-approve
```

#### Option B: Using AWS CLI

```bash
# Get cluster name
aws eks list-clusters --region eu-north-1

# Delete node groups first
aws eks list-nodegroups --cluster-name csv-processor-cluster --region eu-north-1

# Delete each node group
aws eks delete-nodegroup \
    --cluster-name csv-processor-cluster \
    --nodegroup-name <nodegroup-name> \
    --region eu-north-1

# Wait for node groups to be deleted (this can take 10-15 minutes)
aws eks describe-nodegroup \
    --cluster-name csv-processor-cluster \
    --nodegroup-name <nodegroup-name> \
    --region eu-north-1

# Delete the EKS cluster
aws eks delete-cluster \
    --name csv-processor-cluster \
    --region eu-north-1

# Wait for cluster deletion
aws eks describe-cluster \
    --name csv-processor-cluster \
    --region eu-north-1
```

### Step 4: Delete Load Balancers

```bash
# List all load balancers
aws elbv2 describe-load-balancers --region eu-north-1

# Delete each load balancer
aws elbv2 delete-load-balancer \
    --load-balancer-arn <load-balancer-arn> \
    --region eu-north-1

# List classic load balancers
aws elb describe-load-balancers --region eu-north-1

# Delete classic load balancers if any
aws elb delete-load-balancer \
    --load-balancer-name <load-balancer-name> \
    --region eu-north-1
```

### Step 5: Clean Up VPC and Networking

⚠️ **IMPORTANT**: Delete NAT Gateways first as they incur hourly charges!

```bash
# List VPCs
aws ec2 describe-vpcs --region eu-north-1

# Delete NAT Gateways (they cost money) - ONE BY ONE
aws ec2 describe-nat-gateways --region eu-north-1 --query 'NatGateways[*].{ID:NatGatewayId,State:State,VPC:VpcId}' --output table

# Delete each NAT Gateway individually using actual IDs from above
aws ec2 delete-nat-gateway --nat-gateway-id <nat-gateway-id> --region eu-north-1

# Verify deletion status
aws ec2 describe-nat-gateways --region eu-north-1 --query 'NatGateways[*].{ID:NatGatewayId,State:State}' --output table
 
# Release Elastic IPs associated with NAT Gateways
aws ec2 describe-addresses --region eu-north-1 --query 'Addresses[*].{AllocationId:AllocationId,PublicIp:PublicIp}' --output table

# Release each Elastic IP
aws ec2 release-address --allocation-id <allocation-id> --region eu-north-1

# Delete Internet Gateway
aws ec2 describe-internet-gateways --region eu-north-1 --query 'InternetGateways[*].{ID:InternetGatewayId,VPC:Attachments[0].VpcId}' --output table

# Detach and delete Internet Gateway
aws ec2 detach-internet-gateway --internet-gateway-id <igw-id> --vpc-id <vpc-id> --region eu-north-1
aws ec2 delete-internet-gateway --internet-gateway-id <igw-id> --region eu-north-1

# Delete route tables (except main)
aws ec2 describe-route-tables --region eu-north-1 --query 'RouteTables[*].{ID:RouteTableId,VPC:VpcId,Main:Associations[0].Main}' --output table

# Delete custom route tables (where Main != True)
aws ec2 delete-route-table --route-table-id <route-table-id> --region eu-north-1

# Delete subnets
aws ec2 describe-subnets --region eu-north-1 --query 'Subnets[*].{SubnetId:SubnetId,VpcId:VpcId}' --output table

# Delete each subnet
aws ec2 delete-subnet --subnet-id <subnet-id> --region eu-north-1

# Delete security groups (except default)
aws ec2 describe-security-groups --region eu-north-1 --query 'SecurityGroups[*].{GroupId:GroupId,GroupName:GroupName,VpcId:VpcId}' --output table

# Note: If security groups have dependencies, revoke rules first:
# aws ec2 revoke-security-group-ingress --group-id <sg-id> --source-group <source-sg-id> --protocol tcp --port <port> --region eu-north-1

# Delete custom security groups
aws ec2 delete-security-group --group-id <security-group-id> --region eu-north-1

# Finally, delete the VPC
aws ec2 delete-vpc --vpc-id <vpc-id> --region eu-north-1
```

### Step 6: Delete S3 Buckets

```bash
# List all S3 buckets
aws s3 ls

# Empty the bucket first (this removes all objects and versions)
aws s3 rm s3://your-csv-processor-bucket --recursive

# Delete all object versions if versioning is enabled
aws s3api delete-objects \
    --bucket your-csv-processor-bucket \
    --delete "$(aws s3api list-object-versions \
        --bucket your-csv-processor-bucket \
        --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

# Delete all delete markers
aws s3api delete-objects \
    --bucket your-csv-processor-bucket \
    --delete "$(aws s3api list-object-versions \
        --bucket your-csv-processor-bucket \
        --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"

# Delete the bucket
aws s3 rb s3://your-csv-processor-bucket --force
```

### Step 7: Clean Up EC2 Instances and Related Resources

```bash
# List all EC2 instances
aws ec2 describe-instances --region eu-north-1

# Terminate any remaining instances
aws ec2 terminate-instances \
    --instance-ids <instance-id> \
    --region eu-north-1

# Delete key pairs if created
aws ec2 describe-key-pairs --region eu-north-1
aws ec2 delete-key-pair \
    --key-name <key-name> \
    --region eu-north-1

# Delete any EBS volumes
aws ec2 describe-volumes --region eu-north-1
aws ec2 delete-volume \
    --volume-id <volume-id> \
    --region eu-north-1

# Delete snapshots
aws ec2 describe-snapshots --owner-ids self --region eu-north-1
aws ec2 delete-snapshot \
    --snapshot-id <snapshot-id> \
    --region eu-north-1
```

### Step 8: Clean Up IAM Roles and Policies

```bash
# List IAM roles related to EKS
aws iam list-roles --query 'Roles[?contains(RoleName, `eks`) || contains(RoleName, `csv-processor`)].RoleName'

# For each role, detach policies and delete
aws iam list-attached-role-policies --role-name <role-name>
aws iam detach-role-policy \
    --role-name <role-name> \
    --policy-arn <policy-arn>

# Delete instance profiles
aws iam list-instance-profiles-for-role --role-name <role-name>
aws iam remove-role-from-instance-profile \
    --instance-profile-name <instance-profile-name> \
    --role-name <role-name>
aws iam delete-instance-profile \
    --instance-profile-name <instance-profile-name>

# Delete the role
aws iam delete-role --role-name <role-name>

# Delete custom policies
aws iam list-policies --scope Local
aws iam delete-policy --policy-arn <policy-arn>
```

### Step 9: Clean Up CloudWatch Resources

```bash
# Delete CloudWatch Log Groups
aws logs describe-log-groups --region eu-north-1

# Delete each log group
aws logs delete-log-group \
    --log-group-name <log-group-name> \
    --region eu-north-1

# Delete CloudWatch Alarms
aws cloudwatch describe-alarms --region eu-north-1

# Delete each alarm
aws cloudwatch delete-alarms \
    --alarm-names <alarm-name> \
    --region eu-north-1
```

### Step 10: Clean Up KMS Keys

⚠️ **Important**: Only delete customer-managed keys, not AWS-managed keys!

```bash
# List KMS keys
aws kms list-keys --region eu-north-1

# Check if key is customer-managed before deletion
aws kms describe-key --key-id <key-id> --region eu-north-1 --query 'KeyMetadata.{KeyManager:KeyManager,Description:Description}'

# Schedule deletion only for customer-managed keys (minimum 7 days)
aws kms schedule-key-deletion \
    --key-id <key-id> \
    --pending-window-in-days 7 \
    --region eu-north-1
```

### Step 11: Clean Up Secrets Manager

```bash
# List secrets
aws secretsmanager list-secrets --region eu-north-1

# Delete each secret
aws secretsmanager delete-secret \
    --secret-id <secret-name> \
    --force-delete-without-recovery \
    --region eu-north-1
```

### Step 12: Verify Complete Cleanup

```bash
# Comprehensive verification of resource cleanup
echo "=== CLEANUP VERIFICATION ==="
echo "EKS Clusters:"
aws eks list-clusters --region eu-north-1

echo "EC2 Instances:"
aws ec2 describe-instances --region eu-north-1 --query 'Reservations[*].Instances[?State.Name!=`terminated`].{ID:InstanceId,State:State.Name}' --output table

echo "NAT Gateways:"
aws ec2 describe-nat-gateways --region eu-north-1 --query 'NatGateways[?State!=`deleted`].{ID:NatGatewayId,State:State}' --output table

echo "Load Balancers:"
aws elbv2 describe-load-balancers --region eu-north-1 --query 'LoadBalancers[*].LoadBalancerName' --output table

echo "VPCs:"
aws ec2 describe-vpcs --region eu-north-1 --query 'Vpcs[?IsDefault==`false`].VpcId' --output table

echo "S3 Buckets:"
aws s3 ls

echo "CloudWatch Log Groups:"
aws logs describe-log-groups --region eu-north-1 --query 'logGroups[?contains(logGroupName, `eks`) || contains(logGroupName, `csv-processor`)].logGroupName' --output table
```

---

## Automated Cleanup Script

You can create a script to automate most of the cleanup process:

```bash
#!/bin/bash

# Set variables
REGION="eu-north-1"
CLUSTER_NAME="csv-processor-cluster"
BUCKET_NAME="your-csv-processor-bucket"

echo "Starting AWS cleanup for CSV Processor..."

# 1. Delete Kubernetes resources
echo "Deleting Kubernetes resources..."
kubectl delete all --all -n default
kubectl delete pvc --all -n default
kubectl delete hpa --all -n default

# 2. Delete EKS cluster (using Terraform if available)
if [ -f "terraform/terraform.tfstate" ]; then
    echo "Destroying infrastructure with Terraform..."
    cd terraform/
    terraform destroy -auto-approve
    cd ..
else
    echo "Manually delete EKS cluster and node groups..."
fi

# 3. Empty and delete S3 bucket
echo "Cleaning up S3 bucket..."
aws s3 rm s3://$BUCKET_NAME --recursive
aws s3 rb s3://$BUCKET_NAME --force

# 4. Delete CloudWatch log groups
echo "Deleting CloudWatch log groups..."
aws logs describe-log-groups --region $REGION --query 'logGroups[].logGroupName' --output text | \
    xargs -I {} aws logs delete-log-group --log-group-name {} --region $REGION

echo "Cleanup completed! Please verify in AWS Console that all resources are deleted."
```

---

## Important Notes

1. **Terraform State**: If you used Terraform, the `terraform destroy` command should handle most of the cleanup automatically.

2. **Billing**: It may take 24-48 hours for the charges to stop appearing in your AWS billing.

3. **Data Loss**: This process will permanently delete all data. Make sure to backup anything important.

4. **Order Matters**: Follow the steps in order, as some resources depend on others.

5. **Verification**: Always verify in the AWS Console that resources are actually deleted.

6. **Costs**: Some resources like NAT Gateways and Elastic IPs incur charges even when not in use, so prioritize deleting these first.

---

## Troubleshooting

### Common Issues:

1. **"DependencyViolation" errors**: Some resources can't be deleted because others depend on them. Delete dependent resources first.

2. **"Resource in use" errors**: Wait for resources to fully stop before attempting deletion.

3. **Permission errors**: Ensure your AWS credentials have sufficient permissions for deletion.

4. **Terraform state issues**: If Terraform state is corrupted, you may need to manually delete resources.

### Quick Command to Check Remaining Resources:

```bash
# Run this command to get a summary of remaining resources
aws resourcegroupstaggingapi get-resources --region eu-north-1 --query 'ResourceTagMappingList[?Tags[?Key==`Name` && contains(Value, `csv-processor`)]]'
```

This will help you identify any remaining resources tagged with your project name.

---

## IMMEDIATE ACTION: Step-by-Step NAT Gateway Deletion

**NAT Gateways are expensive - Delete these FIRST to stop charges immediately!**

### Step 1: Find Your NAT Gateways

```bash
# List all NAT Gateways with their IDs and states
aws ec2 describe-nat-gateways --region eu-north-1 --query 'NatGateways[*].{ID:NatGatewayId,State:State,VPC:VpcId}' --output table
```

### Step 2: Delete Each NAT Gateway (One by One)

```bash
# First, get the actual NAT Gateway IDs from the previous command
# Then delete each one individually:

# Delete NAT Gateway 1 (replace nat-xxxxxxxxx with actual ID)
aws ec2 delete-nat-gateway --nat-gateway-id nat-xxxxxxxxx --region eu-north-1

# Delete NAT Gateway 2 (replace nat-yyyyyyyyy with actual ID)  
aws ec2 delete-nat-gateway --nat-gateway-id nat-yyyyyyyyy --region eu-north-1

# Check deletion status
aws ec2 describe-nat-gateways --region eu-north-1 --query 'NatGateways[*].{ID:NatGatewayId,State:State}' --output table
```

### Step 3: Release Associated Elastic IPs

```bash
# List Elastic IP addresses
aws ec2 describe-addresses --region eu-north-1 --query 'Addresses[*].{AllocationId:AllocationId,PublicIp:PublicIp,AssociationId:AssociationId}' --output table

# Release each Elastic IP (replace eipalloc-xxxxxxxxx with actual allocation ID)
aws ec2 release-address --allocation-id eipalloc-xxxxxxxxx --region eu-north-1
aws ec2 release-address --allocation-id eipalloc-yyyyyyyyy --region eu-north-1
```

### Step 4: Verify NAT Gateways are Deleted

```bash
# This should show no NAT Gateways or show them as "deleted"
aws ec2 describe-nat-gateways --region eu-north-1
```

---

## ⚠️ CRITICAL: Post-Cleanup Cost Investigation

If costs continue or increase after cleanup, check these potential causes:

### 1. EKS Extended Support Charges
**"Amazon Elastic Container Service for Kubernetes ExtendedSupport"** can charge $30+ per cluster if:
- EKS cluster versions are end-of-life and require extended support
- Charges apply even after cluster deletion for the billing period
- Check AWS billing details for exact reason

### 2. Hidden or Missed Resources
Run these commands immediately to check for missed resources:

```bash
# Check for any remaining EKS clusters in ALL regions
aws eks list-clusters --region us-east-1
aws eks list-clusters --region us-west-2
aws eks list-clusters --region eu-west-1
aws eks list-clusters --region eu-north-1

# Check for running EC2 instances in all regions
aws ec2 describe-instances --region eu-north-1 --query 'Reservations[*].Instances[?State.Name==`running`].{ID:InstanceId,Type:InstanceType,State:State.Name}' --output table

# Check for active NAT Gateways
aws ec2 describe-nat-gateways --region eu-north-1 --query 'NatGateways[?State==`available`].{ID:NatGatewayId,State:State}' --output table

# Check for Load Balancers
aws elbv2 describe-load-balancers --region eu-north-1 --query 'LoadBalancers[*].{Name:LoadBalancerName,State:State.Code}' --output table

# Check for RDS instances
aws rds describe-db-instances --region eu-north-1 --query 'DBInstances[*].{ID:DBInstanceIdentifier,Status:DBInstanceStatus}' --output table

# Check billing for current month
aws ce get-cost-and-usage --time-period Start=2025-06-01,End=2025-06-23 --granularity DAILY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE
```

### 3. Immediate Actions

1. **Check AWS Billing Dashboard** for detailed cost breakdown
2. **Verify region** - resources might exist in different regions
3. **Check for Auto Scaling Groups** that might have recreated instances
4. **Look for reserved instances** or savings plans still active

### 4. Emergency Resource Check Script

```bash
#!/bin/bash
echo "=== EMERGENCY COST INVESTIGATION ==="
regions=("us-east-1" "us-west-2" "eu-west-1" "eu-north-1" "ap-southeast-1")

for region in "${regions[@]}"; do
    echo "Checking region: $region"
    echo "EKS Clusters:"
    aws eks list-clusters --region $region 2>/dev/null
    echo "Running EC2:"
    aws ec2 describe-instances --region $region --query 'Reservations[*].Instances[?State.Name==`running`].InstanceId' --output text 2>/dev/null
    echo "NAT Gateways:"
    aws ec2 describe-nat-gateways --region $region --query 'NatGateways[?State==`available`].NatGatewayId' --output text 2>/dev/null
    echo "---"
done
```

---