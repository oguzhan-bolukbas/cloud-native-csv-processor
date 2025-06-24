# Deployment Guides

This section contains comprehensive deployment guides for different environments and scenarios.

## 🚀 Available Deployment Options

### Local Development
- **[Local Kubernetes](./local-kubernetes.md)** - Deploy on Minikube for local development and testing
  - Complete Minikube setup
  - AWS Secrets Store CSI Driver configuration
  - Local testing procedures
  - Troubleshooting common issues

### Cloud Production
- **[EKS Deployment](./eks-deployment.md)** - Production deployment on AWS EKS
  - Complete EKS cluster setup
  - Production-ready configuration
  - Cleanup and cost management
  - Scaling and monitoring

### AWS Configuration
- **[AWS Setup](./aws-setup.md)** - Manual AWS account and credential setup
  - IAM user creation
  - AWS CLI configuration
  - Permission management
  - Security best practices

## 🎯 Deployment Path by Environment

### Development Environment
1. Start with [AWS Setup](./aws-setup.md) for credentials
2. Follow [Local Kubernetes](./local-kubernetes.md) for Minikube deployment
3. Test your changes locally before production

### Staging/Production Environment
1. Complete [AWS Setup](./aws-setup.md) for production credentials
2. Follow [EKS Deployment](./eks-deployment.md) for cloud deployment
3. Implement monitoring and scaling

## 📋 Deployment Comparison

| Environment | Guide | Complexity | Cost | Use Case |
|-------------|-------|------------|------|----------|
| **Local** | [Minikube](./local-kubernetes.md) | Medium | Free | Development, Testing |
| **AWS EKS** | [EKS Deployment](./eks-deployment.md) | High | $$$ | Production, Staging |
| **AWS Setup** | [AWS Config](./aws-setup.md) | Low | Free | Prerequisites |

## 🛠️ Prerequisites

Before starting any deployment:
- [ ] Docker installed and running
- [ ] kubectl command-line tool
- [ ] Helm 3.0+ package manager
- [ ] AWS CLI configured (for cloud deployments)
- [ ] Basic understanding of Kubernetes concepts

## 🔧 Common Deployment Tasks

### Infrastructure as Code
All deployments use:
- **Terraform** for infrastructure provisioning
- **Helm Charts** for Kubernetes deployments
- **Docker Images** from DockerHub registry

### Configuration Management
- Environment variables via ConfigMaps
- Secrets via AWS Secrets Manager
- Horizontal Pod Autoscaling (HPA)
- Persistent storage for temporary files

## 🆘 Deployment Troubleshooting

### Common Issues
- **Pod failures**: Check logs with `kubectl logs`
- **Service access**: Verify port-forwarding and ingress
- **AWS permissions**: Ensure proper IAM roles
- **Resource limits**: Monitor CPU/memory usage

### Getting Help
1. Check the troubleshooting sections in each guide
2. Review the [operations documentation](../operations/)
3. Examine Kubernetes events: `kubectl get events`
4. Create an issue with specific error messages

## 📚 Related Documentation

- **[Architecture](../architecture.md)** - System design and components
- **[Security](../operations/security.md)** - Security considerations for deployment
- **[Performance](../operations/performance-monitoring.md)** - Monitoring and optimization
- **[API Reference](../api/)** - For testing deployments
