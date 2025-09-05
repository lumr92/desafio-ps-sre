terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes= {
      source = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.10"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                    = data.aws_eks_cluster.Desafio-cluster-eks-LucasMenezes.endpoint
  cluster_ca_certificate  = base64decode(data.aws_eks_cluster.Desafio-cluster-eks-LucasMenezes.certificate_authority[0].data)
  token                   = data.aws_eks_cluster_auth.Desafio-cluster-eks-LucasMenezes-auth.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.Desafio-cluster-eks-LucasMenezes.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.Desafio-cluster-eks-LucasMenezes.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.Desafio-cluster-eks-LucasMenezes-auth.token
  }
}