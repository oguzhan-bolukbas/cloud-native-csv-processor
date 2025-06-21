# EKS Deployment Guide

This guide covers deploying the CSV Processor application to AWS EKS with proper production configurations.

## 🏗️ Infrastructure Overview

### Architecture Components
- **EKS Cluster**: Kubernetes v1.28 with managed node groups
- **Node Groups**: t3.micro SPOT instances (2 nodes, can scale to 3)
- **Networking**: VPC with public/private subnets across 2 AZs
- **Storage**: EBS CSI driver with gp2 storage class
- **Security**: IRSA for AWS service access, IMDSv2 enabled
- **Load Balancing**: AWS Load Balancer Controller for ingress

### Key Features
- **High Availability**: Multi-AZ deployment with pod anti-affinity
- **Auto Scaling**: HPA for both API and nginx components
- **Security**: IRSA instead of hardcoded credentials
- **Cost Optimization**: SPOT instances with proper scaling policies
- **Monitoring**: Metrics server for HPA and observability

## 🚀 Quick Deployment

### Prerequisites
- AWS CLI configured with appropriate permissions
- kubectl installed
- Helm 3.x installed
- Terraform >= 1.0

### One-Command Deployment
```bash
./deploy.sh
```

This script will:
1. Deploy EKS infrastructure with Terraform
2. Configure kubectl
3. Install essential cluster components
4. Deploy the CSV processor application

## 📋 Manual Deployment Steps

### 1. Deploy Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2. Configure kubectl
```bash
aws eks --region eu-north-1 update-kubeconfig --name csv-processor-cluster
```

### 3. Install Cluster Components
```bash
# Install AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=csv-processor-cluster

# Install metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### 4. Deploy Application

#### For Production Environment
```bash
helm install csv-processor ./helm/csv-processor -f ./helm/csv-processor/values-production.yaml
```

## 💰 AWS Free Tier Deployment

### Free Tier Limitations
- **EC2**: 750 hours/month of t2.micro or t3.micro instances
- **EKS**: $0.10/hour for cluster management (not free)
- **EBS**: 30GB of General Purpose SSD storage
- **Data Transfer**: 1GB/month outbound data transfer

### Cost Estimation (Free Tier)
- **EKS Cluster**: ~$72/month (cluster management fee)
- **t3.micro instance**: Free (within 750 hours)
- **EBS Storage**: Free (within 30GB)
- **Estimated Total**: ~$72/month (mainly EKS management fee)

**Note**: EKS cluster management is the main cost. Consider using minikube or k3s locally for development.

## 🔧 Instance Type Analysis

### Current Configuration: t3.micro
- **Specs**: 1 vCPU, 1GB RAM
- **Network**: Up to 5 Gbps
- **EBS**: Up to 2,085 Mbps

### Capacity Analysis
Your application resource requirements:
- API pods: 250m CPU, 256Mi memory (requests)
- Nginx pods: 100m CPU, 128Mi memory (requests)
- **Total per full stack**: ~350m CPU, 384Mi memory

**Verdict**: ✅ **t3.micro is appropriate**
- Can handle 2-3 pod replicas comfortably
- Suitable for development and light production workloads
- SPOT pricing provides 60-70% cost savings
- **Note**: Limited resources may require careful resource management

### Alternative Recommendations
- **Cost-focused**: t3.small (2 vCPU, 2GB) - better balance for light production
- **Balanced**: t3.medium (2 vCPU, 4GB) - recommended for production workloads
- **Performance-focused**: t3.large (2 vCPU, 8GB) - for higher throughput requirements
- **Mixed**: Use node groups with different instance types

## 🛡️ Security Improvements

### What Was Added
1. **IRSA (IAM Roles for Service Accounts)**
   - Eliminates hardcoded AWS credentials
   - Provides least-privilege access to S3
   - Automatic credential rotation

2. **Security Hardening**
   - IMDSv2 enforced on nodes
   - Pod security contexts
   - Non-root container execution
   - Security group rules optimization

3. **Network Security**
   - Private subnets for worker nodes
   - Controlled egress/ingress rules
   - VPC CNI with proper CIDR allocation

## 📊 Production Optimizations

### Resource Configuration
```yaml
# API Service
resources:
  requests:
    cpu: 250m      # Increased from 15m
    memory: 256Mi  # Increased from 64Mi
  limits:
    cpu: 500m
    memory: 512Mi

# HPA Configuration
minReplicas: 2           # HA setup
maxReplicas: 10
targetCPUUtilization: 70 # Conservative threshold
```

### Scaling Behavior
- **Scale-up**: Aggressive (50% increase every 30s)
- **Scale-down**: Conservative (25% decrease every 5 minutes)
- **Stabilization**: Prevents thrashing

## 🔍 Monitoring & Troubleshooting

### Essential Commands
```bash
# Check cluster status
kubectl get nodes
kubectl get pods -A

# Monitor application
kubectl get pods -l app.kubernetes.io/name=csv-processor
kubectl logs -l app.kubernetes.io/name=csv-processor

# Check HPA
kubectl get hpa
kubectl top pods

# Service connectivity
kubectl get svc
kubectl describe svc csv-processor-nginx
```

### Common Issues
1. **Pods stuck in Pending**: Check node capacity and taints
2. **502 Bad Gateway**: Verify nginx configuration and backend connectivity
3. **S3 Access Denied**: Validate IRSA configuration and IAM policies
4. **HPA not scaling**: Ensure metrics-server is running

## 💰 Cost Optimization

### Current Setup Cost Estimation (eu-north-1)
- **t3.micro SPOT**: ~$0.0031/hour × 2 nodes = ~$4.5/month
- **EBS storage**: ~$0.10/GB/month × 100GB = ~$10/month
- **EKS management**: ~$72/month
- **Data transfer**: Variable based on usage
- **Total estimated**: ~$87/month

### Cost Reduction Tips
1. Use SPOT instances (already configured)
2. Right-size based on actual usage
3. Implement cluster autoscaler for node scaling
4. Use Reserved Instances for predictable workloads

## 🔄 CI/CD Integration

### Jenkins Pipeline Integration
```groovy
pipeline {
    agent any
    
    stages {
        stage('Deploy Infrastructure') {
            steps {
                sh 'cd terraform && terraform apply -auto-approve'
            }
        }
        
        stage('Deploy Application') {
            steps {
                sh 'helm upgrade --install csv-processor ./helm/csv-processor -f values-production.yaml'
            }
        }
    }
}
```

## 🧹 Cleanup

### Remove Application
```bash
helm uninstall csv-processor
```

### Remove Infrastructure
```bash
cd terraform
terraform destroy
```

## 📚 Next Steps

1. **Implement monitoring** with Prometheus/Grafana
2. **Set up logging** with ELK stack or CloudWatch
3. **Add ingress controller** for external access
4. **Configure backup strategy** for persistent volumes
5. **Implement GitOps** with ArgoCD or Flux

---

**Note**: This configuration is production-ready with security best practices, cost optimization, and high availability considerations.
