# Architecture Overview

## System Architecture

The CSV Processor is a cloud-native application designed to handle CSV file uploads, processing, and storage with high availability and scalability. The system follows a microservices architecture deployed on Kubernetes.

### High-Level Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Internet      │    │   Kubernetes     │    │   AWS Cloud    │
│                 │    │   Cluster        │    │                 │
│  ┌───────────┐  │    │ ┌──────────────┐ │    │ ┌─────────────┐ │
│  │  Users    │──┼────┼→│ Ingress      │ │    │ │ S3 Bucket   │ │
│  └───────────┘  │    │ │ Controller   │ │    │ │ (CSV Files) │ │
└─────────────────┘    │ └──────────────┘ │    │ └─────────────┘ │
                       │         │        │    │        ▲        │
                       │ ┌──────────────┐ │    │        │        │
                       │ │   Nginx      │ │    │        │        │
                       │ │   (Proxy)    │ │    │        │        │
                       │ └──────────────┘ │    │        │        │
                       │         │        │    │        │        │
                       │ ┌──────────────┐ │    │        │        │
                       │ │  Node.js     │ │    │        │        │
                       │ │  App         │◄┼────┼────────┘        │
                       │ │              │ │    │                 │
                       │ └──────────────┘ │    │ ┌─────────────┐ │
                       │         │        │    │ │ Secrets     │ │
                       │ ┌──────────────┐ │    │ │ Manager     │ │
                       │ │  Shared      │ │    │ └─────────────┘ │
                       │ │  Storage     │ │    └─────────────────┘
                       │ │  (PVC)       │ │
                       │ └──────────────┘ │
                       └──────────────────┘
```

## Component Overview

### 1. Frontend Layer
- **Nginx Reverse Proxy**: Handles static file serving and request routing
- **Web Interface**: Simple HTML/CSS/JS interface for file uploads
- **Shared Volume**: Static assets served directly by Nginx for performance

### 2. Application Layer
- **Node.js Application**: Express.js-based REST API
- **CSV Parser**: Processes CSV files line by line
- **File Upload Handler**: Manages multipart file uploads using Multer
- **S3 Integration**: Uploads processed files to AWS S3

### 3. Infrastructure Layer
- **Kubernetes Cluster**: Container orchestration platform
- **Helm Charts**: Templated Kubernetes deployments
- **Horizontal Pod Autoscaler**: Automatic scaling based on CPU/memory metrics
- **ConfigMaps & Secrets**: Configuration and secret management

### 4. Storage Layer
- **AWS S3**: Object storage for CSV files with intelligent tiering
- **S3 Lifecycle Management**: Automatic cost optimization through storage class transitions
  - **Standard (0-30 days)**: Immediate access for recent uploads
  - **Standard-IA (30-90 days)**: Infrequent access for older files
  - **Glacier (90-365 days)**: Long-term archival for compliance
  - **Deep Archive (365+ days)**: Lowest cost for long-term retention
- **Persistent Volumes**: Temporary file storage in Kubernetes

### 5. Security Layer
- **AWS Secrets Manager**: Secure credential storage
- **CSI Driver**: Kubernetes secrets injection
- **IAM Roles**: Fine-grained AWS permissions
- **Service Accounts**: Kubernetes RBAC

## Data Flow

### File Upload Process
1. **User Upload**: User selects CSV file through web interface
2. **Nginx Proxy**: Request routed to Node.js application
3. **File Validation**: Application validates file format and size
4. **CSV Processing**: File parsed line by line, data displayed in browser
5. **S3 Upload**: Processed file uploaded to designated S3 bucket
6. **Response**: User receives confirmation with file details

### Auto-Scaling Process
1. **Metrics Collection**: Kubernetes metrics server collects pod resource usage
2. **HPA Evaluation**: Horizontal Pod Autoscaler evaluates scaling rules
3. **Scale Decision**: Based on CPU/memory thresholds, scaling triggered
4. **Pod Management**: Kubernetes creates/destroys pods as needed
5. **Load Distribution**: Service automatically distributes traffic

### S3 Storage Lifecycle Process
1. **Initial Upload**: CSV files stored in S3 Standard storage class
2. **30-Day Transition**: Files automatically moved to Standard-IA for cost savings
3. **90-Day Transition**: Files moved to Glacier for long-term archival
4. **365-Day Transition**: Files moved to Deep Archive for maximum cost efficiency
5. **7-Year Retention**: Files automatically deleted after 7 years for compliance

## Deployment Environments

### Development
- **Local Minikube**: Single-node cluster for development
- **Docker Compose**: Alternative local development setup
- **Port Forwarding**: Access via kubectl port-forward

### Staging/Production
- **AWS EKS**: Managed Kubernetes service
- **Multi-AZ Deployment**: High availability across availability zones
- **Node Groups**: Mix of on-demand and spot instances
- **Load Balancer**: AWS Application Load Balancer integration

## S3 Storage Strategy

### Storage Class Transitions
The application implements intelligent S3 lifecycle management to optimize costs while maintaining data accessibility:

| Time Period | Storage Class | Cost | Access Pattern | Use Case |
|-------------|---------------|------|----------------|----------|
| 0-30 days | **Standard** | Highest | Frequent access | Recent uploads, active processing |
| 30-90 days | **Standard-IA** | Medium | Infrequent access | Reference data, occasional retrieval |
| 90-365 days | **Glacier** | Low | Archival | Compliance, backup, long-term storage |
| 365+ days | **Deep Archive** | Lowest | Rare access | Long-term compliance, regulatory requirements |

### Cost Optimization Benefits
- **Up to 60% cost reduction** after 30 days (Standard-IA)
- **Up to 80% cost reduction** after 90 days (Glacier)
- **Up to 95% cost reduction** after 365 days (Deep Archive)
- **Automatic cleanup** after 7 years to prevent indefinite storage costs

### Data Retrieval Options
- **Standard/Standard-IA**: Immediate retrieval
- **Glacier**: 1-5 minutes (Expedited), 3-5 hours (Standard), 5-12 hours (Bulk)
- **Deep Archive**: 12 hours (Standard), 48 hours (Bulk)

### Compliance & Governance
- **Version Control**: S3 versioning enabled with 30-day retention for old versions
- **Encryption**: Server-side encryption (AES-256) for all storage classes
- **Access Control**: IAM policies restrict access to authorized services only
- **Audit Trail**: CloudTrail logging for all S3 operations

## Technology Stack

### Core Technologies
- **Runtime**: Node.js 18+ (LTS)
- **Framework**: Express.js
- **Container**: Docker (multi-stage builds)
- **Orchestration**: Kubernetes 1.19+

### AWS Services
- **EKS**: Elastic Kubernetes Service
- **S3**: Simple Storage Service
- **Secrets Manager**: Secure configuration storage
- **VPC**: Virtual Private Cloud
- **IAM**: Identity and Access Management

### DevOps Tools
- **Terraform**: Infrastructure as Code
- **Helm**: Kubernetes package manager
- **Jenkins**: CI/CD pipeline automation
- **Docker Hub**: Container image registry

## Design Principles

### Cloud-Native
- **12-Factor App**: Follows cloud-native application principles
- **Stateless**: Application instances are stateless and horizontally scalable
- **Configuration**: Environment-based configuration management
- **Logging**: Structured logging for observability

### Security
- **Least Privilege**: Minimal required permissions
- **Secrets Management**: No hardcoded credentials
- **Network Security**: Service mesh and network policies
- **Image Security**: Multi-stage builds, minimal base images

### Scalability
- **Horizontal Scaling**: Auto-scaling based on demand
- **Resource Efficiency**: Optimized resource requests and limits
- **Performance**: Nginx for static content, efficient CSV processing
- **Cost Optimization**: 
  - Spot instances for non-critical workloads
  - S3 intelligent tiering with automatic Glacier transitions
  - Multi-storage class lifecycle (Standard → Standard-IA → Glacier → Deep Archive)
  - 7-year retention policy with automatic cleanup

## Future Enhancements

### Monitoring & Observability
- Prometheus metrics collection
- Grafana dashboards
- Distributed tracing with Jaeger
- Centralized logging with ELK stack

### Advanced Features
- Real-time CSV processing with streaming
- Multiple file format support
- Advanced data validation and transformation
- API rate limiting and authentication

### Scalability Improvements
- Redis caching layer
- Message queue for async processing
- Database integration for metadata
- CDN integration for global distribution
