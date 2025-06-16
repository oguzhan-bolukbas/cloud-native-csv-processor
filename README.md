# cloud-native-csv-processor
    Cloud-native Node.js app to process and upload CSV files to S3, with infrastructure defined using Terraform and deployed via Helm

# Development Roadmap (TODO)

- [ ] Phase 1 – Application Development (Node.js)
  - [X] Create CSV file upload UI (using multer)
  - [ ] Parse CSV line by line and display on browser
  - [ ] Add basic error handling
  - [ ] Write Dockerfile and containerize the app
  - [ ] Perform local tests

- [ ] Phase 2 – S3 Integration
  - [ ] Implement file upload to S3 using AWS SDK or similar library
  - [ ] Manage AWS credentials with `.env` file
  - [ ] Test AWS S3 integration locally
  - [ ] Plan S3 lifecycle rules for transition to Glacier

- [ ] Phase 3 – Kubernetes YAML and Helm Chart
  - [ ] Write deployment manifests including Nginx and Node.js app
  - [ ] Define ConfigMap and Secret resources
  - [ ] Create reusable and parameterized Helm chart
  - [ ] Configure shared volume so Nginx serves static files

- [ ] Phase 4 – Deploy to Minikube
  - [ ] Deploy Helm chart on Minikube
  - [ ] Access app via `kubectl port-forward` or `minikube service`
  - [ ] Test Horizontal Pod Autoscaler (HPA) for autoscaling
  - [ ] Set up metrics-server and run CPU/memory based autoscaling tests

- [ ] Phase 5 – Terraform Cloud Infrastructure Setup
  - [ ] Create VPC, subnets, and networking resources with Terraform
  - [ ] Define EKS cluster and node groups (on-demand + spot)
  - [ ] Configure IAM roles and OIDC provider
  - [ ] Deploy application to cloud environment using Helm

- [ ] Phase 6 – CI/CD Automation
  - [ ] Create GitHub Actions workflows for testing and linting
  - [ ] Automate Docker image build and push to DockerHub
  - [ ] Integrate Helm deploy into the pipeline
  - [ ] Secure secret management in CI/CD workflows

