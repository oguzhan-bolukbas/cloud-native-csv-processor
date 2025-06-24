provider "aws" {
  region = var.region
}

# Data sources for current AWS account and partition
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  name   = var.cluster_name
  region = var.region

  vpc_cidr = "10.123.0.0/16"
  azs      = ["${var.region}a", "${var.region}b"]

  public_subnets  = ["10.123.1.0/24", "10.123.2.0/24"]
  private_subnets = ["10.123.3.0/24", "10.123.4.0/24"]
  intra_subnets   = ["10.123.5.0/24", "10.123.6.0/24"]

  tags = merge(var.tags, {
    Name = local.name
  })
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  intra_subnets   = local.intra_subnets

  enable_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = local.name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  # Essential addons for production
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # Enable IRSA (IAM Roles for Service Accounts)
  enable_irsa = var.enable_irsa

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = var.instance_types
    capacity_type  = var.capacity_type

    attach_cluster_primary_security_group = true
    
    # Enable IMDSv2
    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 2
      instance_metadata_tags      = "disabled"
    }
  }

  eks_managed_node_groups = {
    # On-demand node group for critical system components
    csv-processor-on-demand = {
      name         = "csv-processor-on-demand"
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"

      # Node group specific configurations
      disk_size = 50

      # Taints to ensure only critical workloads run here
      taints = {
        critical = {
          key    = "node-type"
          value  = "on-demand"
          effect = "NO_SCHEDULE"
        }
      }

      # Labels for node selection
      labels = {
        role = "critical"
        capacity-type = "on-demand"
        node-type = "on-demand"
      }

      tags = {
        ExtraTag = "csv-processor-critical"
      }
    }

    # Spot node group for scalable application workloads
    csv-processor-spot = {
      name         = "csv-processor-spot"
      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      instance_types = var.instance_types
      capacity_type  = "SPOT"

      # Node group specific configurations
      disk_size = 50

      # Labels for node selection
      labels = {
        role = "worker"
        capacity-type = "spot"
        node-type = "spot"
      }

      tags = {
        ExtraTag = "csv-processor-workload"
      }
    }
  }

  # Cluster security group rules
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  # Node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  tags = local.tags
}

# IRSA for AWS Load Balancer Controller
module "aws_load_balancer_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "aws-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = local.tags
}

# IRSA for EBS CSI Driver
module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "ebs-csi-controller"

  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

# IRSA for your CSV processor application (for S3 access)
module "csv_processor_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "csv-processor-s3-access"

  role_policy_arns = {
    policy = aws_iam_policy.csv_processor_s3_policy.arn
  }

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["default:csv-processor-sa"]
    }
  }

  tags = local.tags
}

# S3 policy for CSV processor
resource "aws_iam_policy" "csv_processor_s3_policy" {
  name        = "csv-processor-s3-policy"
  path        = "/"
  description = "IAM policy for CSV processor S3 access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })

  tags = local.tags
}

# Outputs for connecting to the cluster
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_name" {
  description = "The name/id of the EKS cluster"
  value       = module.eks.cluster_name
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if enabled"
  value       = module.eks.oidc_provider_arn
}

# Service account role ARNs for application deployment
output "csv_processor_service_account_role_arn" {
  description = "ARN of the service account role for CSV processor"
  value       = module.csv_processor_irsa_role.iam_role_arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = module.aws_load_balancer_controller_irsa_role.iam_role_arn
}

# kubectl configuration command
output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}