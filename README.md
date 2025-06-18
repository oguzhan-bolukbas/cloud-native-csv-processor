# cloud-native-csv-processor
    Cloud-native Node.js app to process and upload CSV files to S3, with infrastructure defined using Terraform and deployed via Helm

# Development Roadmap (TODO)

- [X] Phase 1 – Application Development (Node.js)
  - [X] Create CSV file upload UI (using multer)
  - [X] Parse CSV line by line and display on browser
  - [X] Add basic error handling
  - [X] Write Dockerfile and containerize the app
  - [X] Perform local tests

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

- [ ] Phase 4 – Kubernetes YAML and Helm Chart
  - [ ] Write deployment manifests including Nginx and Node.js app
  - [ ] Define ConfigMap and Secret resources
  - [ ] Create reusable and parameterized Helm chart
  - [ ] Configure shared volume so Nginx serves static files

- [ ] Phase 5 – Deploy to Minikube
  - [ ] Deploy Helm chart on Minikube
  - [ ] Access app via `kubectl port-forward` or `minikube service`
  - [ ] Test Horizontal Pod Autoscaler (HPA) for autoscaling
  - [ ] Set up metrics-server and run CPU/memory based autoscaling tests

- [ ] Phase 6 – Terraform Cloud Infrastructure Setup
  - [ ] Create VPC, subnets, and networking resources with Terraform
  - [ ] Define EKS cluster and node groups (on-demand + spot)
  - [ ] Configure IAM roles and OIDC provider
  - [ ] Deploy application to cloud environment using Helm
