# Create a Virtual Private Cloud (VPC)
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "terraform-env-vpc"
    }
}

# Create an Internet Gateway to allow internet access to the VPC
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
}

# Create a route table for the public subnets to route traffic to the internet
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }   
}

# Create public subnets within the VPC using the defined CIDR blocks
resource "aws_subnet" "app_subnet" {
    count = 2
    vpc_id = aws_vpc.main.id
    cidr_block = element(var.subnet_cidrs, count.index)
    availability_zone = element(data.aws_availability_zones.available.names, count.index)
    tags = {
        Name = "public-subnet-${count.index}"
    }
}

# Associate the public subnets with the route table to allow internet access
resource "aws_route_table_association" "public_rt_assoc" {
    count = 2
    subnet_id = element(aws_subnet.app_subnet[*].id, count.index)
    route_table_id = aws_route_table.public_rt.id
}

