# --- networking/main.tf ---


### CUSTOM VPC CONFIGURATION

resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "aws_vpc" "awsprod_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "awsprod_vpc-${random_integer.random.id}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "available" {
}

### INTERNET GATEWAY

resource "aws_internet_gateway" "awsprod_internet_gateway" {
  vpc_id = aws_vpc.awsprod_vpc.id

  tags = {
    Name = "awsprod_igw"
  }
  lifecycle {
    create_before_destroy = true
  }
}


### PUBLIC SUBNETS (WEB TIER) AND ASSOCIATED ROUTE TABLES

resource "aws_subnet" "awsprod_public_subnets" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.awsprod_vpc.id
  cidr_block              = "10.1.${10 + count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "awsprod_public_${count.index + 1}"
  }
}

resource "aws_route_table" "awsprod_public_rt" {
  vpc_id = aws_vpc.awsprod_vpc.id

  tags = {
    Name = "awsprod_public"
  }
}

resource "aws_route" "default_public_route" {
  route_table_id         = aws_route_table.awsprod_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.awsprod_internet_gateway.id
}

resource "aws_route_table_association" "awsprod_public_assoc" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.awsprod_public_subnets.*.id[count.index]
  route_table_id = aws_route_table.awsprod_public_rt.id
}


### EIP AND NAT GATEWAY

resource "aws_eip" "awsprod_nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "awsprod_ngw" {
  allocation_id     = aws_eip.awsprod_nat_eip.id
  subnet_id         = aws_subnet.awsprod_public_subnets[1].id
}


### PRIVATE SUBNETS (APP TIER & DATABASE TIER) AND ASSOCIATED ROUTE TABLES

resource "aws_subnet" "awsprod_private_subnets" {
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.awsprod_vpc.id
  cidr_block              = "10.1.${20 + count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "awsprod_private_${count.index + 1}"
  }
}

resource "aws_route_table" "awsprod_private_rt" {
  vpc_id = aws_vpc.awsprod_vpc.id
  
  tags = {
    Name = "awsprod_private"
  }
}

resource "aws_route" "default_private_route" {
  route_table_id         = aws_route_table.awsprod_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.awsprod_ngw.id
}


resource "aws_route_table_association" "awsprod_private_assoc" {
  count          = var.private_sn_count
  route_table_id = aws_route_table.awsprod_private_rt.id
  subnet_id      = aws_subnet.awsprod_private_subnets.*.id[count.index]
}


resource "aws_subnet" "awsprod_private_subnets_db" {
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.awsprod_vpc.id
  cidr_block              = "10.1.${40 + count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "awsprod_private_db${count.index + 1}"
  }
}


### SECURITY GROUPS

resource "aws_security_group" "awsprod_bastionhost_sg" {
  name        = "awsprod_bastionhost_sg"
  description = "Allow SSH Inbound Traffic From Set IP"
  vpc_id      = aws_vpc.awsprod_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.access_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "awsprod_lb_sg" {
  name        = "awsprod_lb_sg"
  description = "Allow Inbound HTTP Traffic"
  vpc_id      = aws_vpc.awsprod_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "awsprod_frontend_app_sg" {
  name        = "awsprod_frontend_app_sg"
  description = "Allow SSH inbound traffic from Bastion, and HTTP inbound traffic from loadbalancer"
  vpc_id      = aws_vpc.awsprod_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.awsprod_bastionhost_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.awsprod_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "awsprod_backend_app_sg" {
  name        = "awsprod_backend_app_sg"
  vpc_id      = aws_vpc.awsprod_vpc.id
  description = "Allow Inbound HTTP from FRONTEND APP, and SSH inbound traffic from Bastion"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.awsprod_frontend_app_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.awsprod_bastionhost_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "awsprod_rds_sg" {
  name        = "three-tier_rds_sg"
  description = "Allow MySQL Port Inbound Traffic from Backend App Security Group"
  vpc_id      = aws_vpc.awsprod_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.awsprod_backend_app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


### DATABASE SUBNET GROUP

resource "aws_db_subnet_group" "awsprod_rds_subnetgroup" {
  count      = var.db_subnet_group == true ? 1 : 0
  name       = "awsprod_rds_subnetgroup"
  subnet_ids = [aws_subnet.awsprod_private_subnets_db[0].id, aws_subnet.awsprod_private_subnets_db[1].id]

  tags = {
    Name = "awsprod_rds_sng"
  }
}



# --- networking/outputs.tf ---

output "vpc_id" {
  value = aws_vpc.awsprod_vpc.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.awsprod_rds_subnetgroup.*.name
}

output "rds_db_subnet_group" {
  value = aws_db_subnet_group.awsprod_rds_subnetgroup.*.id
}

output "rds_sg" {
  value = aws_security_group.awsprod_rds_sg.id
}

output "frontend_app_sg" {
  value = aws_security_group.awsprod_frontend_app_sg.id
}

output "backend_app_sg" {
  value = aws_security_group.awsprod_backend_app_sg.id
}

output "bastionhost_sg" {
  value = aws_security_group.awsprod_bastionhost_sg.id
}

output "lb_sg" {
  value = aws_security_group.awsprod_lb_sg.id
}

output "public_subnets" {
  value = aws_subnet.awsprod_public_subnets.*.id
}

output "private_subnets" {
  value = aws_subnet.awsprod_private_subnets.*.id
}

output "private_subnets_db" {
  value = aws_subnet.awsprod_private_subnets_db.*.id
}

# --- networking/variables.tf ---

variable "vpc_cidr" {
  type = string
}

variable "public_sn_count" {
  type = number
}

variable "private_sn_count" {
  type = number
}

variable "access_ip" {
  type = string
}

variable "db_subnet_group" {
  type = bool
}

variable "availabilityzone" {}

variable "azs" {}