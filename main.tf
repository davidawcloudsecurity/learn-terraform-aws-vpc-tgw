# Define the provider
provider "aws" {
  region = var.region  # Change to your preferred region
}

variable region {
  default = "us-east-1"
}

# Create Production VPC
resource "aws_vpc" "production" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Production"
  }
}

# Create Non-Production VPC
resource "aws_vpc" "non_production" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "Non-Production"
  }
}

# Create Shared Services VPC
resource "aws_vpc" "shared_service" {
  cidr_block = "10.2.0.0/16"
  tags = {
    Name = "Shared-Service"
  }
}

# Create Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  description = "Main Transit Gateway"
  tags = {
    Name = "MainTransitGateway"
  }
}

# Attach Production VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "prod_attachment" {
  subnet_ids         = [aws_subnet.prod_subnet_a.id, aws_subnet.prod_subnet_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.production.id
  tags = {
    Name = "ProdAttachment"
  }
}

# Attach Non-Production VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "non_prod_attachment" {
  subnet_ids         = [aws_subnet.non_prod_subnet_a.id, aws_subnet.non_prod_subnet_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.non_production.id
  tags = {
    Name = "NonProdAttachment"
  }
}

# Attach Shared Services VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "shared_attachment" {
  subnet_ids         = [aws_subnet.shared_subnet_a.id, aws_subnet.shared_subnet_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.shared_service.id
  tags = {
    Name = "SharedAttachment"
  }
}

# Define subnets for each VPC
resource "aws_subnet" "prod_subnet_a" {
  vpc_id            = aws_vpc.production.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "ProdSubnetA"
  }
}

resource "aws_subnet" "prod_subnet_b" {
  vpc_id            = aws_vpc.production.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}b"
  tags = {
    Name = "ProdSubnetB"
  }
}

resource "aws_subnet" "non_prod_subnet_a" {
  vpc_id            = aws_vpc.non_production.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "NonProdSubnetA"
  }
}

resource "aws_subnet" "non_prod_subnet_b" {
  vpc_id            = aws_vpc.non_production.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "${var.region}b"
  tags = {
    Name = "NonProdSubnetB"
  }
}

resource "aws_subnet" "shared_subnet_a" {
  vpc_id            = aws_vpc.shared_service.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "SharedSubnetA"
  }
}

resource "aws_subnet" "shared_subnet_b" {
  vpc_id            = aws_vpc.shared_service.id
  cidr_block        = "10.2.2.0/24"
  availability_zone = "${var.region}b"
  tags = {
    Name = "SharedSubnetB"
  }
}

# Create Internet Gateway for Production VPC
resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.production.id
  tags = {
    Name = "ProdIGW"
  }
}

# Create Internet Gateway for Non-Production VPC  
resource "aws_internet_gateway" "non_prod_igw" {
  vpc_id = aws_vpc.non_production.id
  tags = {
    Name = "NonProdIGW"
  }
}

# Create Internet Gateway for Shared Services VPC
resource "aws_internet_gateway" "shared_igw" {
  vpc_id = aws_vpc.shared_service.id
  tags = {
    Name = "SharedIGW"
  }
}

# Create Route Table for Public Subnets in Production VPC
resource "aws_route_table" "prod_public" {
  vpc_id = aws_vpc.production.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_igw.id
  }
  tags = {
    Name = "ProdPublicRT"
  }
}

# Associate Public Subnets with the Route Table in Production VPC
resource "aws_route_table_association" "prod_public_a" {
  subnet_id      = aws_subnet.prod_subnet_a.id
  route_table_id = aws_route_table.prod_public.id
}

resource "aws_route_table_association" "prod_public_b" {
  subnet_id      = aws_subnet.prod_subnet_b.id
  route_table_id = aws_route_table.prod_public.id
}

# Create Route Table for Public Subnets in Non-Production VPC
resource "aws_route_table" "non_prod_public" {
  vpc_id = aws_vpc.non_production.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.non_prod_igw.id
  }
  tags = {
    Name = "NonProdPublicRT"
  }
}

# Associate Public Subnets with the Route Table in Non-Production VPC
resource "aws_route_table_association" "non_prod_public_a" {
  subnet_id      = aws_subnet.non_prod_subnet_a.id
  route_table_id = aws_route_table.non_prod_public.id
}

resource "aws_route_table_association" "non_prod_public_b" {
  subnet_id      = aws_subnet.non_prod_subnet_b.id
  route_table_id = aws_route_table.non_prod_public.id
}

# Create Route Table for Public Subnets in Shared Services VPC
resource "aws_route_table" "shared_public" {
  vpc_id = aws_vpc.shared_service.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.shared_igw.id
  }
  tags = {
    Name = "SharedPublicRT"
  }
}

# Associate Public Subnets with the Route Table in Shared Services VPC
resource "aws_route_table_association" "shared_public_a" {
  subnet_id      = aws_subnet.shared_subnet_a.id
  route_table_id = aws_route_table.shared_public.id
}

resource "aws_route_table_association" "shared_public_b" {
  subnet_id      = aws_subnet.shared_subnet_b.id
  route_table_id = aws_route_table.shared_public.id
}

# Create IAM Role for SSM
resource "aws_iam_role" "ssm_role" {
  name               = "ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ssm_role_trust_policy.json
}

data "aws_iam_policy_document" "ssm_role_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ssm_role.name
}

# EC2 Instance for Production VPC
resource "aws_instance" "prod_web" {
  ami                    = var.ami_id_vm_linux
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.prod_subnet_a.id  # Using the first subnet from Production VPC
  iam_instance_profile    = aws_iam_role.ssm_role.name
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.prod_web.id  # Security group for Production VPC
  ]

  tags = {
    Name = "Production-Web"
  }
}

# EC2 Instance for Non-Production VPC  
resource "aws_instance" "non_prod_web" {
  ami                    = var.ami_id_vm_linux
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.non_prod_subnet_a.id  # Using the first subnet from Non-Production VPC
  iam_instance_profile    = aws_iam_role.ssm_role.name
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.non_prod_web.id  # Security group for Non-Production VPC
  ]

  tags = {
    Name = "Non-Production-Web"
  }
}

# EC2 Instance for Shared Services VPC
resource "aws_instance" "shared_web" {
  ami                    = var.ami_id_vm_linux
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.shared_subnet_a.id  # Using the first subnet from Shared Services VPC
  iam_instance_profile    = aws_iam_role.ssm_role.name
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.shared_web.id  # Security group for Shared Services VPC
  ]

  tags = {
    Name = "Shared-Web"
  }
}
