# AWS User Setup Guide - Manual Steps

## Manual AWS IAM User Creation

### Step 1: Access AWS Console
1. Go to [AWS Console](https://console.aws.amazon.com/)
2. Sign in with your root account or admin account

### Step 2: Create IAM User
1. Navigate to **IAM** → **Users**
2. Click **Create user**
3. Username: `eks-terraform-deployer`
4. Select **Programmatic access**

### Step 3: Attach Permissions
- Attach existing policy: `AdministratorAccess`

### Step 4: Get Access Keys
1. After user creation, go to **Security credentials** tab
2. Click **Create access key**
3. Choose **Command Line Interface (CLI)**
4. **Download the CSV** or copy the credentials

### Step 5: Configure AWS CLI
```bash
# Configure new profile
aws configure --profile eks-terraform-deployer

# Enter the credentials when prompted:
# AWS Access Key ID: [Your Access Key]
# AWS Secret Access Key: [Your Secret Key]  
# Default region: eu-north-1
# Default output format: json

# Set as active profile
export AWS_PROFILE=eks-terraform-deployer

# Test the connection
aws sts get-caller-identity
```

### Step 6: Run the Deployment
Once configured, run:
```bash
./deploy.sh
```
