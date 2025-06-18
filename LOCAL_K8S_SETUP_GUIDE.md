# Local Kubernetes Setup Guide

This guide explains how to run the app on a local Kubernetes cluster using Minikube, including the required setup for secure secret management with the AWS Secrets Store CSI Driver. All steps are required for the app to run successfully in this environment.

---

## 1. Overview

- **Purpose:** Deploy and run the app locally with Minikube, using AWS Secrets Manager for secret management via the Secrets Store CSI Driver.
- **Why:** The app requires secrets (such as credentials) to be securely injected at runtime. The AWS Secrets Store CSI Driver syncs secrets from AWS Secrets Manager into Kubernetes, making them available to the app as environment variables or files.

---

## 2. Prerequisites

- [ ] Minikube (v1.36.0+)
- [ ] kubectl
- [ ] Helm (v3+)
- [ ] Docker (for building images, if needed)
- [ ] AWS credentials with access to AWS Secrets Manager (and IAM permissions for CSI driver)

---

## 3. Step-by-Step: Run the App on Local Minikube Cluster

### 3.1 Start Minikube
```sh
minikube start
```

### 3.2 (Optional) Build and Load Docker Image
If you want to use a locally built image:
```sh
# Build the Docker image
docker build -t <your-image-name>:latest .
# Load the image into Minikube
eval $(minikube docker-env)
docker build -t <your-image-name>:latest .
```

### 3.3 Install AWS Secrets Store CSI Driver (REQUIRED)
_This step is required to enable secret syncing from AWS Secrets Manager._

#### a. Install CRDs
```sh
kubectl apply -f https://github.com/kubernetes-sigs/secrets-store-csi-driver/releases/download/v1.5.1/secrets-store.csi.x-k8s.io_secretproviderclasses.yaml
kubectl apply -f https://github.com/kubernetes-sigs/secrets-store-csi-driver/releases/download/v1.5.1/secrets-store.csi.x-k8s.io_secretproviderclasspodstatuses.yaml
```

#### b. Install the CSI Driver
```sh
kubectl apply -f https://github.com/kubernetes-sigs/secrets-store-csi-driver/releases/download/v1.5.1/secrets-store-csi-driver.yaml
```

#### c. Add and Install AWS Provider
```sh
helm repo add aws-secrets-manager https://aws.github.io/secrets-store-csi-driver-provider-aws
helm repo update
helm install -n kube-system aws-secrets-provider aws-secrets-manager/secrets-store-csi-driver-provider-aws
```

#### d. Wait for all CSI and AWS provider pods to be running
```sh
kubectl get pods -n kube-system | grep csi
kubectl get pods -n kube-system | grep aws
```

### 3.4 Apply Kubernetes Manifests (App, SecretProviderClass, etc.)
_This will deploy your app, SecretProviderClass, and all required resources. The app will not start correctly unless the CSI driver and AWS provider are running and secrets are synced._
```sh
kubectl apply -f k8s/
```

### 3.5 Access the App
```sh
minikube service <service-name>
# Or, get the NodePort and access via browser
kubectl get svc
```

---

## 4. Verification & Troubleshooting

- Check pods:
  ```sh
  kubectl get pods -A
  ```
- Check secrets:
  ```sh
  kubectl get secrets
  ```
- Describe resources for more info:
  ```sh
  kubectl describe pod <pod-name>
  kubectl describe secret <secret-name>
  ```
- Common issues:
  - Missing CRDs: Ensure you applied the CRDs before other manifests.
  - Pod errors: Check for missing secrets, misconfigured SecretProviderClass, or AWS permissions.
  - App not starting: Make sure the CSI driver and AWS provider pods are running and secrets are synced.

---

## 5. References
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Secrets Store CSI Driver](https://github.com/kubernetes-sigs/secrets-store-csi-driver)
- [AWS Provider for CSI Driver](https://github.com/aws/secrets-store-csi-driver-provider-aws)

---

_Last updated: 2025-06-19_
