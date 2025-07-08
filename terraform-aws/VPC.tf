# Criação VPC
resource "aws_vpc" "desafio-vpc" {
  cidr_block = "128.0.0.0/16"

  tags = {
    Name     = "Desafio-VPC-LucaMenezes"
  }
}

# Criação Internet Gateway
resource "aws_internet_gateway" "desafio-igw" {
  vpc_id = aws_vpc.desafio-vpc.id

  tags = {
    Name = "Desafio-Internet-Gateway-LucasMenezes"
  }
}

# Criação Subnet publica 1
resource "aws_subnet" "desafio-public-subnet-1" {
  vpc_id                  = aws_vpc.desafio-vpc.id
  cidr_block              = "128.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name                  = "Desafio-Public-Subnet-1-LucasMenezes" 
  }
}

# Criação Subnet publica 2
resource "aws_subnet" "desafio-public-subnet-2" {
  vpc_id                  = aws_vpc.desafio-vpc.id
  cidr_block              = "128.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name                  = "Desafio-Public-Subnet-2-LucasMenezes"
  }
}

# Criação Public route table 
resource "aws_route_table" "desafio-public-rt" {
  vpc_id       = aws_vpc.desafio-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.desafio-igw.id
  }

  tags = {
    Name       = "Desafio-Public-rt-LucasMenezes"
  }
}

# Criação Public Route table associate 1
resource "aws_route_table_association" "desafio-public-rt-assoc-1" {
  subnet_id      = aws_subnet.desafio-public-subnet-1.id
  route_table_id = aws_route_table.desafio-public-rt.id
}

# Criação Route table associate 2
resource "aws_route_table_association" "desafio-public-rt-assoc-2" {
  subnet_id      = aws_subnet.desafio-public-subnet-2.id
  route_table_id = aws_route_table.desafio-public-rt.id
}

# Criação Subnet privada 1
resource "aws_subnet" "desafio-private-subnet-1" {
  vpc_id                  = aws_vpc.desafio-vpc.id
  cidr_block              = "128.0.3.0/24"
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name                  = "Desafio-Private-Subnet-1-LucasMenezes"
  }
}

# Criação Subnet privada 2
resource "aws_subnet" "desafio-private-subnet-2" {
  vpc_id                  = aws_vpc.desafio-vpc.id
  cidr_block              = "128.0.4.0/24"
  availability_zone       = "${var.aws_region}b"

  tags = {
    Name                  = "Desafio-Private-Subnet-2-LucasMenezes"
  }
}

# Criação Private route table 
resource "aws_route_table" "desafio-private-rt" {
  vpc_id       = aws_vpc.desafio-vpc.id

  tags = {
    Name       = "Desafio-Private-rt-LucasMenezes"
  }
}

# Criação Private Route table associate 1
resource "aws_route_table_association" "desafio-private-rt-assoc-1" {
  subnet_id      = aws_subnet.desafio-private-subnet-1.id
  route_table_id = aws_route_table.desafio-private-rt.id
}

# Criação Private Route table associate 2
resource "aws_route_table_association" "desafio-private-rt-assoc-2" {
  subnet_id      = aws_subnet.desafio-private-subnet-2.id
  route_table_id = aws_route_table.desafio-private-rt.id
}