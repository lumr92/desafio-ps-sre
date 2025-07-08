# Criação sg para msk
resource "aws_security_group" "desafio-sg-msk" {
  vpc_id = aws_vpc.desafio-vpc.id
}

# Criação do cluster msk
resource "aws_msk_cluster" "desafio-msk-cluster" {
  cluster_name = "Desafio-cluster-msk-LucasMenezes"
  kafka_version = "3.7.x"
  number_of_broker_nodes = 2

  broker_node_group_info {
    instance_type = "kafka.t3.small"
    client_subnets = [
        aws_subnet.desafio-private-subnet-1.id,
        aws_subnet.desafio-private-subnet-2.id,
    ]
    security_groups = [aws_security_group.desafio-sg-msk.id]
  }
}
