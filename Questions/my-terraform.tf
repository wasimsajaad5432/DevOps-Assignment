provider "aws" {
  region = "eu-north-1" # Updated region code for Stockholm
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Create Public Subnet in Stockholm
resource "aws_subnet" "public_subnet_stockholm" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"  # Stockholm, Zone A
  map_public_ip_on_launch = true
}

# Create Private Subnet in Stockholm
resource "aws_subnet" "private_subnet_stockholm" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-north-1b"  # Stockholm, Zone B
}

# Create Internet Gateway for public subnet
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a route table for public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a route table for private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a default route for the public route table to the Internet Gateway
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Associate the public route table with the public subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet_stockholm.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet_stockholm.id
  route_table_id = aws_route_table.private_route_table.id
}

output "public_subnet_route_table_id" {
  value = aws_route_table.public_route_table.id
}

output "private_subnet_route_table_id" {
  value = aws_route_table.private_route_table.id
}

output "public_subnet_association_ids" {
  value = aws_subnet.public_subnet_stockholm.*.association_ids
}

output "private_subnet_association_ids" {
  value = aws_subnet.private_subnet_stockholm.*.association_ids
}
