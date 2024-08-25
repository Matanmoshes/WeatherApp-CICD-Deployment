provider "aws" {
    region = "us-east-1"
}

# VPC configuration
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Nmae = "terraform-env-vpc"
    }  
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
}

# Route table for publice subnet
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }  
}

# Publice Subnet
resource "aws_subnet" "app_subnet" {
    count             = 2
    vpc_id            = aws_vpc.main.id
    cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
    availability_zone = element(data.aws_availability_zones.available.names, count.index)

    tags = {
    Name = "public-subnet-${count.index}"
    }
}

# Associate Subnets with the Route Table
resource "aws_route_table_association" "public_rt_assoc" {
    count = 2
    subnet_id      = element(aws_subnet.app_subnet[*].id, count.index)
    route_table_id = aws_route_table.public_rt.id  
}

data "aws_availability_zone" "available" {}