# Documentation Index

Welcome to the CSV Processor documentation! This directory contains comprehensive guides for users, developers, and operators.

## 📖 Quick Navigation

### 🏗️ Architecture & Design
- **[Architecture Overview](./architecture.md)** - System design, components, and data flow

### 👨‍💻 For Developers
- **[Development Guide](./guides/development-guide.md)** - Setup, coding standards, and contribution guidelines
- **[API Reference](./api/)** - Complete REST API documentation with examples

### 👤 For Users
- **[User Guide](./guides/user-guide.md)** - How to use the application effectively

### 🚀 Deployment & Operations
- **[Deployment Guides](./guides/deployment/)** - Multiple deployment scenarios
  - [Local Kubernetes Setup](./guides/deployment/local-kubernetes.md) - Minikube deployment instructions
  - [EKS Deployment Guide](./guides/deployment/eks-deployment.md) - AWS EKS deployment and cleanup
  - [AWS Setup Guide](./guides/deployment/aws-setup.md) - Manual AWS configuration steps

### 🛡️ Security & Operations
- **[Operations Documentation](./operations/)** - Security and monitoring guides
  - [Security Considerations](./operations/security.md) - Security architecture and best practices
  - [Performance & Monitoring](./operations/performance-monitoring.md) - Monitoring setup and optimization

### 🔧 Component Documentation
- **[Helm Chart](../helm/csv-processor/README.md)** - Kubernetes deployment configuration
- **[Terraform](../terraform/README.md)** - Infrastructure as Code documentation
- **[HPA Testing](../hpa-testing/README.md)** - Horizontal Pod Autoscaler testing suite

---

## 📚 Documentation by Audience

### New Users
1. Start with [User Guide](./guides/user-guide.md)
2. Review [Architecture Overview](./architecture.md) for context
3. Check [API Reference](./api/) for integration

### Developers
1. Read [Development Guide](./guides/development-guide.md) for setup
2. Study [Architecture Overview](./architecture.md) for system understanding
3. Reference [API Documentation](./api/) for implementation details
4. Follow [Security Considerations](./operations/security.md) for secure coding

### DevOps/Operators
1. Review [Architecture Overview](./architecture.md) for system design
2. Choose appropriate deployment guide from [Deployment Guides](./guides/deployment/)
3. Implement [Security Considerations](./operations/security.md)
4. Set up [Performance Monitoring](./operations/performance-monitoring.md)

### System Architects
1. Study [Architecture Overview](./architecture.md) for design decisions
2. Review [Security Considerations](./operations/security.md) for compliance
3. Examine [Performance Monitoring](./operations/performance-monitoring.md) for scalability

---

## 🔄 Documentation Updates

This documentation is actively maintained. When making changes:

1. **Keep it current**: Update docs with code changes
2. **Be comprehensive**: Include examples and explanations
3. **Stay organized**: Use the established folder structure
4. **Link appropriately**: Cross-reference related documentation
5. **Consider your audience**: Write for the intended reader

## 📝 Contributing to Documentation

We welcome documentation improvements! Please:

- Follow the existing style and structure
- Test all code examples and links
- Update the relevant index files
- Submit pull requests with clear descriptions

## 🆘 Getting Help

If you can't find what you're looking for:

1. Check the [FAQ sections](./guides/user-guide.md#frequently-asked-questions) in relevant guides
2. Search the [API documentation](./api/README.md) for specific endpoints
3. Review [troubleshooting sections](./operations/performance-monitoring.md#troubleshooting-performance-issues)
4. Create an issue with your question

---

**Last Updated**: June 2025
**Version**: 1.0.0
