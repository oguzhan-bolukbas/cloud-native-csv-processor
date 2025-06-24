#!/bin/bash

set -e

echo "🚀 CSV Processor EKS Deployment Script"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check required tools
check_requirements() {
    echo "📋 Checking requirements..."
    
    for cmd in terraform aws kubectl helm; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "${RED}❌ $cmd is not installed${NC}"
            exit 1
        fi
    done
    echo -e "${GREEN}✅ All required tools are installed${NC}"
}

# Deploy infrastructure with Terraform
deploy_infrastructure() {
    echo "🏗️  Deploying infrastructure with Terraform..."
    
    cd terraform
    
    terraform init
    terraform plan -out=tfplan
    
    echo -e "${YELLOW}Do you want to apply the Terraform plan? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        terraform apply tfplan
    else
        echo "❌ Terraform apply cancelled"
        exit 1
    fi
    
    # Get outputs
    CLUSTER_NAME=$(terraform output -raw cluster_name)
    SERVICE_ACCOUNT_ROLE_ARN=$(terraform output -raw csv_processor_service_account_role_arn)
    AWS_LB_CONTROLLER_ROLE_ARN=$(terraform output -raw aws_load_balancer_controller_role_arn)
    
    echo -e "${GREEN}✅ Infrastructure deployed successfully${NC}"
    echo "Cluster Name: $CLUSTER_NAME"
    
    cd ..
}

# Configure kubectl
configure_kubectl() {
    echo "🔧 Configuring kubectl..."
    
    cd terraform
    CLUSTER_NAME=$(terraform output -raw cluster_name)
    REGION=$(terraform output -raw cluster_endpoint | cut -d'.' -f3)
    
    aws eks --region eu-north-1 update-kubeconfig --name $CLUSTER_NAME
    
    # Verify connection
    kubectl get nodes
    echo -e "${GREEN}✅ kubectl configured successfully${NC}"
    
    cd ..
}

# Install essential cluster components
install_cluster_components() {
    echo "📦 Installing essential cluster components..."
    
    # Install AWS Load Balancer Controller
    echo "Installing AWS Load Balancer Controller..."
    
    cd terraform
    AWS_LB_CONTROLLER_ROLE_ARN=$(terraform output -raw aws_load_balancer_controller_role_arn)
    CLUSTER_NAME=$(terraform output -raw cluster_name)
    cd ..
    
    # Create service account for AWS Load Balancer Controller
    kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: $AWS_LB_CONTROLLER_ROLE_ARN
EOF

    # Install AWS Load Balancer Controller using Helm
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    
    helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
      -n kube-system \
      --set clusterName=$CLUSTER_NAME \
      --set serviceAccount.create=false \
      --set serviceAccount.name=aws-load-balancer-controller
    
    # Install metrics server for HPA
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    
    echo -e "${GREEN}✅ Cluster components installed${NC}"
}

# Deploy application
deploy_application() {
    echo "🚀 Deploying CSV Processor application..."
    
    cd terraform
    SERVICE_ACCOUNT_ROLE_ARN=$(terraform output -raw csv_processor_service_account_role_arn)
    cd ..
    
    # Deploy application using Helm with production values
    helm upgrade --install csv-processor ./helm/csv-processor \
      --values ./helm/csv-processor/values-production.yaml \
      --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="$SERVICE_ACCOUNT_ROLE_ARN"
    
    echo -e "${GREEN}✅ Application deployed successfully${NC}"
}

# Show access information
show_access_info() {
    echo "🌐 Access Information"
    echo "===================="
    
    echo "📊 Check deployment status:"
    echo "kubectl get pods -l app.kubernetes.io/name=csv-processor"
    echo "kubectl get svc"
    echo "kubectl get ingress"
    
    echo ""
    echo "🔍 Access the application:"
    echo "# Wait for the Load Balancer to be ready (this may take 2-3 minutes)"
    echo "kubectl get ingress csv-processor-ingress"
    echo ""
    echo "# Get the Load Balancer URL:"
    echo "kubectl get ingress csv-processor-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
    echo ""
    echo "# Or use this command to get the full URL:"
    echo "echo \"http://\$(kubectl get ingress csv-processor-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')\""
    
    echo ""
    echo "📈 Monitor HPA:"
    echo "kubectl get hpa"
    echo "kubectl top pods"
    
    echo ""
    echo "📋 Useful commands:"
    echo "helm list"
    echo "kubectl logs -l app.kubernetes.io/name=csv-processor"
    echo "kubectl describe ingress csv-processor-ingress"
}

# Main execution
main() {
    check_requirements
    deploy_infrastructure
    configure_kubectl
    install_cluster_components
    deploy_application
    show_access_info
    
    echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
}

# Execute main function
main "$@"
