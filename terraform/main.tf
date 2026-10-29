
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-id"
    values = ["use1-az1", "use1-az2"]
  }
}

# --- VPC MODULE ---
module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=7c1f791efd61f326ed6102d564d1a65d1eceedf0"

  name = "three-tier-vpc"
  cidr = "10.0.0.0/16"

  azs = slice(
    data.aws_availability_zones.available.names,
    0,
    2
  )

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/three-tier-cluster" = "shared"
    "kubernetes.io/role/elb"                   = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/three-tier-cluster" = "shared"
    "kubernetes.io/role/internal-elb"          = "1"
  }
}

# --- EKS MODULE ---
module "eks" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=8a0efdbbc84180a26e0bacfd2b6fcfceac53b3b6"

  cluster_name                           = "three-tier-cluster"
  cluster_version                        = "1.31"
  cloudwatch_log_group_retention_in_days = 365

  # Enable all five EKS control-plane log types.
  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  # Preserve the existing cluster's setting.
  bootstrap_self_managed_addons = false

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # Preserve existing endpoint access for now.
  cluster_endpoint_public_access = true

  # Grant the current Terraform caller cluster administrator access.
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      # Verify eligibility and availability before applying.
      instance_types = ["t3.small"]
      ami_type       = "AL2_x86_64"
    }
  }
}
