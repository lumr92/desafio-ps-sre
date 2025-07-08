# Obtendo IP automaticamente
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  my_ip = "${chomp(data.http.myip.response_body)}/32"
}

# Criação de grupo de subnets para o DB
resource "aws_db_subnet_group" "desafio-db-subnet-group" {
  name = "desafio-db-subnet-group-lucasmenezes"
  subnet_ids = [aws_subnet.desafio-private-subnet-1.id, aws_subnet.desafio-private-subnet-2.id]
}

# Criação sg para rds
resource "aws_security_group" "desafio-sg-rds" {
  vpc_id      = aws_vpc.desafio-vpc.id
  name        = "Desafio-sg-rds-LucasMenezes"
  description = "Allow ssh inbound traffic"
  # Input
  ingress {
        description      = "SSH"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = [local.my_ip]
    }

    ingress {
        description      = "HTTP"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    } 
     
    ingress { 
        description      = "MySQL Port"
        to_port          = 3306
        from_port        = 3306
        protocol         = "tcp"
        security_groups  = [aws_security_group.desafio-sg-cluster-eks.id]
    }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  tags = {
    Name = "Desafio-sg-rds"
  }
}

# Criação RDS
resource "aws_db_instance" "desafio-rds" {
  allocated_storage    = 20
  storage_type         = "gp3"
  engine               = "mysql"
  engine_version       = "8.0.36"
  instance_class       = "db.t3.medium"
  db_subnet_group_name = aws_db_subnet_group.desafio-db-subnet-group.name
  db_name              = "DesafioRDSLucasMenezes"
  username             = var.db-username
  password             = var.db-password
  port                 = 3306
  identifier           = "terraform-database-desafio"
  skip_final_snapshot  = true

}