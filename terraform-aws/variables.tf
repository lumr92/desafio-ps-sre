variable "aws_region" {
  description = "aws region"
  type        = string
  default     = "us-east-2"
}

variable "profile_name" {
  description = "Profile name user AWS"
  type        = string
  default     = "PS-870205216049"
}

variable "db-username" {
  description = "usuário do db"
  default     = "desafio"
  type        = string
}

variable "db-password" {
  description = "senha do bd"
  default     = "password"
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
  default     = "Desafio-cluster-eks-LucasMenezes"
}

variable "domain_name" {
  description = "Domain name for ingress"
  type        = string
  default     = "desafio.app"
}

variable "certificate_arn" {
  description = "SSL certificate ARN from ACM"
  type        = string
  default     = ""
}

