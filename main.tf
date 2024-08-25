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
  subnet_ids = [aws_subnet.prod_subnet_a.id, aws_subnet.prod_subnet_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id = aws_vpc.production.id
  tags = {
    Name = "ProdAttachment"
  }
}

# Attach Non-Production VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "non_prod_attachment" {
  subnet_ids = [aws_subnet.non_prod_subnet_a.id, aws_subnet.non_prod_subnet_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id = aws_vpc.non_production.id
  tags = {
    Name = "NonProdAttachment"
  }
}

# Attach Shared Services VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "shared_attachment" {
  subnet_ids = [aws_subnet.shared_subnet_a.id, aws_subnet.shared_subnet_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id = aws_vpc.shared_service.id
  tags = {
    Name = "SharedAttachment"
  }
}

# Define subnets for each VPC
resource "aws_subnet" "prod_subnet_a" {
  vpc_id     = aws_vpc.production.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "ProdSubnetA"
  }
}

resource "aws_subnet" "prod_subnet_b" {
  vpc_id     = aws_vpc.production.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "ProdSubnetB"
  }
}

resource "aws_subnet" "non_prod_subnet_a" {
  vpc_id     = aws_vpc.non_production.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "NonProdSubnetA"
  }
}

resource "aws_subnet" "non_prod_subnet_b" {
  vpc_id     = aws_vpc.non_production.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "NonProdSubnetB"
  }
}

resource "aws_subnet" "shared_subnet_a" {
  vpc_id     = aws_vpc.shared_service.id
  cidr_block = "10.2.1.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "SharedSubnetA"
  }
}

resource "aws_subnet" "shared_subnet_b" {
  vpc_id     = aws_vpc.shared_service.id
  cidr_block = "10.2.2.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "SharedSubnetB"
  }
}

# Create Route Table for Shared Services VPC
resource "aws_ec2_transit_gateway_route_table" "shared_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = {
    Name = "SharedServicesRouteTable"
  }
}

# Add routes for Shared Services VPC
resource "aws_ec2_transit_gateway_route" "shared_services_to_prod" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_route_table.id
  destination_cidr_block = aws_vpc.production.cidr_block
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.shared_attachment.id
}

resource "aws_ec2_transit_gateway_route" "shared_services_to_non_prod" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_route_table.id
  destination_cidr_block = aws_vpc.non_production.cidr_block
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.shared_attachment.id
}

# Create Route Table for Production VPC
resource "aws_ec2_transit_gateway_route_table" "prod_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = {
    Name = "ProductionRouteTable"
  }
}

# Add route for Production VPC to Shared Services
resource "aws_ec2_transit_gateway_route" "prod_to_shared" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_route_table.id
  destination_cidr_block = aws_vpc.shared_service.cidr_block
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.prod_attachment.id
}

# Create Route Table for Non-Production VPC
resource "aws_ec2_transit_gateway_route_table" "non_prod_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = {
    Name = "NonProductionRouteTable"
  }
}

# Add route for Non-Production VPC to Shared Services
resource "aws_ec2_transit_gateway_route" "non_prod_to_shared" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.non_prod_route_table.id
  destination_cidr_block = aws_vpc.shared_service.cidr_block
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.non_prod_attachment.id
}
