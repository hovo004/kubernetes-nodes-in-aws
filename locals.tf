locals {
  common_tags = {
    ManagedBy   = "Terraform"
    Project     = "k8s-cluster"
    Environment = "dev"
  }
}