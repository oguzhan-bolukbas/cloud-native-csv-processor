# cloud-native-csv-processor
    Cloud-native Node.js app to process and upload CSV files to S3, with infrastructure defined using Terraform and deployed via Helm

---

## Quick Start - Deployment

Deploy to Kubernetes using the Helm chart:

```bash
# Deploy the application
helm install csv-processor ./helm/csv-processor

# Access the application
kubectl port-forward service/csv-processor-nginx 8080:80
# Open http://localhost:8080 in your browser

# Upgrade deployment
helm upgrade csv-processor ./helm/csv-processor

# Uninstall
helm uninstall csv-processor
```

---

**For a complete local Kubernetes setup and secret management guide, see:**
[Local Kubernetes & AWS Secrets Store CSI Driver Setup Guide](./LOCAL_K8S_SETUP_GUIDE.md)

---

# Development Roadmap (TODO)

- [X] Phase 1 – Application Development (Node.js)
  - [X] Create CSV file upload UI (using multer)
  - [X] Parse CSV line by line and display on browser
  - [X] Add basic error handling
  - [X] Write Dockerfile and containerize the app
  - [X] Perform local tests
  - [X] Implement automated tests

- [X] Phase 2 – S3 Integration
  - [X] Implement file upload to S3 using AWS SDK or similar library
  - [X] Manage AWS credentials with `.env` file
  - [X] Test AWS S3 integration locally
  - [X] Plan S3 lifecycle rules for transition to Glacier

- [ ] Phase 3 – CI/CD & Image Publishing
  - [X] Run Jenkins locally in a container for CI/CD pipeline
  - [X] Build and test Docker image automatically
  - [X] Push Docker image to DockerHub (public repository)
  - [ ] Use the published DockerHub image for Kubernetes deployments
  - [ ] Deploy to Kubernetes using Helm in Jenkins pipeline

- [X] Phase 4 – Kubernetes YAML and Helm Chart
  - [X] Write deployment manifests including Nginx and Node.js app
  - [X] Expose the application via a Kubernetes Service
  - [X] Define ConfigMap and Secret resources
  - [X] Create reusable and parameterized Helm chart
  - [X] Configure shared volume so Nginx serves static files

- [X] Phase 5 – Deploy to Minikube
  - [X] Deploy Helm chart on Minikube
  - [X] Access app via `kubectl port-forward` or `minikube service`
  - [X] Test Horizontal Pod Autoscaler (HPA) for autoscaling
  - [X] Set up metrics-server and run CPU/memory based autoscaling tests

- [ ] Phase 6 – Terraform Cloud Infrastructure Setup
  - [ ] Create VPC, subnets, and networking resources with Terraform
  - [ ] Define EKS cluster and node groups (on-demand + spot)
  - [ ] Configure IAM roles and OIDC provider
  - [ ] Deploy application to cloud environment using Helm

- [ ] Phase 7 – Documentation & Architecture
  - [ ] Prepare project documentation
  - [ ] Create architecture diagram
