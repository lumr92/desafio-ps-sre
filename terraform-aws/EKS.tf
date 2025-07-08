# Criação de Role para garantir permissão para provisionamento do cluster K8s
resource "aws_iam_role" "desafio-role-eks-cluster" {
  name               = "Desafio-role-eks-cluster-LucasMenezes"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
    ]
  }
  EOF
}

# Atachando policies as roles para subir o cluster
resource "aws_iam_role_policy_attachment" "desafio-attach-eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.desafio-role-eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "desafio-attach-eks-service-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.desafio-role-eks-cluster.name
}

# Criação de Role para garantir permissão para provisionamennto dos nodes
resource "aws_iam_role" "desafio-role-nodes-eks-cluster" {
  name               = "Desafio-role-nodes-cluster-LucasMenezes"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

# Atachando policies as roles para subir os nodes
resource "aws_iam_role_policy_attachment" "desafio-attach-nodes-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.desafio-role-nodes-eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "desafio-attach-nodes-EKS-CNI-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.desafio-role-nodes-eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "desafio-attach-nodes-EC2-container-registry-readonly-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.desafio-role-nodes-eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "desafio-attach-nodes-worknode-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.desafio-role-nodes-eks-cluster.name
}

# Criação do cluster k8s
resource "aws_eks_cluster" "desafio-cluster-eks" {
  name                 = "Desafio-cluster-eks-LucasMenezes"
  role_arn             = aws_iam_role.desafio-role-eks-cluster.arn
  vpc_config {
    security_group_ids = [aws_security_group.desafio-sg-cluster-eks.id]
    subnet_ids         = [
        aws_subnet.desafio-public-subnet-1.id,
        aws_subnet.desafio-public-subnet-2.id,
    ]
  }

  # Adicionando depends_on para garantir que as politicas sejam anexadas nas roles antes da criação do cluster
  depends_on   = [ 
    aws_iam_role_policy_attachment.desafio-attach-eks-cluster-policy,
    aws_iam_role_policy_attachment.desafio-attach-eks-service-policy,
    aws_iam_role_policy_attachment.desafio-attach-nodes-cluster-policy,
    aws_iam_role_policy_attachment.desafio-attach-nodes-EKS-CNI-policy,
    aws_iam_role_policy_attachment.desafio-attach-nodes-EC2-container-registry-readonly-policy,
    aws_iam_role_policy_attachment.desafio-attach-nodes-worknode-policy,
   ]

   tags = {
    Name       = "Desafio-EKS-LucasMenezes"
  }
}

# Configurando node group on-demand
resource "aws_eks_node_group" "desafio-eks-nodes-ondemand" {
  cluster_name    = aws_eks_cluster.desafio-cluster-eks.name
  node_group_name = "desafio-eks-nodes-on-demand"
  subnet_ids      = [aws_subnet.desafio-public-subnet-1.id, aws_subnet.desafio-public-subnet-2.id]
  node_role_arn   = aws_iam_role.desafio-role-nodes-eks-cluster.arn
  capacity_type   = "ON_DEMAND"
  instance_types  = ["t3a.medium"]
  scaling_config {
    desired_size  = 1
    max_size      = 1
    min_size      = 1
  }

  tags = {
    Name          = "Desafio-EKS-node-group-LucasMenezes"
  }
}

# Configurando node group spot
resource "aws_eks_node_group" "desafio-eks-nodes-spot" {
  cluster_name    = aws_eks_cluster.desafio-cluster-eks.name
  node_group_name = "desafio-eks-nodes-spot"
  subnet_ids      = [aws_subnet.desafio-public-subnet-1.id, aws_subnet.desafio-public-subnet-2.id]
  node_role_arn   = aws_iam_role.desafio-role-nodes-eks-cluster.arn
  capacity_type   = "SPOT"
  instance_types  = ["t3a.medium"]
  scaling_config {
    desired_size  = 1
    max_size      = 1
    min_size      = 1
  }

  tags = {
    Name          = "Desafio-EKS-nodes-spot-LucasMenezes"
  }
}

resource "aws_eks_node_group" "desafio-eks-nodes-spot-2" {
  cluster_name    = aws_eks_cluster.desafio-cluster-eks.name
  node_group_name = "desafio-eks-nodes-spot-2"
  subnet_ids      = [aws_subnet.desafio-public-subnet-1.id, aws_subnet.desafio-public-subnet-2.id]
  node_role_arn   = aws_iam_role.desafio-role-nodes-eks-cluster.arn
  capacity_type   = "SPOT"
  instance_types  = ["t3a.medium"]
  scaling_config {
    desired_size  = 1
    max_size      = 1
    min_size      = 1
  }

  tags = {
    Name          = "Desafio-EKS-nodes-spot2-LucasMenezes"
  }
}

# Criando SG para o cluster
resource "aws_security_group" "desafio-sg-cluster-eks" {
  name        = "desafio-sg-cluster-LucasMenezes"
  description = "AWS sg for terraform"
  vpc_id      = aws_vpc.desafio-vpc.id

  # Input
  ingress {
    from_port   = "1"
    to_port     = "65365"
    protocol    = "TCP"
    cidr_blocks = concat(aws_subnet.desafio-public-subnet-1[*].cidr_block, aws_subnet.desafio-public-subnet-2[*].cidr_block, [aws_vpc.desafio-vpc.cidr_block])
  }

  # Output
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}